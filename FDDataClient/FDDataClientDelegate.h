#import "FDModel.h"


#pragma mark Forward Declarations


#pragma mark - Protocol

@protocol FDDataClientDelegate<NSObject>


#pragma mark - Required Methods

@required

- (Class<FDModel>)modelClassForDictionary: (NSDictionary *)dictionary;


#pragma mark - Optional Methods

@optional


@end