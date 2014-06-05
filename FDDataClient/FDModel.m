#import "FDModel.h"
#import <FDFoundationKit/FDFoundationKit.h>


#pragma mark - Class Extension

@interface FDModel ()

- (NSString *)_modelFilePathForIdentifier: (id)identifier;

@end


#pragma mark - Class Variables

static NSMutableDictionary *_existingModelsByClass;


#pragma mark - Class Definition

@implementation FDModel


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
	initBlock: (FDModelInitBlock)initBlock 
	customizationBlock: (FDModelCustomizationBlock)customizationBlock
{
	// If an identifier has been passed in check if an instance of the class with the identifier already exists.
	if (FDIsEmpty(identifier) == NO)
	{
		// Because models can be created on any create this code needs to be synchronized on the class being created to ensure that two threads can't create the same object at the same time.
		@synchronized ([self class])
		{
			NSString *modelClassAsString = NSStringFromClass([self class]);
			
			// Load the dictionary of all the existings models for the class. If the dictionary does not yet exist create it.
			FDWeakMutableDictionary *existingModels = [_existingModelsByClass objectForKey: modelClassAsString];
			if (existingModels == nil)
			{
				existingModels = [FDWeakMutableDictionary dictionary];
				[_existingModelsByClass setValue: existingModels 
					forKey: modelClassAsString];
			}
			
			// Load the existing model for the identifier.
			FDModel *model = [existingModels objectForKey: identifier];
			
			// If the model does not exist call the init block.
			if (model == nil)
			{
				if (initBlock != nil)
				{
					model = initBlock(identifier);
				}
				
				// If the model still does not exist after the init block create a blank instance of the model.
				if (model == nil)
				{
					if ((self = [super init]) == nil)
					{
						return nil;
					}
				}
				else
				{
					self = model;
				}
				
				// Ensure the identifier is set on the model.
				self.identifier = identifier;
				
				// Because the model was just created call the customization block.
				if (customizationBlock != nil)
				{
					customizationBlock(self);
				}
				
				// Store the model in the existing models dictionary to ensure that only one instance of the model will ever exist.
				[existingModels setObject: self 
					forKey: identifier];
			}
			// If the model already exists assign it to self.
			else
			{
				self = model;
			}
		}
	}
	// If there is no identifier create a blank instance of the model.
	else if ((self = [super init]) == nil)
	{
		return nil;
	}
	else	
	{
		// Because the model was just created call the customization block.
		if (customizationBlock != nil)
		{
			customizationBlock(self);
		}
	}
	
	// Return initialized instance.
	return self;
}

- (instancetype)initWithIdentifier: (id)identifier
{
	self = [self initWithIdentifier: identifier 
		initBlock: ^id (id identifier)
			{
				// If the model does not exist in memory check and see if it was saved to disk.
				FDModel *model = nil;
				
				NSString *modelFilePath = [self _modelFilePathForIdentifier: identifier];
				if (modelFilePath != nil)
				{
					model = [NSKeyedUnarchiver unarchiveObjectWithFile: modelFilePath];
				}
				
				return model;
			} 
		customizationBlock: nil];
	
	if (self == nil)
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
	
	self = [self initWithIdentifier: identifier 
		initBlock: nil 
		customizationBlock: ^(FDModel *model)
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

- (BOOL)save
{
	NSString *modelFilePath = [self _modelFilePathForIdentifier: self.identifier];
	
	BOOL saveSuccessful = [NSKeyedArchiver archiveRootObject: self 
		toFile: modelFilePath];
	
	return saveSuccessful;
}


#pragma mark - Private Methods

- (NSString *)_modelFilePathForIdentifier: (id)identifier
{
	// If no identifier was passed in a file path cannot be generated.
	if (FDIsEmpty(identifier) == YES)
	{
		return nil;
	}
	
	// Get the path for the cache directory.
	NSArray *cacheDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSAllDomainsMask, YES);
	NSString *systemCacheFolderPath = [cacheDirectories firstObject];
	NSString *cacheFolderPath = [systemCacheFolderPath stringByAppendingPathComponent: @"FDModel Cache"];
	
	// Ensure the cache directory has been created.
	NSFileManager *defaultFileManager = [NSFileManager defaultManager];
	[defaultFileManager createDirectoryAtPath: cacheFolderPath 
		withIntermediateDirectories: YES 
		attributes: nil 
		error: nil];
	
	// Concatenate the class and identifier together to ensure different classes that use the same identifier do not collide.
	NSString *fullIdentifier = [NSString stringWithFormat: @"%@-%@", 
		[self class], 
		identifier];
	
	// Hash the full identifier to ensure there are no / in the file name.
	NSString *hashedIdentifier = [fullIdentifier sha256HashString];
	
	// Create the file name for the model from the hash and append it to the cache directory path.
	NSString *modelFileName = [NSString stringWithFormat: @"%@.plist", 
		hashedIdentifier];
	NSString *modelFilePath = [cacheFolderPath stringByAppendingPathComponent: modelFileName];
	
	return modelFilePath;
}


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