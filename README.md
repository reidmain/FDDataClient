# Overview
Anyone who has worked with RESTful services in Objective-C knows the pain that is writing parsing code. FDDataClient tries to alleviate this pain by leveraging the networking layer of [FDRequestClient](https://github.com/reidmain/FDRequestClient) and the model layer of [FDModel](https://github.com/reidmain/FDModel). By combining these two projects FDDataClient allows users to easily implement their parsing logic using FDModel and when a HTTP request is being processed FDDataClient provides three hooks that can be used to determine what instance of FDModel an object from the response should be parsed into:

**1. Through a delegate method**  
FDDataClient implements a delegate that is asked what FDModel subclass an object should be converted into. This delegate is called on all requests made by the data client.

**2. Through a block specific to a given request**  
When making an HTTP request with the data client you can pass in a modelClassBlock that will be queried before the delegate. If the modelClassBlock returns a class the delegate will not be called. This allows users to override the delegate and provide information that is scoped to a specific request.

For example, in general if you encounter an NSDictionary with a key called "type" that has a value of "bah" that may be an indicator that you should create an instance of the FDBah class. However for a specific request encountering this same key-value pair may indicate you shoud create an instance of FDSubclassedBah.

**3. Through a method at a FDModel subclass level**  
When a FDModel subclass is being parsed you have ability to specify what class an object should be converted to through the modelClassForDictionary:withRemoteKeyPath: method.

Using these three methods any web service's data layer can be implemented easily and efficiently and remove all the boilplate code and headaches caused by writing your own parsing layer.

# Installation
There are two supported methods for FDDataClient. Both methods assume your Xcode project is using modules.

### 1. Subprojects
1. Add the "FDDataClient" project inside the "Framework Project" directory as a subproject or add it to your workspace.
2. Add "FDDataClient (iOS/Mac)" to the "Target Dependencies" section of your target.
3. Use "@import FDDataClient" inside any file that will be using FDDataClient.

### 2. CocoaPods
Simply add `pod "FDDataClient", "~> 1.0.0"` to your Podfile.

# Example
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

This example takes any dictionary that is off the root object of the response and communicates to the FDDataClient that those dictionaries should be transformed into instances of FDCulture. If you run the above code you will see the following logged to the console (at the time of writing):

	(
		"<FDCulture: 0x7ffefa87c950; ar-all; All (Arabic)>",
		"<FDCulture: 0x7ffefa87dae0; en-all; All (English)>",
		"<FDCulture: 0x7ffefa87dc90; es-ar; Argentina>",
		"<FDCulture: 0x7ffefa87de40; en-au; Australia>",
		"<FDCulture: 0x7ffefa87e1c0; pt-br; Brazil>",
		"<FDCulture: 0x7ffefa87e340; en-ca; Canada>",
		"<FDCulture: 0x7ffefa87e4c0; zh-cn; China>",
		"<FDCulture: 0x7ffefa87e640; en-cn; China (English)>",
		"<FDCulture: 0x7ffefa87e7c0; es-co; Colombia>",
		"<FDCulture: 0x7ffefa87eb40; ar-eg; Egypt (Arabic)>",
		"<FDCulture: 0x7ffefa8127e0; en-eg; Egypt (English)>",
		"<FDCulture: 0x7ffefa87f340; fr-fr; France>",
		"<FDCulture: 0x7ffefa87f4c0; de-de; Germany>",
		"<FDCulture: 0x7ffefa87f640; en-de; Germany (English)>",
		"<FDCulture: 0x7ffefa87f7c0; hi-in; India>",
		"<FDCulture: 0x7ffefa87f940; en-in; India (English)>",
		"<FDCulture: 0x7ffefa87fac0; it-it; Italy>",
		"<FDCulture: 0x7ffefa87fd40; es-mx; Mexico>",
		"<FDCulture: 0x7ffefa87fe00; en-pk; Pakistan>",
		"<FDCulture: 0x7ffefa8801b0; pl-pl; Poland>",
		"<FDCulture: 0x7ffefa880330; ru-ru; Russia>",
		"<FDCulture: 0x7ffefa8804b0; ar-sa; Saudi Arabia (Arabic)>",
		"<FDCulture: 0x7ffefa880630; en-sa; Saudi Arabia (English)>",
		"<FDCulture: 0x7ffefa8809b0; en-za; South Africa>",
		"<FDCulture: 0x7ffefa810ba0; es-es; Spain>",
		"<FDCulture: 0x7ffefa880db0; tr-tr; Turkey>",
		"<FDCulture: 0x7ffefa880f30; en-uk; United Kingdom>",
		"<FDCulture: 0x7ffefa8810b0; en-us; United States>",
		"<FDCulture: 0x7ffefa87fc70; vn-vn; Vietnam>"
	)

and you can see that each dictionary has been automatically parsed into a FDCulture object and the ONLY method that had to be implement on FDCulture is:

	+ (NSDictionary *)remoteKeyPathsToLocalKeyPaths
	{
		FDCulture *culture = nil;
		
		NSDictionary *remoteKeyPathsToLocalKeyPaths = @{ 
			@"language_code" : @keypath(culture.languageCode), 
			@"country_code" : @keypath(culture.countryCode), 
			@"culture_code" : @keypath(culture.cultureCode), 
			@"display_culture_name" : @keypath(culture.displayCultureName), 
			@"english_culture_name" : @keypath(culture.englishCultureName) 
			};
		
		return remoteKeyPathsToLocalKeyPaths;
	}

This example shows how you can specify what objects should be parsed on a per request level. If your web service is properly designed so you do not need to know what request is being made and you can type all the responses in a bubble then you can implement this same logic in the FDDataClient's delegate.
