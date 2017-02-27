#import "appdel.h"

@class modsite;

@interface modsettings:NSObject<UIAlertViewDelegate>

+(modsettings*)sha;
-(void)changecountry:(NSInteger)_index;
-(void)loadpreferences;
-(void)savepreferences;
-(void)editquery:(NSString*)_newquery;
-(BOOL)shouldpricesguide;

@property(weak, nonatomic)modsite *site;
@property(strong, nonatomic)NSDictionary *perks;
@property(copy, nonatomic)NSString *uuid;
@property(copy, nonatomic)NSString *appid;
@property(copy, nonatomic)NSString *searchquery;
@property(nonatomic)NSInteger siteindex;
@property(nonatomic)NSInteger lastpricesguide;

@end