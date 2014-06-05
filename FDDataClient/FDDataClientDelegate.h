#import "FDModel.h"


#pragma mark Protocol

@protocol FDDataClientDelegate<NSObject>


#pragma mark - Required Methods

@required

// The class returned from this method must be a subclass of FDModel. If NSNull is returned the identifier will be ignored.
- (Class)modelClassForIdentifier: (id)identifier;


@end