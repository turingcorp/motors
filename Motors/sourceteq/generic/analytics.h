#import "appdel.h"

@interface analytics:NSObject<MofilerDelegate>

+(instancetype)singleton;
-(void)start;
-(void)screen:(NSString*)name;
-(void)event:(NSString*)name;

@property(weak, nonatomic)Mofiler *mofiler;

@end
