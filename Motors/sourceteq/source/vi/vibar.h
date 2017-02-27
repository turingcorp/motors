#import "appdel.h"

@class vifavoritesmenu;
@class vifilterbar;

@interface vibar:UIView

-(void)configtitle:(NSString*)_newtitle;
-(void)showfavmenu;
-(void)hidefavmenu;
-(void)showfiltermenu;
-(void)hidefiltermenu;

@property(weak, nonatomic)vifavoritesmenu *favorites;
@property(weak, nonatomic)vifilterbar *filterbar;
@property(weak, nonatomic)UILabel *lbltitle;
@property(weak, nonatomic)UIButton *btnleft;
@property(weak, nonatomic)UIButton *btnright;
@property(nonatomic)CGRect rectshown;
@property(nonatomic)CGRect recthidden;

@end