#import <Foundation/Foundation.h>

typedef enum
{
    timerstateactive,
    timerstatepaused
}timerstate;

@protocol timerbgdel <NSObject>

-(void)timerbgtick;

@end

@interface timerbg:NSObject

+(timerbg*)millis:(NSInteger)_millis delegate:(id<timerbgdel>)_delegate background:(BOOL)_background;
+(timerbg*)millis:(NSInteger)_millis leeway:(NSInteger)_leeway delegate:(id<timerbgdel>)_delegate background:(BOOL)_background;
-(void)pause;
-(void)resume;

@property(weak, nonatomic)id<timerbgdel> delegate;
@property(nonatomic)timerstate state;

@end