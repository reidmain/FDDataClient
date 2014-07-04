#import <FDFoundationKit/FDFoundationKit.h>
#import "FDModelStore.h"

#ifndef LOG_UNUSED_REMOTE_KEYS
    #define LOG_UNUSED_REMOTE_KEYS 0
#endif

#ifndef LOG_MISSING_EXPECTED_KEYS
    #define LOG_MISSING_EXPECTED_KEYS 0
#endif

#pragma mark Type Definitions

typedef id (^FDModelInitBlock)(id identifier);
typedef void (^FDModelCustomizationBlock)(FDModel *model);


#pragma mark - Class Interface

@interface FDModel : NSObject<
	NSCoding>


#pragma mark - Properties

@property (nonatomic, copy) id identifier;


#pragma mark - Constructors

+ (instancetype)modelWithIdentifier: (id)identifier;
- (instancetype)initWithIdentifier: (id)identifier 
	initBlock: (FDModelInitBlock)initBlock 
	customizationBlock: (FDModelCustomizationBlock)initializerBlock;
- (instancetype)initWithIdentifier: (id)identifier;


#pragma mark - Static Methods

+ (NSString *)remoteKeyPathForUniqueIdentifier;
+ (NSDictionary *)remoteKeyPathsToLocalKeyPaths;
+ (NSValueTransformer *)transformerForKey: (NSString *)key;
// The class returned from this method must be a subclass of FDModel.
+ (Class)modelClassForDictionary: (NSDictionary *)dictionary 
	withRemoteKeyPath: (NSString *)remoteKeyPath;

+ (void)setModelStore: (FDModelStore *)modelStore;


#pragma mark - Instance Methods

- (BOOL)save;


#pragma mark - Debug Methods
/**
 *  Validates a response object against the expected reponse and logs the 
 *  difference. Useful for identifying missing and unused keys.
 *
 *
 *  @param remoteObject An response object to validate against the expect response.
 */
+ (void)_validateAndLogRemoteObject: (NSDictionary *)remoteObject;

@end