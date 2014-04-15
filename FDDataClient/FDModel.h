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
// The class returned from this method must be a subclass of FDModel.
+ (Class)modelClassForDictionary: (NSDictionary *)dictionary 
	withRemoteKeyPath: (NSString *)remoteKeyPath;


#pragma mark - Instance Methods


@end