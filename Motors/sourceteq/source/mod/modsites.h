#import "appdel.h"

@class modsite;

@interface modsites:NSObject

+(modsites*)sha;
-(NSInteger)count;
-(modsite*)site:(NSInteger)_index;
-(NSInteger)siteforname:(NSString*)_sitename;
-(modsite*)siteforid:(NSInteger)_siteid;

@end


@interface modsite:NSObject

-(modsite*)init:(NSString*)_identifier name:(NSString*)_name siteid:(NSInteger)_siteid;

@property(copy, nonatomic)NSString *identifier;
@property(copy, nonatomic)NSString *name;
@property(nonatomic)NSInteger siteid;

@end