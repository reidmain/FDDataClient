#import "FDModel.h"


#pragma mark Protocol

@protocol FDDataClientDelegate<NSObject>


#pragma mark - Required Methods

@required

/**
Asks the delegate which class an object should be parsed into.

The method behaves almost identically to FDDataClientModelClassBlock whereas the block is usually scoped to a specific request this delegate method is more appropriate for objects that are encountered multiple times and can be typed without having any knowledge about what request is taking place.

@param value The object to be parsed.

@return Return a FDModel subclass if the value can be parsed into an instance of that subclass. Return nil if the value does not map to a FDModel subclass. Return NSNull if the value is 'invalid' or 'bad' in some way and should not be parsed at all.

@see FDDataClientModelClassBlock
*/
- (Class)modelClassForValue: (id)value;

@end