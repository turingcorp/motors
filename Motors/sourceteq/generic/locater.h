#import "appdel.h"

@class locman;

@interface locater:NSObject<CLLocationManagerDelegate>

@property(strong, nonatomic)locman *loc;

@end