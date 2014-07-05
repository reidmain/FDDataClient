#import <FDRequestClient/FDRequestClient.h>
#import "FDDataClientDelegate.h"


#pragma mark - Class Interface

@interface FDDataClient : NSObject


#pragma mark - Properties

@property (nonatomic, weak) id<FDDataClientDelegate> delegate;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL logCurlCommandsToConsole;
@property (nonatomic, copy) NSArray *headerFieldsToLog;


#pragma mark - Instance Methods
/**
 *  Execute an http request.
 *
 *  @param httpRequest        The request to be executed.
 *  @param authorizationBlock A block to be called if an authentication 
 *                            challenge is received.
 *  @param progressBlock      A block to be called when the progress of a 
 *                            request changes.
 *  @param dataParserBlock    A block responsible for parsing api responses that 
 *                            are something other than JSON.
 *  @param modelClassBlock    A block responsible for determining which class 
 *                            response objects should be parse as
 *  @param completionBlock    A block to be called when the request is complete 
 *                            and all parsing is done.
 *
 *  @return A client task for the request being executed.
 */
- (FDRequestClientTask *)loadHTTPRequest: (FDHTTPRequest *)httpRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	modelClassBlock: (FDDataClientModelClassBlock)modelClassBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;


@end