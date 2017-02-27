#import "spinner.h"

@implementation spinner

-(spinner*)init:(NSInteger)_x y:(NSInteger)_y
{
    self = [super initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self setClipsToBounds:YES];
    [self setUserInteractionEnabled:NO];
    [self setCenter:CGPointMake(_x, _y)];
    [self setContentMode:UIViewContentModeCenter];
    [self setAnimationDuration:1];
    [self setAnimationImages:@[[UIImage imageNamed:@"loader1"], [UIImage imageNamed:@"loader2"], [UIImage imageNamed:@"loader3"], [UIImage imageNamed:@"loader4"], [UIImage imageNamed:@"loader5"], [UIImage imageNamed:@"loader6"], [UIImage imageNamed:@"loader7"], [UIImage imageNamed:@"loader8"]]];
    [self startAnimating];
    
    return self;
}

-(void)dealloc
{
    [self stopAnimating];
}

#pragma mark public

-(void)stop
{
    [self removeFromSuperview];
}

@end