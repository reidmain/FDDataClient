#import "FDDataClient.h"


#pragma mark Class Definition

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

- (FDRequestClientTask *)loadHTTPRequest: (FDHTTPRequest *)httpRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	modelClassBlock: (FDModelProviderModelClassBlock)modelClassBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock
{
	FDRequestClientTask *requestClientTask = [_requestClient loadHTTPRequest: httpRequest 
		authorizationBlock: authorizationBlock 
		progressBlock: progressBlock 
		dataParserBlock: dataParserBlock 
		transformBlock: ^id(id object)
			{
				FDModelProvider *modelProvider = [FDModelProvider sharedInstance];
				id transformedObject = [modelProvider parseObject: object 
					modelClassBlock: ^Class(NSString *parentKey, id value)
						{
							// Ask the block for the model class represented by the transformed value.
							Class modelClass = nil;
							if (modelClassBlock != nil)
							{
								modelClass = modelClassBlock(parentKey, value);
							}
							
							// If the block did not return a model class ask the delegate for the model class represented by the transformed object.
							if (modelClass == nil)
							{
								modelClass = [_delegate modelClassForValue: value];
							}
							
							return modelClass;
						}];
				
				return transformedObject;
			} 
		completionBlock: completionBlock];
	
	return requestClientTask;
}


@end