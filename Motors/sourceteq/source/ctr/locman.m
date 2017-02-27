#import "locman.h"

@implementation locman

-(locman*)init
{
    self = [super init];
    
    [self setDesiredAccuracy:kCLLocationAccuracyKilometer];
    [self setDistanceFilter:1000];
    
    if([self respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self requestWhenInUseAuthorization];
    }
    
    return self;
}

@end