#import "appdel.h"

@class modperkelement;

@interface modperks:NSObject

+(modperks*)sha;
-(void)refresh;
-(void)loadperk:(SKProduct*)_product;
-(NSInteger)count;
-(modperkelement*)perk:(NSInteger)_index;
-(void)productpurchased:(NSString*)_productid;
-(void)productpurchasing:(NSString*)_productid;
-(void)productdeferred:(NSString*)_productid;
-(void)productcanceled:(NSString*)_productid;
-(NSDictionary*)asdictionary;
-(NSSet*)asaset;
-(BOOL)buyed:(NSString*)_perkid;

@end

@interface modperkelement:NSObject

-(void)purchase;

@property(strong, nonatomic)SKProduct *skproduct;
@property(copy, nonatomic)NSString *prodid;
@property(copy, nonatomic)NSString *title;
@property(copy, nonatomic)NSString *descr;
@property(copy, nonatomic)NSString *pricestr;
@property(nonatomic)perkstatus status;

@end