@import Foundation;

@import FDModel;
@import FDRequestClient;

#import "FDDataClientDelegate.h"


#pragma mark Class Interface

/**
FDDataClient is a wrapper class around FDRequestClient which encapsulates the process of making HTTP requests and converting the resulting objects into instances of an FDModel subclass.

When an HTTP request is being processed there are three methods that can be used to determine what an object should be parsed into:

1. Through a delegate method
FDDataClient implements a delegate that is asked what FDModel subclass an object should be converted into. This delegate is called on all requests made by the data client.

2. Through a block specific to a given request
When making an HTTP request with the data client you can pass in a modelClassBlock that will be queried before the delegate. If the modelClassBlock returns a class the delegate will not be called. This allows users to override the delegate and provide information that is scoped to a specific request.

For example, in general if you encounter an NSDictionary with a key called "type" that has a value of "bah" that may be an indicator that you should create an instance of the FDBah class. However for a specific request encountering this same key-value pair may indicate you shoud create an instance of FDSubclassedBah.

3. Through a method at a FDModel subclass level
When a FDModel subclass is being parsed you have ability to specify what class an object should be converted to through the modelClassForDictionary:withRemoteKeyPath: method.
*/
@interface FDDataClient : NSObject


#pragma mark - Properties

/**
The object that acts as the delegate of the data client.

The delegate must adopt the FDDataClientDelegate protocol. The data client maintains only a weak reference to the delegate.
*/
@property (nonatomic, weak) id<FDDataClientDelegate> delegate;

/**
When set to YES a curl command will be logged to the console when a request is loaded.

This allows users to easily see what requests are being made as well as duplicate those requests.
*/
@property (nonatomic, assign) BOOL logCurlCommandsToConsole;

/**
If logCurlCommandsToConsole is set to YES this value is intersected with the headers of the request being made and the resulting headers are added to the curl command logged to the console.

By default the "Authorization" field is the only field that is logged.
*/
@property (nonatomic, copy) NSArray *headerFieldsToLog;


#pragma mark - Instance Methods

/**
Starts loading a HTTP request asynchronously and executes a number of blocks while the request is being loaded.

This method behaves almost exactly like FDRequestClient's loadHTTPRequest:authorizationBlock:progressBlock:dataParserBlock:transformBlock:completionBlock method. The only difference is that the transformBlock is replaced with the the modelClassBlock.

@param httpRequest The HTTP request to load. This parameter must not be nil.
@param authorizationBlock The block to call when an authentication challenge occurs. This parameter may be nil.
@param progressBlock The block to call when the progress of the request is updated. This parameter may be nil.
@param dataParserBlock The block to call when parsing the NSData returned from the request. If this parameter is nil the NSData is automatically parsed based on the 'Content-Type' header of the response.
@param modelClassBlock The block to call when determining which class an object from the response should be parsed into. This parameter may be nil.
@param completionBlock The block to call when the request finishes loading and the response has been generated. This parameter may be nil.

@return A client task for the request being loaded.

@see [FDRequestClient loadHTTPRequest:authorizationBlock:progressBlock:dataParserBlock:transformBlock:completionBlock:]
*/
- (FDRequestClientTask *)loadHTTPRequest: (FDHTTPRequest *)httpRequest 
	authorizationBlock: (FDRequestClientTaskAuthorizationBlock)authorizationBlock 
	progressBlock: (FDRequestClientTaskProgressBlock)progressBlock 
	dataParserBlock: (FDRequestClientTaskDataParserBlock)dataParserBlock 
	modelClassBlock: (FDModelProviderModelClassBlock)modelClassBlock 
	completionBlock: (FDRequestClientTaskCompletionBlock)completionBlock;


@end