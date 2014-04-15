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

+ (NSString *)remoteKeyPathForUniqueIdentifier
{
	// This method should be overridden by all subclasses.
	return nil;
}

+ (NSDictionary *)remoteKeyPathsToLocalKeyPaths
{
	// This method should be overridden by all subclasses.
	return nil;
}

+ (NSValueTransformer *)transformerForKey: (NSString *)key
{
	// Check if the class implements a method called "<key>Transformer" and return the result if it exists.
	NSString *selectorName = [NSString stringWithFormat: @"%@Transformer", 
		key];
	SEL selector = NSSelectorFromString(selectorName);
	
	if ([self respondsToSelector: selector] == YES)
	{
		__unsafe_unretained NSValueTransformer *transformer = nil;
		
		NSMethodSignature *methodSignature = [self methodSignatureForSelector: selector];
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: methodSignature];
		invocation.target = self;
		invocation.selector = selector;
		
		[invocation invoke];

		[invocation getReturnValue:&transformer];
		
		return transformer;
	}
	
	return nil;
}

+ (Class)modelClassForDictionary: (NSDictionary *)dictionary 
	withRemoteKeyPath: (NSString *)remoteKeyPath
{
	// This method can be overridden by all subclasses.
	return nil;
}


#pragma mark - Overridden Methods


#pragma mark - Private Methods


@end