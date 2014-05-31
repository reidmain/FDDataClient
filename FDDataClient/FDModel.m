#import "FDModel.h"
#import <objc/runtime.h>
#import <FDFoundationKit/FDFoundationKit.h>


#pragma mark Constants


#pragma mark - Class Extension

@interface FDModel ()

@end


#pragma mark - Class Variables

static NSMutableDictionary *_existingModelsByClass;


#pragma mark - Class Definition

@implementation FDModel


#pragma mark - Properties


#pragma mark - Constructors

+ (void)initialize
{
	// NOTE: initialize is called in a thead-safe manner so we don't need to worry about two shared instances possibly being created.
	
	// Create a flag to keep track of whether or not this class has been initialized because this method could be called a second time if a subclass does not override it.
	static BOOL classInitialized = NO;
	
	// If this class has not been initialized then initalize the class variables.
	if (classInitialized == NO)
	{
		_existingModelsByClass = [NSMutableDictionary new];
		
		classInitialized = YES;
	}
}

+ (instancetype)modelWithIdentifier: (id)identifier
{
	FDModel *model = [[self alloc] 
		initWithIdentifier: identifier];
	
	return model;
}

- (instancetype)initWithIdentifier: (id)identifier 
	initializerBlock: (FDModelInitializerBlock)initializerBlock
{
	// If an identifier has been passed in check if an instance of the class with the identifier already exists.
	if (FDIsEmpty(identifier) == NO)
	{
		// This code needs to be synchronized because models can be created from any thread.
		@synchronized(self)
		{
			NSString *modelClassAsString = NSStringFromClass([self class]);
			
			// Load the dictionary of all the existings model instances. If the dictionary does not yet exist create one.
			FDWeakMutableDictionary *existingModels = [_existingModelsByClass objectForKey: modelClassAsString];
			if (existingModels == nil)
			{
				existingModels = [FDWeakMutableDictionary dictionary];
				[_existingModelsByClass setValue: existingModels 
					forKey: modelClassAsString];
			}
			
			// Load the existing model instance for the identifier.
			FDModel *model = [existingModels objectForKey: identifier];
			
			// If the model does not exist create a blank instance of it with the identifier.
			if (model == nil)
			{
				// Abort if base initializer fails.
				if ((self = [super init]) == nil)
				{
					return nil;
				}
				
				self.identifier = identifier;
				
				// Because the model was just created call the initializer block.
				if (initializerBlock)
				{
					initializerBlock(self);
				}
				
				[existingModels setObject: self 
					forKey: identifier];
			}
			// Otherwise if the model already exists assign it to self and skip the super initialization.
			else
			{
				self = model;
			}
		}
	}
	// If the identifier does not exist call the base initializer.
	else if ((self = [super init]) == nil)
	{
		return nil;
	}
	
	// Because the model was just created call the initializer block.
	if (initializerBlock)
	{
		initializerBlock(self);
	}
	
	// Return initialized instance.
	return self;
}

- (instancetype)initWithIdentifier: (id)identifier
{
	// Abort if base initializer fails.
	if ((self = [self initWithIdentifier: identifier 
		initializerBlock: nil]) == nil)
	{
		return nil;
	}
	
	// Return initialized instance.
	return self;
}

- (id)initWithCoder: (NSCoder *)coder
{
	// Decode the identifier.
	id identifier = [coder decodeObjectForKey: @keypath(self.identifier)];
	
	// Abort if base initializer fails.
	self = [self initWithIdentifier: identifier 
		initializerBlock: ^(FDModel *model)
		{
			// Iterate over each declared property and attempt to decode it and set it on the model.
			NSArray *declaredProperties = [[model class] declaredPropertiesForSubclass: [FDModel class]];
			for (FDDeclaredProperty *declaredProperty in declaredProperties)
			{
				NSString *key = declaredProperty.name;
				id value = [coder decodeObjectForKey: key];
				
				@try
				{
					[model setValue: value 
						forKey: key];
				}
				// If the key on the model does not exist an exception will most likely be thrown. Catch any execeptions and log them so that any incorrect decodings will not crash the application.
				@catch (NSException *exception)
				{
					FDLog(FDLogLevelInfo, @"Could not set %@ property on %@ because %@", key, [model class], [exception reason]);
				}
			}
		}];
	
	if (self == nil)
	{
		return nil;
	}
	
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


#pragma mark - NSCoding Methods

- (void)encodeWithCoder: (NSCoder *)coder
{
	// Iterate over each declared property and encode it.
	NSArray *declaredProperties = [[self class] declaredPropertiesForSubclass: [FDModel class]];
	for (FDDeclaredProperty *declaredProperty in declaredProperties)
	{
		NSString *key = declaredProperty.name;
		id value = [self valueForKey: key];
		[coder encodeObject: value 
			forKey: key];
	}
}


@end