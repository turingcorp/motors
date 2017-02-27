#import "appdel.h"

@class modsite;
@class moditempictures;
@class moditempicture;
@class moditemlocation;
@class moditemcontact;
@class moditemattributes;
@class moditemattribute;

@interface moditem:NSObject

@property(weak, nonatomic)modsite *site;
@property(strong, nonatomic)moditempictures *pictures;
@property(strong, nonatomic)moditemlocation *location;
@property(strong, nonatomic)moditemcontact *contact;
@property(strong, nonatomic)moditemattributes *attributes;
@property(strong, nonatomic)NSDate *datepublished;
@property(copy, nonatomic)NSString *itemid;
@property(copy, nonatomic)NSString *title;
@property(copy, nonatomic)NSString *descr;
@property(copy, nonatomic)NSString *sellerid;
@property(copy, nonatomic)NSString *categoryid;
@property(copy, nonatomic)NSString *currencyid;
@property(copy, nonatomic)NSNumber *price;

@end

@interface moditempictures:NSObject

-(NSInteger)count;
-(void)add:(moditempicture*)_picture;
-(moditempicture*)picture:(NSInteger)_index;

@end

@interface moditempicture:NSObject

+(moditempicture*)parse:(NSNotification*)_notification;
-(moditempicture*)init:(NSString*)_url;
-(NSDictionary*)userinfo;
-(BOOL)equalsuserinfo:(NSDictionary*)_userinfo;

@property(copy, nonatomic)NSString *url;
@property(strong, nonatomic)UIImage *image;

@end

@interface moditemlocation:NSObject

@property(copy, nonatomic)NSString *addressline;
@property(copy, nonatomic)NSString *zipcode;
@property(copy, nonatomic)NSString *neightbourhood;
@property(copy, nonatomic)NSString *city;
@property(copy, nonatomic)NSString *state;
@property(copy, nonatomic)NSString *country;
@property(nonatomic)CGFloat latitude;
@property(nonatomic)CGFloat longitude;

@end

@interface moditemcontact:NSObject

-(void)call;
-(void)write;

@property(copy, nonatomic)NSString *name;
@property(copy, nonatomic)NSString *openhours;
@property(copy, nonatomic)NSString *areacode;
@property(copy, nonatomic)NSString *phone;
@property(copy, nonatomic)NSString *email;

@end

@interface moditemattributes:NSObject

-(NSInteger)count;
-(moditemattribute*)attribute:(NSInteger)_index;
-(void)add:(moditemattribute*)_attribute;
-(void)prepend:(moditemattribute*)_attribute;
-(void)insertafternum:(moditemattribute*)_attribute;

@end

@interface moditemattribute:NSObject

@end

@interface moditemattributesimple:moditemattribute

@property(copy, nonatomic)NSString *title;

@end

@interface moditemattributecomplex:moditemattribute

@property(copy, nonatomic)NSString *name;
@property(copy, nonatomic)NSString *value;

@end

@interface moditemattributenum:moditemattribute

@property(copy, nonatomic)NSString *name;
@property(copy, nonatomic)NSNumber *value;

@end