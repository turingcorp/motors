#import "appdel.h"
#import "cloudreqdel.h"

@class modprice;
@class modpricereport;

@interface modprices:NSObject<cloudreqdel>

-(NSInteger)count;
-(void)add:(modprice*)_price;
-(modprice*)price:(NSInteger)_index;
-(void)pull;

@property(strong, nonatomic)modprice *prevselected;
@property(copy, nonatomic)NSString *error;
@property(nonatomic)BOOL leaf;

@end

@interface modprice:NSObject

-(modprice*)init:(NSString*)_catid name:(NSString*)_name qty:(NSInteger)_qty;

@property(strong, nonatomic)modpricereport *report;
@property(copy, nonatomic)NSString *name;
@property(copy, nonatomic)NSString *catid;
@property(copy, nonatomic)NSString *filter;
@property(nonatomic)NSInteger qty;

@end

@interface modpricereport:NSObject

@property(nonatomic)double min;
@property(nonatomic)double max;

@end