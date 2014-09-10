#import "FDModel.h"


#pragma mark Type Definitions

/**
This block is used to determine which FDModel subclass an object should be parsed into.

The majority of the time the value will be an NSDictionary object with NSString and NSValue being the next most common objects. NSDictionary is the most common because they are the objects that normally map one-to-one with a subclass of FDModel. Instances of NSString or NSValue usually reference an instance of an FDModel subclass that already exists in memory.
 
@param parentKey The key of a key-value pair within a NSDictionary if the object being parsed is an entry in a dictionary or if the entry in the dictionary is an array which contains the object being parsed.
@param value The object to be parsed.

@return Returns a FDModel subclass if the value can be parsed into an instance of that subclass. Return nil if the value does not map to a FDModel subclass. Return NSNull if the value is 'invalid' or 'bad' in some way and should not be parsed at all.
*/
typedef Class (^FDModelProviderModelClassBlock)(NSString *parentKey, id value);


#pragma mark - Class Interface

@interface FDModelProvider : NSObject


#pragma mark - Properties

/**
The data formatter to use whenever the model provider is attempting to set an instance of NSString on a property whose type is NSDate.
*/
@property (nonatomic, strong) NSDateFormatter *dateFormatter;


#pragma mark - Static Methods

+ (FDModelProvider *)sharedInstance;


#pragma mark - Instance Methods

- (id)parseObject: (id)object 
	modelClassBlock: (FDModelProviderModelClassBlock)modelClassBlock;

@end