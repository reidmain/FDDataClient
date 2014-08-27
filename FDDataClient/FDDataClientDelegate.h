#import "FDModel.h"


#pragma mark Type Definitions

/**
Determines which class an object should be parsed into.

This block is used to determine which FDModel subclass an object should be parsed into.

The majority of the time the value will be an NSDictionary object followed by NSString or NSValue. NSDictionary is the most common because they are the objects that normally map one-to-one with a subclass of FDModel. Instances of NSString or NSValue usually reference a instance of an FDModel subclass that already exists in memory.
 
@param parentKey The key of a key-value pair within a NSDictionary if the object being parsed is an entry in a dictionary or if the entry in the dictionary is an array which contains the object being parsed.
@param value The object to be parsed.

@return Return a FDModel subclass if the value can be parsed into an instance of that subclass. Return nil if the value does not map to a FDModel subclass. Return NSNull if the value is 'invalid' or 'bad' in some way and should not be parsed at all.
*/
typedef Class (^FDDataClientModelClassBlock)(NSString *parentKey, id value);


#pragma mark - Protocol

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