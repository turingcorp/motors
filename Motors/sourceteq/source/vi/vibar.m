#import "vibar.h"

@implementation vibar
{
    NSInteger contentheight;
}

@synthesize favorites;
@synthesize filterbar;
@synthesize lbltitle;
@synthesize btnleft;
@synthesize btnright;
@synthesize rectshown;
@synthesize recthidden;

-(vibar*)init
{
    self = [super initWithFrame:CGRectMake(0, 0, screenwidth, barheight)];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:colormain];

    rectshown = self.bounds;
    recthidden = CGRectMake(0, 0, screenwidth, 0);
    contentheight = barheight - 20;
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, barheight - 1, screenwidth, 1)];
    [border setUserInteractionEnabled:NO];
    [border setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.6]];
    [border setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    
    UIButton *strongbtnleft = [[UIButton alloc] initWithFrame:CGRectMake(-10, 20, 70, contentheight)];
    btnleft = strongbtnleft;
    [btnleft setImage:[[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [btnleft setImage:[[UIImage imageNamed:@"menu"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    [btnleft.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnleft.imageView setClipsToBounds:YES];
    [btnleft.imageView setTintColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [btnleft addTarget:self action:@selector(actionleft) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *stronglbltitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, screenwidth, contentheight)];
    lbltitle = stronglbltitle;
    [lbltitle setBackgroundColor:[UIColor clearColor]];
    [lbltitle setFont:[UIFont fontWithName:fontboldname size:18]];
    [lbltitle setTextAlignment:NSTextAlignmentCenter];
    [lbltitle setUserInteractionEnabled:NO];
    [lbltitle setTextColor:[UIColor blackColor]];
    
    [self addSubview:lbltitle];
    [self addSubview:border];
    [self addSubview:btnleft];
    
    return self;
}

#pragma mark actions

-(void)actionleft
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    switch([vimaster sha].menustate)
    {
        case appmenustatehide:
            
            [[vimaster sha] showmenu];
            
            break;
            
        case appmenustateshown:
            
            [[vimaster sha] hidemenu];
            
            break;
    }
}

#pragma mark public

-(void)configtitle:(NSString*)_newtitle
{
    [lbltitle setText:_newtitle];
}

-(void)showfavmenu
{
    vifavoritesmenu *strongfavorites = [[vifavoritesmenu alloc] initWithFrame:CGRectMake(screenwidth_2 - 45, 20, 90, contentheight)];
    favorites = strongfavorites;
    
    [self addSubview:favorites];
}

-(void)hidefavmenu
{
    [favorites removeFromSuperview];
}

-(void)showfiltermenu
{
    vifilterbar *strongfilterbar = [[vifilterbar alloc] init];
    filterbar = strongfilterbar;
    
    [self insertSubview:filterbar belowSubview:btnleft];
}

-(void)hidefiltermenu
{
    [filterbar removeFromSuperview];
}

@end