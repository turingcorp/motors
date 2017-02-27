#import "modsites.h"

@implementation modsites
{
    NSMutableArray *array;
}

+(modsites*)sha
{
    static modsites *sha;
    static dispatch_once_t once;
    dispatch_once(&once, ^(void){ sha = [[self alloc] init]; });
    
    return sha;
}

-(modsites*)init
{
    self = [super init];
    
    array = [NSMutableArray array];
    NSArray *rawsites = [db rows:@"SELECT id, site, name FROM site ORDER BY NAME ASC"];
    NSInteger count = rawsites.count;
    
    for(NSInteger i = 0; i < count; i++)
    {
        NSDictionary *rawsite = rawsites[i];
        NSString *identifier = rawsite[@"site"];
        NSString *name = rawsite[@"name"];
        NSInteger siteid = [rawsite[@"id"] integerValue];
        
        [array addObject:[[modsite alloc] init:identifier name:name siteid:siteid]];
    }
    
    return self;
}

#pragma mark public

-(NSInteger)count
{
    return array.count;
}

-(modsite*)site:(NSInteger)_index
{
    return array[_index];
}

-(NSInteger)siteforname:(NSString*)_sitename
{
    NSInteger index = -1;
    NSInteger count = array.count;
    
    for(NSInteger i = 0; i < count; i++)
    {
        modsite *insite = array[i];
        
        if([insite.name.lowercaseString isEqualToString:_sitename])
        {
            index = i;
            
            break;
        }
    }
    
    return index;
}

-(modsite*)siteforid:(NSInteger)_siteid
{
    modsite *site;
    NSInteger count = array.count;
    
    for(NSInteger i = 0; i < count; i++)
    {
        modsite *insite = array[i];
        
        if(insite.siteid == _siteid)
        {
            site = insite;
            
            break;
        }
    }
    
    return site;
}

@end

@implementation modsite

@synthesize identifier;
@synthesize name;
@synthesize siteid;

-(modsite*)init:(NSString*)_identifier name:(NSString*)_name siteid:(NSInteger)_siteid
{
    self = [super init];

    identifier = _identifier;
    name = _name;
    siteid = _siteid;
    
    return self;
}

@end