#import "modann.h"

@implementation modann

@synthesize title;
@synthesize coordinate;

-(modann*)init:(CGFloat)_latitude lon:(CGFloat)_longitude title:(NSString*)_title
{
    self = [super init];

    title = _title;
    coordinate = CLLocationCoordinate2DMake(_latitude, _longitude);
    
    return self;
}

@end