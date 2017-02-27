#import "appdel.h"

@interface modann:NSObject<MKAnnotation>

-(modann*)init:(CGFloat)_latitude lon:(CGFloat)_longitude title:(NSString*)_title;

@end