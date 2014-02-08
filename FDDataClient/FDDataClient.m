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
	
	// Return the object if it could not be transformed.
	return object;
}


@end