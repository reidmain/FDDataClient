#import <FDRequestClient/FDRequestClient.h>


#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface FDDataClient : NSObject


#pragma mark - Properties


#pragma mark - Constructors


#pragma mark - Static Methods


#pragma mark - Instance Methods

- (FDRequestClientTask *)loadURLRequest: (FDURLRequest *)urlRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;


@end