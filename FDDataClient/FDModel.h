#pragma mark Forward Declarations

@class FDModel;


#pragma mark - Constants


#pragma mark - Type Definitions

typedef void (^FDModelInitializerBlock)(FDModel *model);


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface FDModel : NSObject<
	NSCoding>


#pragma mark - Properties

@property (nonatomic, copy) id identifier;


#pragma mark - Constructors

+ (instancetype)modelWithIdentifier: (id)identifier;
- (instancetype)initWithIdentifier: (id)identifier 
	initializerBlock: (FDModelInitializerBlock)initializerBlock;
- (instancetype)initWithIdentifier: (id)identifier;


#pragma mark - Static Methods

+ (NSString *)remoteKeyPathForUniqueIdentifier;
+ (NSDictionary *)remoteKeyPathsToLocalKeyPaths;
+ (NSValueTransformer *)transformerForKey: (NSString *)key;
// The class returned from this method must be a subclass of FDModel.
+ (Class)modelClassForDictionary: (NSDictionary *)dictionary 
	withRemoteKeyPath: (NSString *)remoteKeyPath;


#pragma mark - Instance Methods


@end