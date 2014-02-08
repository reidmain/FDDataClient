#import "FDModel.h"


#pragma mark Constants


#pragma mark - Class Extension

@interface FDModel ()

@end


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation FDModel


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
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods

+ (NSDictionary *)remoteKeyPathsToLocalKeyPaths
{
	// This method should be overridden by all subclasses.
	return nil;
}


#pragma mark - Overridden Methods


#pragma mark - Private Methods


@end