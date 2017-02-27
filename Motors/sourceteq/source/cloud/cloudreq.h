#import "appdel.h"

@interface cloudreq:NSObject<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

+(void)type:(cloudreqtype)_type delegate:(id<cloudreqdel>)_delegate variables:(NSString*)_variables;
-(void)cancel;

@property(weak, nonatomic)id<cloudreqdel> delegate;
@property(strong, nonatomic)id response;
@property(copy, nonatomic)NSString *variables;
@property(nonatomic)cloudreqtype type;

@end