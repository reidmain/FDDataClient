#import "FDDataClient.h"
#import "FDModel.h"


#pragma mark Class Extension

@interface FDDataClient ()

- (id)_transformObjectToLocalModels: (id)object 
	fromURL: (NSURL *)url 
	modelClassBlock: (FDDataClientModelClassBlock)modelClassBlock 
	parentModelClass: (Class)parentModelClass 
	parentRemoteKeypath: (NSString *)parentRemoteKeyPath;

@end


#pragma mark - Class Definition

@implementation FDDataClient
{
	@private __strong FDRequestClient *_requestClient;
}


#pragma mark - Properties

- (void)setLogCurlCommandsToConsole:(BOOL)logCurlCommandsToConsole
{
	[_requestClient setLogCurlCommandsToConsole: logCurlCommandsToConsole];
}

- (BOOL)logCurlCommandsToConsole
{
	BOOL logCurlCommandsToConsole = [_requestClient logCurlCommandsToConsole];
	
	return logCurlCommandsToConsole;
}

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
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods


#pragma mark - Overridden Methods

- (FDRequestClientTask *)loadHTTPRequest: (FDHTTPRequest *)httpRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	modelClassBlock: (FDDataClientModelClassBlock)modelClassBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock
{
	FDRequestClientTask *requestClientTask = [_requestClient loadHTTPRequest: httpRequest 
		authorizationBlock: authorizationBlock 
		progressBlock: progressBlock 
		dataParserBlock: dataParserBlock 
		transformBlock: ^id(id object)
			{
				id transformedObject = [self _transformObjectToLocalModels: object 
					fromURL: httpRequest.url 
					modelClassBlock: modelClassBlock 
					parentModelClass: nil 
					parentRemoteKeypath: nil];
				
				return transformedObject;
			} 
		completionBlock: completionBlock];
	
	return requestClientTask;
}


#pragma mark - Private Methods

