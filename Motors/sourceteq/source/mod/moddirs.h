#import "appdel.h"

@class modsearchresult;

@interface moddirs:NSObject

+(void)create:(NSURL*)_dirname;
+(void)deletefile:(NSString*)_filename isdir:(BOOL)_isdir;
+(void)copy:(NSString*)_origin to:(NSString*)_destination;
+(void)saveimage:(modsearchresult*)_result;

@end