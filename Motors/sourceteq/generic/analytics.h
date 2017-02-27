#import "appdel.h"

@interface analytics:NSObject<MofilerDelegate>

+(instancetype)singleton;
-(void)start;

@property(weak, nonatomic)Mofiler *mofiler;

@end
