#import "FDDataClient.h"
#import "FDModel.h"


#pragma mark Constants


#pragma mark - Class Extension

@interface FDDataClient ()

- (id)_transformObjectToLocalModels: (id)object;

@end


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation FDDataClient
{
	@private __strong FDRequestClient *_requestClient;
}


#pragma mark - Properties


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

- (FDRequestClientTask *)loadURLRequest: (FDURLRequest *)urlRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock
{
	FDRequestClientTask *requestClientTask = [_requestClient loadURLRequest: urlRequest 
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

- (id)_transformObjectToLocalModels: (id)object
{
	// If the object is an array attempt to transform each element of the array.
	if ([object isKindOfClass: [NSArray class]] == YES)
	{
		NSMutableArray *array = [NSMutableArray arrayWithCapacity: [object count]];
		
		[object enumerateObjectsUsingBlock: ^(id objectInArray, NSUInteger idx, BOOL *stop)
			{
				id transformedObject = [self _transformObjectToLocalModels: objectInArray];
				
				[array addObject: transformedObject];
			}];
		
		return array;
	}
	// If the object is a dictionary attempt to transform it to a local model.
	else if ([object isKindOfClass: [NSDictionary class]] == YES)
	{
		// Ask delegate for the model class represented by the dictionary.
		Class modelClass = [_delegate modelClassForDictionary: object];
		
		// If the delegate did not return a model class do not attempt to create one.
		if (modelClass != nil)
		{
			// Create an instance of the model.
			FDModel *model = [modelClass new];
			
			// Get the mapping of remote key paths to local key paths for the model class.
			NSDictionary *keyPathsMapping = [modelClass remoteKeyPathsToLocalKeyPaths];
			
			// Iterate over the mapping and attempt to parse the objects for each remote key path into their respective local model key path.
			[keyPathsMapping enumerateKeysAndObjectsUsingBlock: ^(id remoteKeyPath, id localKeyPath, BOOL *stop)
				{
					id remoteObject = [object valueForKeyPath: remoteKeyPath];
					id transformedObject = [self _transformObjectToLocalModels: remoteObject];
					
					@try
					{
						[model setValue: transformedObject 
							forKeyPath: localKeyPath];
					}
					// If the key path on the local model does not exist an exception will most likely be thrown. Catch this exeception and log it so that any incorrect mappings will not crash the application.
					@catch (NSException *exception)
					{
						NSLog(@"%@", exception);
					}
				}];
			
			return model;
		}
	}
	
	// Return the object if it could not be transformed.
	return object;
}


@end