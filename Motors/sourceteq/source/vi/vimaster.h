#import "appdel.h"

@class vibar;
@class vimenu;
@class spinner;
@class locater;

@interface vimaster:UIView

+(vimaster*)sha;
-(void)firstload;
-(void)opensection:(appsection)_section;
-(void)changebar:(appbarstate)_barstate;
-(void)showmenu;
-(void)hidemenu;

@property(strong, nonatomic)locater *loca;
@property(weak, nonatomic)spinner *spin;
@property(weak, nonatomic)vibar *bar;
@property(weak, nonatomic)vimenu *menu;
@property(weak, nonatomic)UIView *menumask;
@property(weak, nonatomic)UIView *content;
@property(weak, nonatomic)UIView *contentinner;
@property(nonatomic)appsection section;
@property(nonatomic)appbarstate barstate;
@property(nonatomic)appmenustate menustate;

@end