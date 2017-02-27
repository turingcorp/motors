#import "ctralert.h"

@implementation ctralert
{
    NSTimer *timer;
    CGRect rectmain;
}

+(void)alert:(NSString*)_message
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notclosealert object:nil];

    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [[ctrmain sha].view.superview insertSubview:[[ctralert alloc] init:_message] atIndex:0];
                   });
}

-(ctralert*)init:(NSString*)_message
{
    self = [super init];
    [self setBackgroundColor:colormain];
    [self setClipsToBounds:YES];
    
    UIFont *font = [UIFont fontWithName:fontname size:18];
    
    NSInteger width = screenwidth - 40;
    NSInteger height = ceilf([_message boundingRectWithSize:CGSizeMake(width, 200) options:stringdrawing attributes:@{NSFontAttributeName:font} context:nil].size.height);
    NSInteger heighttot = height + 38;
    [self setFrame:CGRectMake(0, 0, screenwidth, heighttot)];
    rectmain = CGRectMake(0, heighttot, screenwidth, screenheight - heighttot);
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 28, width, height)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setFont:font];
    [lbl setNumberOfLines:0];
    [lbl setTextColor:[UIColor blackColor]];
    [lbl setText:_message];
    [lbl setUserInteractionEnabled:NO];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:self.bounds];
    [btn addTarget:self action:@selector(closealert) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, heighttot - 1, screenwidth, 1)];
    [border setBackgroundColor:[UIColor blackColor]];
    [border setUserInteractionEnabled:NO];
    
    [self addSubview:border];
    [self addSubview:lbl];
    [self addSubview:btn];
    [self showalert];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedclosealert) name:notclosealert object:nil];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark notifications

-(void)notifiedclosealert
{
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [self closealert];
                   });
}

#pragma mark functionality

-(void)showalert
{
    [UIView animateWithDuration:0.3 animations:
     ^(void)
     {
         [[ctrmain sha].view setFrame:rectmain];
     } completion:
     ^(BOOL _done)
     {
         timer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(closealert) userInfo:nil repeats:NO];
     }];
}

-(void)closealert
{
    [timer invalidate];
    
    [UIView animateWithDuration:0.25 animations:
     ^(void)
     {
         [[ctrmain sha].view setFrame:screenrect];
     } completion:
     ^(BOOL _done)
     {
         [self removeFromSuperview];
     }];
}

@end