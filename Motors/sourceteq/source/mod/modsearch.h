#import "appdel.h"
#import "cloudreqdel.h"

@class modsearchresult;
@class moditem;
@class moditempicture;
@class modinitem;
@class modfilters;

@interface modsearch:NSObject<cloudreqdel>

-(void)retry;
-(NSInteger)count;
-(modsearchresult*)searchresult:(NSInteger)_index;
-(void)pull;
-(void)selectresult:(NSInteger)_index;
-(void)remove:(modsearchresult*)_result;

@property(weak, nonatomic)modsearchresult *resultselected;
@property(strong, nonatomic)modfilters *filters;
@property(nonatomic)NSInteger totalitems;
@property(nonatomic)NSInteger loadeditems;
@property(nonatomic)NSInteger indexselected;
@property(nonatomic)BOOL poolable;

@end

@interface modsearchresult:NSObject<cloudreqdel>

-(modsearchresult*)init;
-(void)getitem;
-(void)changetitle:(NSString*)_title price:(NSString*)_price address:(NSString*)_address;
-(void)changeimage:(NSString*)_image;
-(NSDictionary*)userinfo;
-(BOOL)equalsuserinfo:(NSDictionary*)_userinfo;

@property(weak, nonatomic)modinitem *initem;
@property(strong, nonatomic)moditem *item;
@property(strong, nonatomic)moditempicture *picture;
@property(copy, nonatomic)NSString *itemid;
@property(copy, nonatomic)NSString *title;
@property(copy, nonatomic)NSString *price;
@property(copy, nonatomic)NSString *address;
@property(copy, nonatomic)NSString *sellerareacode;
@property(copy, nonatomic)NSString *sellerphone;
@property(copy, nonatomic)NSAttributedString *attr;

@end