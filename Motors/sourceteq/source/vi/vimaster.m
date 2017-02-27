#import "vimaster.h"

@implementation vimaster
{
    CGRect rectbar;
}

@synthesize loca;
@synthesize spin;
@synthesize bar;
@synthesize menu;
@synthesize menumask;
@synthesize content;
@synthesize contentinner;
@synthesize section;
@synthesize barstate;
@synthesize menustate;

+(vimaster*)sha
{
    static vimaster *sha;
    static dispatch_once_t once;
    dispatch_once(&once, ^(void) { sha = [[self alloc] init]; });
    return sha;
}

-(vimaster*)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    [self setBackgroundColor:colormain];
    [self setClipsToBounds:YES];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    spinner *strongspin = [[spinner alloc] init:self.center.x y:self.center.y];
    spin = strongspin;
    
    [self addSubview:spin];
    
    return self;
}

#pragma mark actions

-(void)actionclosemenu
{
    [self hidemenu];
}

#pragma mark functionality

-(void)configsection:(UIView*)_view
{
    contentinner = _view;
    [content insertSubview:contentinner atIndex:0];
}

-(void)configsearch
{
    [self configsection:[[visearchman alloc] initWithFrame:content.bounds]];
}

-(void)configfavorites
{
    [self configsection:[[vifavorites alloc] initWithFrame:content.bounds]];
}

-(void)configprices
{
    [self configsection:[[viprices alloc] initWithFrame:content.bounds]];
}

-(void)configsettings
{
    [self configsection:[[visettings alloc] initWithFrame:content.bounds]];
}

-(void)configstore
{
    [self configsection:[[vistore alloc] initWithFrame:content.bounds]];
}

-(void)showbar
{
    [UIView animateWithDuration:0.4 animations:
     ^(void)
     {
         [bar setFrame:bar.rectshown];
         [content setFrame:rectbar];
     }];
}

-(void)hidebar
{
    [UIView animateWithDuration:0.4 animations:
     ^(void)
     {
         [bar setFrame:bar.recthidden];
         [content setFrame:screenrect];
     }];
}

#pragma mark public

-(void)firstload
{
    loca = nil;
    [spin removeFromSuperview];
    [self setBackgroundColor:[UIColor whiteColor]];
    menustate = appmenustatehide;
    rectbar = CGRectMake(0, barheight, screenwidth, screenheight - barheight);
    section = appsectionsettings;
    
    UIView *strongcontent = [[UIView alloc] initWithFrame:rectbar];
    content = strongcontent;
    [content setClipsToBounds:YES];
    [content setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    vibar *strongbar = [[vibar alloc] init];
    bar = strongbar;
    
    vimenu *strongmenu = [[vimenu alloc] init];
    menu = strongmenu;
    
    UIView *strongmenumask = [[UIView alloc] initWithFrame:screenrect];
    menumask = strongmenumask;
    
    if(applicationios == ioslevel7)
    {
        [menumask setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.95]];
    }
    else
    {
        UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        [blur setFrame:menumask.bounds];
        [blur setUserInteractionEnabled:NO];
        
        [menumask addSubview:blur];
    }
    UIButton *btnmask = [[UIButton alloc] initWithFrame:menumask.bounds];
    [btnmask addTarget:self action:@selector(actionclosemenu) forControlEvents:UIControlEventTouchUpInside];
    [btnmask setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [menumask addSubview:btnmask];
    [menumask setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [menumask setAlpha:0];
    
    [self addSubview:menu];
    [self addSubview:content];
    [self addSubview:bar];
    [self addSubview:menumask];
    [self opensection:appsectionsearch];
}

-(void)opensection:(appsection)_section
{
    if(section != _section)
    {
        [contentinner removeFromSuperview];
        section = _section;
        NSString *title;
        
        switch(section)
        {
            case appsectionsearch:
                
                title = @"";
                [bar hidefavmenu];
                [bar showfiltermenu];
                [self configsearch];
                
                break;
                
            case appsectionfavorites:
                
                title = @"";
                [bar showfavmenu];
                [bar hidefiltermenu];
                [self configfavorites];
                
                break;
                
            case appsectionpricesguide:
                
                title = NSLocalizedString(@"prices_title", nil);
                [bar hidefavmenu];
                [bar hidefiltermenu];
                [self configprices];
                
                break;
                
            case appsectionsettings:
                
                title = NSLocalizedString(@"settings_title", nil);
                [bar hidefavmenu];
                [bar hidefiltermenu];
                [self configsettings];
                
                break;
                
            case appsectionstore:
                
                title = NSLocalizedString(@"store_title", nil);
                [bar hidefavmenu];
                [bar hidefiltermenu];
                [self configstore];
                
                break;
                
            default:break;
        }
        
        [menu opensection:_section];
        [bar configtitle:title];
    }
}

-(void)changebar:(appbarstate)_barstate
{
    barstate = _barstate;
    
    switch(barstate)
    {
        case appbarstateshown:
            
            [self showbar];
            
            break;
            
        case appbarstatehide:
            
            [self hidebar];
            
            break;
    }
}

-(void)showmenu
{
    menustate = appmenustateshown;
    CGRect rect = CGRectMake(menuwidth, content.frame.origin.y, content.bounds.size.width, content.bounds.size.height);
    CGRect newrectbar = CGRectMake(menuwidth, bar.frame.origin.y, bar.bounds.size.width, bar.bounds.size.height);
    CGRect rectmask = CGRectMake(menuwidth, 0, screenwidth, screenheight);
    
    [[ctrmain sha] statusbarlight];
    
    [UIView animateWithDuration:0.35 animations:
     ^(void)
     {
         [content setFrame:rect];
         [bar setFrame:newrectbar];
         [menumask setAlpha:1];
         [menumask setFrame:rectmask];
     }];
}

-(void)hidemenu
{
    menustate = appmenustatehide;
    CGRect rect = CGRectMake(0, content.frame.origin.y, content.bounds.size.width, content.bounds.size.height);
    CGRect newrectbar = CGRectMake(0, bar.frame.origin.y, bar.bounds.size.width, bar.bounds.size.height);
    
    [UIView animateWithDuration:0.3 animations:
     ^(void)
     {
         [content setFrame:rect];
         [bar setFrame:newrectbar];
         [menumask setAlpha:0];
         [menumask setFrame:screenrect];
     } completion:
     ^(BOOL _done)
     {
         [[ctrmain sha] statusbardark];
     }];
}

@end
