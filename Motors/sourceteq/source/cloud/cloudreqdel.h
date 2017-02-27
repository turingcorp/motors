@class cloudreq;

@protocol cloudreqdel <NSObject>

-(void)requestsuccess:(cloudreq*)_request;
-(void)request:(cloudreq*)_request error:(NSString*)_error;

@end