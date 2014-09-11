#import "FDCulture.h"


#pragma mark Class Definition

@implementation FDCulture


#pragma mark - Overridden Methods

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

- (NSString *)description
{
	NSString *description = [NSString stringWithFormat: @"<%@: %p; %@-%@; %@>", 
		[self class], 
		self, 
		_languageCode, 
		_countryCode, 
		_englishCultureName];
	
	return description;
}


@end