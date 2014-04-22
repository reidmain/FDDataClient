#import "FDDataClient.h"
#import "FDModel.h"


#pragma mark Constants


#pragma mark - Class Extension

@interface FDDataClient ()

- (FDModel *)_modelForClass: (Class)modelClass 
	withIdentifier: (id)identifier;
- (id)_transformObjectToLocalModels: (id)object 
	parentModelClass: (Class)parentModelClass 
	parentRemoteKeypath: (NSString *)parentRemoteKeyPath;
- (id)_transformObjectToLocalModels: (id)object;

@end


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation FDDataClient
{
	@private __strong FDRequestClient *_requestClient;
	@private __strong NSMutableDictionary *_existingModelsByClass;
}


#pragma mark - Properties

- (void)setHeaderFieldsToLog: (NSArray *)headerFieldsToLog
{
	[_requestClient setHeaderFieldsToLog: headerFieldsToLog];
}

- (NSArray *)headerFieldsToLog
{
	NSArray *headerFieldsToLog = [_requestClient headerFieldsToLog];
	
	return headerFieldsToLog;
}


#pragma mark - Constructors

- (id)init
{
	// Abort if base initializer fails.
	if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Initialize instance variables.
	_requestClient = [FDRequestClient new];
	_existingModelsByClass = [NSMutableDictionary new];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods


#pragma mark - Overridden Methods

- (FDRequestClientTask *)loadHTTPRequest: (FDHTTPRequest *)httpRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock
{
	FDRequestClientTask *requestClientTask = [_requestClient loadHTTPRequest: httpRequest 
		authorizationBlock: authorizationBlock 
		progressBlock: progressBlock 
		dataParserBlock: dataParserBlock 
		transformBlock: ^id(id object)
			{
				id transformedObject = [self _transformObjectToLocalModels: object];
				
				return transformedObject;
			} 
		completionBlock: completionBlock];
	
	return requestClientTask;
}


#pragma mark - Private Methods

- (FDModel *)_modelForClass: (Class)modelClass 
	withIdentifier: (id)identifier
{
	// If the modelClass parameter is not a subclass of FDModel do not attempt to create anything.
	if ([modelClass isSubclassOfClass: [FDModel class]] == NO)
	{
		FDLog(FDLogLevelTrace, @"%s was called with %@ as the modelClass parameter which is not a subclass of FDModel.", __PRETTY_FUNCTION__, modelClass);
		
		return nil;
	}
	else if (FDIsEmpty(identifier) == NO 
		&& [identifier conformsToProtocol: @protocol(NSCopying)] == NO)
	{
		FDLog(FDLogLevelTrace, @"%s was called with %@ as the identifier paramter which does not implement NSCopying.", __PRETTY_FUNCTION__, identifier);
	}
	
	FDModel *model = nil;
	
	// If a identifier has been passed in check if a instance of modelClass with that identifier already exists.
	if (FDIsEmpty(identifier) == NO)
	{
		NSString *modelClassAsString = NSStringFromClass(modelClass);
		
		@synchronized(self)
		{
			// Load the dictionary of all the existings modelClass instances. If the dictionary does not yet exist create one.
			FDWeakMutableDictionary *existingModels = [_existingModelsByClass objectForKey: modelClassAsString];
			if (existingModels == nil)
			{
				existingModels = [FDWeakMutableDictionary dictionary];
				[_existingModelsByClass setValue: existingModels 
					forKey: modelClassAsString];
			}
			
			// Load the existing modelClass instance for the identifier.
			model = [existingModels objectForKey: identifier];
			
			// If the model does not exist create a blank instance of it and assign the identifier.
			if (model == nil)
			{
				model = [modelClass new];
				[model setIdentifier: identifier];
				
				[existingModels setObject: model 
					forKey: identifier];
			}
		}
	}
	// If no identifier has been passed in create a blank instance of modelClass.
	else
	{
		model = [modelClass new];
	}
	
	return model;
}

- (id)_transformObjectToLocalModels: (id)object 
	parentModelClass: (Class)parentModelClass 
	parentRemoteKeypath: (NSString *)parentRemoteKeyPath
{
	// Ensure the parent model class is a subclass of FDModel.
	if (parentModelClass != nil 
		&& [parentModelClass isSubclassOfClass: [FDModel class]] == NO)
	{
		[NSException raise: NSInvalidArgumentException 
			format: @"The parentModelClass parameter on %@ must be a subclass of FDModel", 
				NSStringFromSelector(_cmd)];
		
		return object;
	}
	
	// If the object is an array attempt to transform each element of the array.
	if ([object isKindOfClass: [NSArray class]] == YES)
	{
		NSMutableArray *array = [NSMutableArray arrayWithCapacity: [object count]];
		
		[object enumerateObjectsUsingBlock: ^(id objectInArray, NSUInteger index, BOOL *stop)
			{
				id transformedObject = [self _transformObjectToLocalModels: objectInArray 
					parentModelClass: parentModelClass 
					parentRemoteKeypath: parentRemoteKeyPath];
				
				[array addObject: transformedObject];
			}];
		
		return array;
	}
	// If the object is a dictionary attempt to transform it to a local model.
	else if ([object isKindOfClass: [NSDictionary class]] == YES)
	{
		// Ask the delegate for the model class represented by the dictionary.
		Class modelClass = [_delegate modelClassForIdentifier: object];
		
		// If the delegate did not return a model class ask the parent model class if it understands the dictionary.
		if (modelClass == nil)
		{
			modelClass = [parentModelClass modelClassForDictionary: object 
				withRemoteKeyPath: parentRemoteKeyPath];
		}
		
		// If there is no model class iterate over all the keys and objects and attempt to convert them to local models.
		if (modelClass == nil)
		{
			NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity: [object count]];
			
			[object enumerateKeysAndObjectsUsingBlock: ^(id key, id objectInDictionary, BOOL *stop)
				{
					id transformedObject = [self _transformObjectToLocalModels: objectInDictionary];
					
					[dictionary setValue: transformedObject 
						forKey: key];
				}];
			
			return dictionary;
		}
		// If the delegate returned a model class populate an instance of it.
		else
		{
			// Ensure the model class is a subclass of FDModel.
			if ([modelClass isSubclassOfClass: [FDModel class]] == NO)
			{
				[NSException raise: NSInternalInconsistencyException 
					format: @"The model class for the following dictionary is not a subclass of FDModel:\n%@", 
						object];
				
				return object;
			}
			
			// Get the remote key path that that points to the unique identifier of the object.
			NSString *remoteKeyPathForUniqueIdentifier = [modelClass remoteKeyPathForUniqueIdentifier];
			id identifier = [object valueForKeyPath: remoteKeyPathForUniqueIdentifier];
			
			// Load the instance of the model for the identifier if it exists. Otherwise create a blank instance of the model.
			FDModel *model = [self _modelForClass: modelClass 
				withIdentifier: identifier];
			
			// Get the mapping of remote key paths to local key paths for the model class.
			NSDictionary *keyPathsMapping = [modelClass remoteKeyPathsToLocalKeyPaths];
			
			// Iterate over the mapping and attempt to parse the objects for each remote key path into their respective local model key paths.
			[keyPathsMapping enumerateKeysAndObjectsUsingBlock: ^(id remoteKeyPath, id localKeyPath, BOOL *stop)
				{
					// Load the object for the remote key path and attempt to transform it to a local model.
					id remoteObject = [object valueForKeyPath: remoteKeyPath];
					
					// If the remote object is null ignore it and move onto the next item. There is no point to deal with a null object because it could only delete data that currently exists.
					if (FDIsNull(remoteObject) == YES)
					{
						return;
					}
					
					// If a local transformer has been defined use it instead of attempting to transform the object into local models.
					id transformedObject = nil;
					
					NSValueTransformer *valueTransformer = [modelClass transformerForKey: localKeyPath];
					if (valueTransformer != nil)
					{
						transformedObject = [valueTransformer transformedValue: remoteObject];
					}
					else
					{
						transformedObject = [self _transformObjectToLocalModels: remoteObject 
							parentModelClass: modelClass 
							parentRemoteKeypath: remoteKeyPath];
					}
					
					// If the transformed object is nil do not attempt to set it on the model because it could be erasing data that already exists.
					if (transformedObject != nil)
					{
						// Get the property info on the property that is about to be set.
						FDDeclaredProperty *declaredProperty = [modelClass declaredPropertyForKeyPath: localKeyPath];
						
						// If the property being set is of type FDModel and the transformed object is a NSString or NSValue it is possible that the string is the unique identifier for the model. Check and see if an instance of model class with that identifier exists.
						if ([declaredProperty.type isSubclassOfClass: [FDModel class]] == YES 
							&& ([transformedObject isKindOfClass: [NSString class]] == YES 
								|| [transformedObject isKindOfClass: [NSValue class]] == YES))
						{
							// Ask the delegate for the model class represented by the string.
							Class modelClass = [_delegate modelClassForIdentifier: transformedObject];
							
							// Ensure the model class is a subclass of FDModel.
							if ([modelClass isSubclassOfClass: [FDModel class]] == NO)
							{
								[NSException raise: NSInternalInconsistencyException 
									format: @"The model class for '%@' is not a subclass of FDModel.", 
										transformedObject];
								
								return;
							}
							
							transformedObject = [self _modelForClass: modelClass 
								withIdentifier: transformedObject];
						}
						// If the property being set is a NSURL and the transformed object is a NSString convert the string to a NSURL object.
						else if ([declaredProperty.type isSubclassOfClass: [NSURL class]] == YES 
							&& [transformedObject isKindOfClass: [NSString class]] == YES)
						{
							transformedObject = [NSURL URLWithString: transformedObject];
						}
						// If the property being set is a NSDate and the transformed object is a NSString attempt to convert the string to a NSDate using the data client's date formatter.
						else if ([declaredProperty.type isSubclassOfClass: [NSDate class]] == YES 
							&& [transformedObject isKindOfClass: [NSString class]] == YES)
						{
							transformedObject = [_dateFormatter dateFromString: transformedObject];
						}
						// If the property being set is a NSString and the transformed object is a NSNumber convert the number to a string.
						else if ([declaredProperty.type isSubclassOfClass: [NSString class]] == YES 
							&& [transformedObject isKindOfClass: [NSNumber class]] == YES)
						{
							transformedObject = [transformedObject stringValue];
						}
						
						// If the transformed object is not the same type as the property that is being set stop parsing this remote key path.
						if (declaredProperty.type != nil 
							 && [transformedObject isKindOfClass: declaredProperty.type] == NO)
						{
							return;
						}
						
						@try
						{
							[model setValue: transformedObject 
								forKeyPath: localKeyPath];
						}
						// If the key path on the local model does not exist an exception will most likely be thrown. Catch this exeception and log it so that any incorrect mappings will not crash the application.
						@catch (NSException *exception)
						{
							FDLog(FDLogLevelInfo, @"Could not set %@ property on %@ because %@", localKeyPath, [model class], [exception reason]);
						}
					}
				}];
			
			return model;
		}
	}
	// If the object is a NSNull replace it with nil to prevent the inevitable crash caused by NSNull getting sent a message.
	else if (object == [NSNull null])
	{
		return nil;
	}
	
	// Return the object if it could not be transformed.
	return object;
}

- (id)_transformObjectToLocalModels: (id)object
{
	id transformedObject = [self _transformObjectToLocalModels: object 
		parentModelClass: nil 
		parentRemoteKeypath: nil];
	
	return transformedObject;
}


@end