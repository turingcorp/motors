#import "picturer.h"

@implementation picturer
{
    NSTimer *timer;
    CGRect rectinitial;
    CGFloat rwidth;
    CGFloat rheight;
    CGFloat maxx;
    CGFloat rx;
    CGFloat delta;
    CGFloat maxtilt;
    CGFloat maxtilt2;
}

@synthesize slider;
@synthesize baseview;
@synthesize image;

+(void)open:(UIImageView*)_image
{
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [[vimaster sha] addSubview:[[picturer alloc] init:_image image:_image.image]];
                   });
}

+(void)open:(UIImageView*)_image real:(UIImage*)_realimage
{
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [[vimaster sha] addSubview:[[picturer alloc] init:_image image:_realimage]];
                   });
}

-(picturer*)init:(UIImageView*)_image image:(UIImage*)_realimage
{
    self = [super initWithFrame:screenrect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    maxtilt = 0.2;
    maxtilt2 = maxtilt * 2;
    rectinitial = [_image.superview convertRect:_image.frame toView:[UIApplication sharedApplication].keyWindow];
    
    UIView *strongbaseview = [[UIView alloc] initWithFrame:screenrect];
    baseview = strongbaseview;
    [baseview setUserInteractionEnabled:NO];
    [baseview setClipsToBounds:YES];
    [baseview setAlpha:0];
    
    if(applicationios != ioslevel7)
    {
        UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        [blur setFrame:screenrect];
        [baseview addSubview:blur];
    }
    else
    {
        [baseview setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.9]];
    }
    
    UIImageView *strongimage = [[UIImageView alloc] initWithFrame:rectinitial];
    image = strongimage;
    [image setClipsToBounds:YES];
    [image setBackgroundColor:[UIColor blackColor]];
    [image setUserInteractionEnabled:NO];
    [image setContentMode:UIViewContentModeScaleAspectFit];
    [image setImage:_realimage];
    [image.layer setBorderWidth:1];
    [image.layer setBorderColor:[UIColor blackColor].CGColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:screenrect];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn addTarget:self action:@selector(animateclose) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notimagedetailclose object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedclosepicturesdetail) name:notimagedetailclose object:nil];
    
    [self addSubview:baseview];
    [self addSubview:image];
    [self addSubview:btn];
    
    [self animateopen];
    
    return self;
}

-(void)dealloc
{
    [timer invalidate];
    [[tools sha].motion stopAccelerometerUpdates];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark notifications

-(void)notifiedclosepicturesdetail
{
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [self animateclose];
                   });
}

#pragma mark functionality

-(void)tick
{
    CGFloat xacc;
    
    switch(applicationtype)
    {
        case apptypepad:
            
            xacc = [tools sha].motion.accelerometerData.acceleration.y;
            
            break;
            
        case apptypephone:
            
            xacc = [tools sha].motion.accelerometerData.acceleration.x;
            
            break;
    }
    
    if(xacc > 0)
    {
        if(xacc > maxtilt)
        {
            xacc = maxtilt;
        }
    }
    else if(xacc < 0)
    {
        if(xacc < -maxtilt)
        {
            xacc = -maxtilt;
        }
    }
    
    CGFloat newx = -(maxx + (xacc * delta));
    CGRect rect = CGRectMake(newx, 0, rwidth, rheight);
    CGFloat updtval = (xacc + maxtilt) / maxtilt2;
    
    [UIView animateWithDuration:1 animations:
     ^(void)
     {
         [image setFrame:rect];
         [slider update:updtval];
     }];
}

#pragma mark animations

-(void)animateopen
{
    BOOL accelerometer = NO;
    CGRect maxrect;
    CGFloat imagewidth = image.image.size.width;
    CGFloat imageheight = image.image.size.height;
    CGFloat ratio = imageheight / screenheight;
    rwidth = imagewidth / ratio;
    
    if(rwidth > screenwidth)
    {
        rheight = imageheight / ratio;
        maxx = (rwidth - screenwidth) / 2.0;
        rx = -maxx;
        delta = maxx / maxtilt;
        maxrect = CGRectMake(rx, 0, rwidth, rheight);
        accelerometer = YES;
    }
    else
    {
        maxrect = screenrect;
    }
    
    [UIView animateWithDuration:0.4 animations:
     ^(void)
     {
         [image setFrame:maxrect];
         [baseview setAlpha:1];
     } completion:
     ^(BOOL _done)
     {
         if(accelerometer)
         {
             picturerslider *strongslider = [[picturerslider alloc] init];
             slider = strongslider;
             
             [self addSubview:slider];
             
             if(![tools sha].motion)
             {
                 [tools sha].motion = [[CMMotionManager alloc] init];
             }
             
             [[tools sha].motion startAccelerometerUpdates];
             timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(tick) userInfo:nil repeats:YES];
         }
     }];
}

-(void)animateclose
{
    [timer invalidate];
    [slider removeFromSuperview];
    
    [UIView animateWithDuration:0.3 animations:
     ^(void)
     {
         [baseview setAlpha:0];
         [image setFrame:rectinitial];
     } completion:
     ^(BOOL _done)
     {
         [self removeFromSuperview];
     }];
}

@end

@implementation picturerslider

@synthesize indicator;

-(picturerslider*)init
{
    self = [super initWithFrame:CGRectMake((screenwidth - 150)/ 2, screenheight - 36, 150, 8)];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.3]];
    [self setUserInteractionEnabled:NO];
    [self.layer setCornerRadius:4];
    [self.layer setBorderWidth:1];
    [self.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.05].CGColor];
    
    UIView *strongindicator = [[UIView alloc] initWithFrame:CGRectMake(35, 1, 80, 6)];
    indicator = strongindicator;
    [indicator setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.4]];
    [indicator setClipsToBounds:YES];
    [indicator.layer setCornerRadius:3];
    
    [self addSubview:indicator];
    
    return self;
}

#pragma mark public

-(void)update:(CGFloat)_delta
{
    [indicator setFrame:CGRectMake(70 * _delta, 1, 80, 6)];
}

@end