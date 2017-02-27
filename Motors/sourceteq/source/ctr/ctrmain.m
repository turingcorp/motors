#import "ctrmain.h"

@implementation ctrmain
{
    UIStatusBarStyle barstyle;
    BOOL barhidden;
}

+(ctrmain*)sha
{
    static ctrmain *sha;
    static dispatch_once_t once;
    dispatch_once(&once, ^(void) { sha = [[self alloc] init]; });
    return sha;
}

-(ctrmain*)init
{
    self = [super init];
    
    barstyle = UIStatusBarStyleDefault;
    barhidden = NO;
    
    return self;
}

-(void)loadView
{
    self.view = [vimaster sha];
}
 
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return barstyle;
}

-(BOOL)prefersStatusBarHidden
{
    return barhidden;
}

#pragma mark public

-(void)statusbarlight
{
    barstyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)statusbardark
{
    barstyle = UIStatusBarStyleDefault;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)statusbarhide
{
    barhidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)statusbarshow
{
    barhidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

@end