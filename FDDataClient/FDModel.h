#pragma mark Protocol Defintion

@protocol FDModel <NSObject>

+ (NSDictionary *)remoteKeyPathsToLocalKeyPaths;

@end


#pragma mark Constants


#pragma mark - Enumerations


#pragma mark - Class Interface

@interface FDModel : NSObject<
	FDModel>


#pragma mark - Properties


#pragma mark - Constructors


#pragma mark - Static Methods

+ (NSDictionary *)remoteKeyPathsToLocalKeyPaths;


#pragma mark - Instance Methods


@end