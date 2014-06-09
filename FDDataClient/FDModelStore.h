#pragma mark Forward Declarations

@class FDModel;


#pragma mark - Class Interface

// NOTE: This is an abstract class.
@interface FDModelStore : NSObject


#pragma mark - Instance Methods

- (FDModel *)modelForIdentifier: (id)identifier;
- (BOOL)saveModel: (FDModel *)model;


@end