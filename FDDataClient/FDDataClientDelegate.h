#import "FDModel.h"


#pragma mark Type Definitions

/**
 *  Determine which class an object should be parsed into.
 *
 *  Used to obtain the FDModel subclass for an object that should be parsed into
 *  a local object but whose response data does not have an identifer that can
 *  be used to determine the FDModel subclass automatically.
 *
 *  For most practical uses cases the values that are of interest will be
 *  NSDictionary objects, but it could be anything allowing you to do things
 *  like instantiaing placeholder objects based on a URL or an enum.
 *
 *  Return an FDModel subclass to parse the value as that kind of class. Return 
 *  Nil if something else should make that determination or if the value is fine 
 *  as it is. You can also return NSNull if you have determined that this is a 
 *  bad value and all parsing of it should halt.
 *
 *  @param parentKey  The key used to access the object in the api response.
 *  @param value      The object to be parsed.
 *
 *  @return An FDModel subclass, Nil or NSNull.
 */
typedef Class (^FDDataClientModelClassBlock)(NSString *parentKey, id value);


#pragma mark Protocol

@protocol FDDataClientDelegate<NSObject>


#pragma mark - Required Methods

@required

/**
 *  Determine which class an object should be parsed into.
 *
 *  This delegate method behaves identically to FDDataClientModelClassBlock.
 *  Where FDDataClientModelClassBlock is appropriate for individual api requests,
 *  this method is better suited for when objects are encountered multiple times
 *  or there is a single failure condition for all objects.
 *
 *  @param value The object to be parsed.
 *
 *  @return An FDModel subclass, Nil or NSNull.
 */
- (Class)modelClassForValue: (id)value;

@end