#import "appdel.h"

@interface tools:NSObject

+(tools*)sha;
+(void)dataexport:(NSArray*)_array view:(UIView*)_view;
+(void)rateapp;
+(NSDictionary*)defaultdict;
+(NSInteger)timestamp;
+(NSString*)parsestring:(id)_value;
+(NSString*)parsestringvalid:(id)_value;
+(NSNumber*)parsenum:(id)_value;
+(BOOL)notnullorempty:(id)_value;
-(NSString*)urlencode:(NSString*)_string;
-(NSString*)numbertostring:(NSNumber*)_number;
-(NSNumber*)numberfromstring:(NSString*)_string;
-(NSString*)pricetostring:(NSNumber*)_number;
-(NSString*)pricetostringusd:(NSNumber*)_number;
-(NSAttributedString*)resultstring:(NSString*)_title price:(NSString*)_price address:(NSString*)_address;
-(NSDate*)stringtodate:(NSString*)_string;

@property(strong, nonatomic)CMMotionManager *motion;
@property(strong, nonatomic)NSComparator comparerfilter;

@end