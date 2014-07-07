#import <FDFoundationKit/FDFoundationKit.h>
#import "FDModelStore.h"


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


@end