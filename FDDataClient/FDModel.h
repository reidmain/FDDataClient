#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface FDModel : NSObject


#pragma mark - Properties

@property (nonatomic, copy) id identifier;


#pragma mark - Constructors


#pragma mark - Static Methods

+ (NSString *)remoteKeyPathForUniqueIdentifier;
+ (NSDictionary *)remoteKeyPathsToLocalKeyPaths;
+ (NSValueTransformer *)transformerForKey: (NSString *)key;


#pragma mark - Instance Methods


@end