#import "appdel.h"

@interface cloudimg:NSObject<NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

+(cloudimg*)sha;
-(void)image:(NSString*)_url;

@end

@interface cloudimgreference:NSObject

+(UIImage*)userinfo:(NSDictionary*)_userinfo equals:(NSString*)_reference;
-(cloudimgreference*)init:(NSString*)_url image:(UIImage*)_image;
-(NSDictionary*)userinfo;

@property(strong, nonatomic)UIImage *image;
@property(strong, nonatomic)NSString *url;

@end