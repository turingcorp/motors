#import "appdel.h"

@class picturerslider;

@interface picturer:UIView

+(void)open:(UIImageView*)_image;
+(void)open:(UIImageView*)_image real:(UIImage*)_realimage;

@property(weak, nonatomic)picturerslider *slider;
@property(weak, nonatomic)UIView *baseview;
@property(weak, nonatomic)UIImageView *image;

@end

@interface picturerslider:UIView

-(void)update:(CGFloat)_delta;

@property(weak, nonatomic)UIView *indicator;

@end