#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface FDModel : NSObject


#pragma mark - Properties

@property (nonatomic, copy) id identifier;


#pragma mark - Constructors


#pragma mark - Static Methods

+ (NSDictionary *)remoteKeyPathsToLocalKeyPaths;
+ (NSString *)remoteKeyPathForUniqueIdentifier;
+ (NSValueTransformer *)transformerForKey: (NSString *)key;


#pragma mark - Instance Methods


@end