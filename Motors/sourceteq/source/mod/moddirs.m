#import "moddirs.h"

@implementation moddirs

+(void)create:(NSURL*)_dirname
{
    NSFileManager *manager = [NSFileManager defaultManager];
 
    if(![manager fileExistsAtPath:_dirname.absoluteString])
    {
        [manager createDirectoryAtURL:_dirname withIntermediateDirectories:YES attributes:nil error:nil];
        [_dirname setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
}

+(void)deletefile:(NSString*)_filename isdir:(BOOL)_isdir
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if([manager fileExistsAtPath:_filename])
    {
        NSURL *fileurl = [NSURL fileURLWithPath:_filename isDirectory:_isdir];
        [manager removeItemAtURL:fileurl error:nil];
    }
}

+(void)copy:(NSString*)_origin to:(NSString*)_destination
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *destinationurl = [NSURL fileURLWithPath:_destination];
    NSURL *originurl = [NSURL fileURLWithPath:_origin];

    if([manager fileExistsAtPath:_destination])
    {
        [manager removeItemAtURL:destinationurl error:nil];
    }
    
    [manager copyItemAtURL:originurl toURL:destinationurl error:nil];
}

+(void)saveimage:(modsearchresult*)_result
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       if(_result.picture)
                       {
                           NSString *fullpathname = [imagesfolder stringByAppendingPathComponent:_result.itemid];
                           [UIImageJPEGRepresentation(_result.picture.image, 1) writeToFile:fullpathname options:NSDataWritingAtomic error:nil];
                       }
                   });
}

@end