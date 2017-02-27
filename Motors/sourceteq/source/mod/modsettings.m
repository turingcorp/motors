#import "modsettings.h"

@implementation modsettings
{
    BOOL prefloaded;
}

@synthesize site;
@synthesize perks;
@synthesize uuid;
@synthesize appid;
@synthesize searchquery;
@synthesize siteindex;
@synthesize lastpricesguide;

+(modsettings*)sha
{
    static modsettings *sha;
    static dispatch_once_t once;
    dispatch_once(&once, ^(void){ sha = [[self alloc] init]; });
    
    return sha;
}

-(modsettings*)init
{
    self = [super init];
    
    prefloaded = NO;
    
    return self;
}

#pragma mark functionality

#pragma mark public

-(void)changecountry:(NSInteger)_index
{
    searchquery = nil;
    siteindex = _index;
    site = [[modsites sha] site:siteindex];
}

-(void)loadpreferences
{
    prefloaded = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    uuid = [defaults valueForKey:@"uuid"];
    appid = [defaults valueForKey:@"appid"];
    perks = [defaults valueForKey:@"perks"];
    
    if(!perks)
    {
        perks = [NSDictionary dictionary];
    }
    
    NSDictionary *settings = [defaults valueForKey:@"settings"];
    siteindex = [settings[@"site"] integerValue];
    lastpricesguide = [settings[@"lastpricesguide"] integerValue];
    site = [[modsites sha] site:siteindex];
}

-(void)savepreferences
{
    NSMutableDictionary *setts = [NSMutableDictionary dictionary];
    setts[@"site"] = @(siteindex);
    setts[@"lastpricesguide"] = @(lastpricesguide);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:setts forKey:@"settings"];
    [defaults setValue:perks forKey:@"perks"];
}

-(void)editquery:(NSString*)_newquery
{
    BOOL update = NO;
    
    if(_newquery && _newquery.length)
    {
        if(![_newquery.lowercaseString isEqualToString:searchquery.lowercaseString])
        {
            searchquery = _newquery;
            update = YES;
        }
    }
    else if(searchquery)
    {
        searchquery = nil;
        update = YES;
    }
    
    if(update)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:notfilterschanged object:self];
    }
}

-(BOOL)shouldpricesguide
{
    BOOL granted = YES;
    
    if(![[modperks sha] buyed:@"iturbide.Motors.prices"])
    {
        NSInteger timestamp = [NSDate date].timeIntervalSince1970;
        
        if(timestamp - lastpricesguide < 86400)
        {
            granted = NO;
        }
        else
        {
            lastpricesguide = timestamp;
            [self savepreferences];
        }
    }
    
    return granted;
}

@end