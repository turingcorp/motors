#import "cloudreq.h"

@implementation cloudreq
{
    NSURLSession *session;
    NSMutableData *data;
    NSError *error;
}

@synthesize delegate;
@synthesize response;
@synthesize variables;
@synthesize type;

+(void)type:(cloudreqtype)_type delegate:(id<cloudreqdel>)_delegate variables:(NSString*)_variables
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       __unused cloudreq *req = [[cloudreq alloc] init:_type delegate:_delegate variables:_variables];
                   });
}

-(cloudreq*)init:(cloudreqtype)_type delegate:(id<cloudreqdel>)_delegate variables:(NSString*)_variables
{
    self = [super init];
    
    delegate = _delegate;
    variables = _variables;
    type = _type;
    data = [NSMutableData data];
    
    NSDictionary *urls = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"url" withExtension:@"plist"]];
    NSString *server;
    NSString *endpoint;
    NSInteger timeout;
    NSString *urlstr;
    NSURL *url;
    NSURLSessionTask *task;
    NSMutableURLRequest *request;
    NSString *postvars;
    BOOL post = NO;
    
    switch(type)
    {
        case cloudreqtypelogin:
        case cloudreqtypesearch:
            
            timeout = 40;
            server = urls[@"server"];
            endpoint = [NSString stringWithFormat:@"/%@/%@/%@?", urls[@"sites"], [modsettings sha].site.identifier, urls[@"search"]];
            
            break;
            
        case cloudreqtypeitem:
            
            timeout = 20;
            server = urls[@"server"];
            endpoint = [NSString stringWithFormat:@"/%@/", urls[@"items"]];
            
            break;
            
        case cloudreqtypepricesselect:
            
            timeout = 25;
            server = urls[@"server"];
            endpoint = [NSString stringWithFormat:@"/%@/", urls[@"cats"]];
            
            break;
            
        case cloudreqtypepricesfilters:

            timeout = 45;
            server = urls[@"server"];
            endpoint = [NSString stringWithFormat:@"/%@/%@/%@?", urls[@"sites"], [modsettings sha].site.identifier, urls[@"search"]];
            
            break;
            
        case cloudreqtypepricesfetch:
            
            timeout = 50;
            server = urls[@"server"];
            endpoint = [NSString stringWithFormat:@"/%@/%@/%@?", urls[@"sites"], [modsettings sha].site.identifier, urls[@"search"]];
            
            break;
    }
    
    urlstr = [NSString stringWithFormat:@"%@%@%@", server, endpoint, variables];
    url = [NSURL URLWithString:urlstr];
    
    if(post)
    {
        request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[postvars dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO]];
    }
    else
    {
        request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeout];
    }
    
    NSLog(@"%@", urlstr);
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    [configuration setAllowsCellularAccess:YES];
    [configuration setTimeoutIntervalForRequest:timeout];
    session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    task = [session dataTaskWithRequest:request];
    [task resume];
    [session finishTasksAndInvalidate];
    
    return self;
}

#pragma mark public

-(void)cancel
{
    [session invalidateAndCancel];
}

#pragma mark -
#pragma mark session del

-(void)URLSession:(NSURLSession*)_session didBecomeInvalidWithError:(NSError*)_error
{
    error = error ? error : _error;
    
    if(error)
    {
        [delegate request:self error:error.localizedDescription];
    }
    else if(!data)
    {
        [delegate request:self error:NSLocalizedString(@"request_error_dataempty", nil)];
    }
    else
    {
        NSError *jsonerror;
        
        response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonerror];
        
        if(jsonerror)
        {
            [delegate request:self error:jsonerror.localizedDescription];
        }
        else if(!response)
        {
            [delegate request:self error:NSLocalizedString(@"request_error_invalidparse", nil)];
        }
        else
        {
            [delegate requestsuccess:self];
        }
    }
}

#pragma mark session task del

-(void)URLSession:(NSURLSession*)_session task:(NSURLSessionTask*)_task didCompleteWithError:(NSError*)_error
{
    error = _error;
}

#pragma mark session data task del

-(void)URLSession:(NSURLSession*)_session dataTask:(NSURLSessionDataTask*)_task didReceiveData:(NSData*)_data
{
    [data appendData:_data];
}

@end
