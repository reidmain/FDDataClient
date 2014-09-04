#import "AppDelegate.h"
#import "FDCulture.h"


#pragma mark Class Definition

@implementation AppDelegate


#pragma mark - NSApplicationDelegate Methods

- (void)applicationDidFinishLaunching: (NSNotification *)notification
{
	FDDataClient *dataClient = [FDDataClient new];
	
	NSURL *url = [NSURL URLWithString: @"http://api.feedzilla.com/v1/cultures.json"];
	
	FDHTTPRequest *httpRequest = [[FDHTTPRequest alloc] 
		initWithURL: url];
	
	[dataClient loadHTTPRequest: httpRequest 
		authorizationBlock: nil 
		progressBlock: nil 
		dataParserBlock: nil 
		modelClassBlock: ^Class(NSString *parentKey, id value)
			{
				if ([value isKindOfClass: [NSDictionary class]] == YES)
				{
					return [FDCulture class];
				}
				
				return nil;
			} 
		completionBlock: ^(FDURLResponse *urlResponse)
			{
				NSLog(@"Finished loading:\n%@", urlResponse.content);
			}];
}


#pragma mark - Private Methods


@end