- (id)_transformObjectToLocalModels: (id)object 
	fromURL: (NSURL *)url 
	modelClassBlock: (FDDataClientModelClassBlock)modelClassBlock 
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
					fromURL: url 
					modelClassBlock: modelClassBlock 
					parentModelClass: parentModelClass 
					parentRemoteKeypath: parentRemoteKeyPath];
				
				if (FDIsNull(transformedObject) == NO)
				{
					[array addObject: transformedObject];
				}
			}];
		
		return array;
	}
	// If the object is a dictionary attempt to transform it to a local model.
	else if ([object isKindOfClass: [NSDictionary class]] == YES)
	{
		// Ask the block for the model class represented by the dictionary.
		Class modelClass = nil;
		if (modelClassBlock != nil)
		{
			modelClass = modelClassBlock(parentRemoteKeyPath, object);
		}
		
		// If the block did not return a model class ask the parent model class if it understands the dictionary.
		if (modelClass == nil)
		{
			modelClass = [parentModelClass modelClassForDictionary: object 
				withRemoteKeyPath: parentRemoteKeyPath];
		}
		
		// If the parent model class did not return a model class ask the delegate for the model class represented by the dictionary.
		if (modelClass == nil)
		{
			modelClass = [_delegate modelClassForValue: object];
		}
		
		// If the model class is NSNull ignore the dictionary entirely.
		if (modelClass == [NSNull class])
		{
			return nil;
		}
		
		// If there is no model class iterate over all the keys and objects and attempt to convert them to local models.
		if (modelClass == nil)
		{
			NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity: [object count]];
			
			[object enumerateKeysAndObjectsUsingBlock: ^(id key, id objectInDictionary, BOOL *stop)
				{
					id transformedObject = [self _transformObjectToLocalModels: objectInDictionary 
						fromURL: url 
						modelClassBlock: modelClassBlock 
						parentModelClass: parentModelClass 
						parentRemoteKeypath: key];
					
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
			FDModel *model = [modelClass modelWithIdentifier: identifier];
			
			// Get the mapping of remote key paths to local key paths for the model class.
			NSDictionary *keyPathsMapping = [modelClass remoteKeyPathsToLocalKeyPaths];
			
			// Iterate over the mapping and attempt to parse the objects for each remote key path into their respective local model key paths.
			[keyPathsMapping enumerateKeysAndObjectsUsingBlock: ^(id remoteKeyPath, id localKeyPath, BOOL *stop)
				{
					// Load the object for the remote key path and attempt to transform it to a local model.
					id remoteObject = [object valueForKeyPath: remoteKeyPath];
					
					// If the remote key path does not exist on the object ignore it and move onto the next item. There is no point in dealing with a remote key path that does not exist because it could only delete data that currently exists.
					if (remoteObject == nil)
					{
						return;
					}
					// If the remote object is NSNull make it nil to prevent the inevitable crash from working with NSNull objects. This will still allow the property being set to be cleared.
					else if (remoteObject == [NSNull null])
					{
						remoteObject = nil;
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
							fromURL: url 
							modelClassBlock: modelClassBlock 
							parentModelClass: modelClass 
							parentRemoteKeypath: remoteKeyPath];
					}
					
					// If the transformed object is not nil check if there are any common transforms that can be performed on the object before it is set on the property.
					if (transformedObject != nil)
					{
						// Get the property info on the property that is about to be set.
						FDDeclaredProperty *declaredProperty = [modelClass declaredPropertyForKeyPath: localKeyPath];
						
						// If the property being set is of type FDModel and the transformed object is a NSString or NSValue it is possible that the string is the unique identifier for the model. Check and see if an instance of model class with that identifier exists.
						if ([declaredProperty.type isSubclassOfClass: [FDModel class]] == YES 
							&& ([transformedObject isKindOfClass: [NSString class]] == YES 
								|| [transformedObject isKindOfClass: [NSValue class]] == YES))
						{
							// Ask the block for the model class represented by the transformed object.
							Class modelClass = nil;
							if (modelClassBlock != nil)
							{
								modelClass = modelClassBlock(remoteKeyPath, transformedObject);
							}
							
							// If the block did not return a model class ask the delegate for the model class represented by the transformed object.
							if (modelClass == nil)
							{
								modelClass = [_delegate modelClassForValue: transformedObject];
							}
							
							// If the model class is NSNull ignore the object entirely.
							if (modelClass == [NSNull class])
							{
								return;
							}
							
							// Ensure the model class is a subclass of FDModel.
							if ([modelClass isSubclassOfClass: [FDModel class]] == NO)
							{
								[NSException raise: NSInternalInconsistencyException 
									format: @"The model class for '%@' is not a subclass of FDModel.", 
										transformedObject];
								
								return;
							}
							
							// If the model class is still nil use the declared property type.
							
							transformedObject = [modelClass modelWithIdentifier: transformedObject];
						}
						// If the property being set is of type FDModel and the remote object is a NSDictionary attempt to transform the dictionary into a instance of the FDModel class.
						else if ([declaredProperty.type isSubclassOfClass: [FDModel class]] == YES 
							&& [remoteObject isKindOfClass: [NSDictionary class]] == YES)
						{
							transformedObject = [self _transformObjectToLocalModels: transformedObject 
								fromURL: url 
								modelClassBlock: ^Class(NSString *parentKey, id value)
									{
										if (parentKey == remoteKeyPath)
										{
											return declaredProperty.type;
										}
										
										if (modelClassBlock != nil)
										{
											Class modelClass = modelClassBlock(remoteKeyPath, transformedObject);
											
											return modelClass;
										}
										
										return nil;
									} 
								parentModelClass: parentModelClass 
								parentRemoteKeypath: remoteKeyPath];
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
				}];
			
#if DEBUG
			[modelClass _validateAndLogRemoteObject: object 
				fromURL: url];
#endif

			return model;
		}
	}
	else if ([object isKindOfClass: [NSString class]] == YES)
	{
		// Ask the block for the model class represented by the string.
		Class modelClass = nil;
		if (modelClassBlock != nil)
		{
			modelClass = modelClassBlock(parentRemoteKeyPath, object);
		}
		
		// If the model class is NSNull return nothing.
		if (modelClass == [NSNull class])
		{
			return nil;
		}
		// If the model class is nil return the string.
		else if (modelClass == nil)
		{
			return object;
		}
		
		// Ensure the model class is a subclass of FDModel.
		if ([modelClass isSubclassOfClass: [FDModel class]] == NO)
		{
			[NSException raise: NSInternalInconsistencyException 
				format: @"The model class for '%@' is not a subclass of FDModel.", 
					object];
			
			return object;
		}
		
		// Load the instance of the model for the string if it exists. Otherwise create a blank instance of the model.
		id transformedObject = [modelClass modelWithIdentifier: object];
		
		return transformedObject;
	}
	// If the object is a NSNull replace it with nil to prevent the inevitable crash caused by NSNull getting sent a message.
	else if (object == [NSNull null])
	{
		return nil;
	}
	
	// Return the object if it could not be transformed.
	return object;
}


@end