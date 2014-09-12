#import "AppDelegate.h"
#import "FDCulture.h"


#pragma mark Class Definition

@implementation AppDelegate
{
	@private __strong UIWindow *_mainWindow;
}


#pragma mark - UIApplicationDelegate Methods

- (BOOL)application: (UIApplication *)application 
	didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
	// Create the main window.
	UIScreen *mainScreen = [UIScreen mainScreen];
	
	_mainWindow = [[UIWindow alloc] 
		initWithFrame: mainScreen.bounds];
	
	_mainWindow.backgroundColor = [UIColor blackColor];
	
	// TODO: Create the root view controller for the window.
	
	// Example use of the FDDataClient.
	NSURL *url = [NSURL URLWithString: @"http://api.feedzilla.com/v1/cultures.json"];
	
	FDHTTPRequest *httpRequest = [FDHTTPRequest requestWithURL: url];
	
	FDDataClient *dataClient = [FDDataClient new];
	[dataClient loadHTTPRequest: httpRequest 
		authorizationBlock: nil 
		progressBlock: nil 
		dataParserBlock: nil 
		modelClassBlock: ^Class(NSString *parentKey, id value)
			{
				if (parentKey == nil 
					 && [value isKindOfClass: [NSDictionary class]] == YES)
				{
					return [FDCulture class];
				}
				
				return nil;
			} 
		completionBlock: ^(FDURLResponse *urlResponse)
			{
				NSLog(@"Finished loading:\n%@", urlResponse.content);
			}];
	
	// Show the main window.
	[_mainWindow makeKeyAndVisible];
	
	// Indicate success.
	return YES;
}


@end