#import <Foundation/Foundation.h>
#import "sqlite3.h"

#define dbshared                SQLITE_OPEN_SHAREDCACHE | SQLITE_OPEN_READWRITE
#define dbprivate               SQLITE_OPEN_PRIVATECACHE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE

extern NSString *dbname;

@interface db:NSObject

+(void)query:(NSString*)_query;
+(int)query_identity:(NSString*)_query;
+(id)value:(NSString*)_select;
+(NSArray*)values:(NSString*)_select;
+(NSDictionary*)row:(NSString*)_select;
+(NSArray*)rows:(NSString*)_select;
+(NSArray*)tables;
+(db*)begin;
+(db*)begin:(NSString*)_name;
-(void)commit;
-(void)rollback;
-(void)query:(NSString*)_query;
-(int)query_identity:(NSString*)_query;
-(id)value:(NSString*)_query;
-(NSArray*)values:(NSString*)_query;
-(NSDictionary*)row:(NSString*)_query;
-(NSArray*)rows:(NSString*)_query;

@property(nonatomic)sqlite3 *insqlite;
@property(nonatomic)sqlite3_stmt *instmt;

@end