#import "cloudimg.h"

@implementation cloudimg
{
    dispatch_queue_t queue;
    NSMutableArray *tasks;
    NSURLSession *session;
}

+(cloudimg*)sha
{
    static cloudimg *sha;
    static dispatch_once_t once;
    dispatch_once(&once,
                  ^(void)
                  {
                      sha = [[self alloc] init];
                  });
    return sha;
}

-(cloudimg*)init
{
    self = [super init];
    
    NSString *queuename = [NSString stringWithFormat:@"cloudimg_%@", @(arc4random_uniform(1000))];
    queue = dispatch_queue_create(queuename.UTF8String, DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
    
    dispatch_async(queue,
                   ^(void)
                   {
                       tasks = [NSMutableArray array];
                   });
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    [configuration setAllowsCellularAccess:YES];
    [configuration setTimeoutIntervalForRequest:40];
    
    session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    return self;
}

#pragma mark public

-(void)image:(NSString*)_url
{
    dispatch_async(queue,
                   ^(void)
                   {
                       NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[NSURL URLWithString:_url]];
                       [tasks addObject:task];
                       task.taskDescription = _url;
                       [task resume];
                   });
}

#pragma mark -
#pragma mark session task del

-(void)URLSession:(NSURLSession*)_session task:(NSURLSessionTask*)_task didCompleteWithError:(NSError*)_error
{
    if(_error)
    {
        NSLog(@"Image with error: %@", _error.localizedDescription);
    }
}

#pragma mark download task del

-(void)URLSession:(NSURLSession*)_session downloadTask:(NSURLSessionDownloadTask*)_task didFinishDownloadingToURL:(NSURL*)_location
{
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:_location]];
    
    dispatch_async(queue,
                   ^(void)
                   {
                       NSUInteger index = [tasks indexOfObject:_task];
                       
                       if(index != NSNotFound)
                       {
                           [tasks removeObject:_task];
                           NSString *url = _task.taskDescription;
                           cloudimgreference *reference = [[cloudimgreference alloc] init:url image:image];
                           
                           [[NSNotificationCenter defaultCenter] postNotificationName:notimageloaded object:nil userInfo:[reference userinfo]];
                       }
                   });
}

@end

@implementation cloudimgreference

@synthesize image;
@synthesize url;

+(UIImage*)userinfo:(NSDictionary*)_userinfo equals:(NSString*)_reference
{
    UIImage *image;
    
    if(_userinfo[@"image"])
    {
        cloudimgreference *ref = _userinfo[@"image"];
        
        if(ref)
        {
            if([ref.url isEqualToString:_reference])
            {
                image = ref.image;
            }
        }
    }
    
    return image;
}

-(cloudimgreference*)init:(NSString*)_url image:(UIImage*)_image
{
    self = [super init];
    
    url = _url;
    image = _image;
    
    return self;
}

#pragma mark public

-(NSDictionary*)userinfo
{
    return @{@"image":self};
}

@end