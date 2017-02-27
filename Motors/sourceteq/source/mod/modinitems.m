#import "modinitems.h"

@implementation modinitems
{
    NSMutableDictionary *dict;
}

+(modinitems*)sha
{
    static modinitems *sha;
    static dispatch_once_t once;
    dispatch_once(&once, ^(void){ sha = [[self alloc] init]; });
    
    return sha;
}

-(modinitems*)init
{
    self = [super init];
    
    return self;
}

#pragma mark public

-(void)refresh
{
    dict = [NSMutableDictionary dictionary];
    
    NSString *query = [NSString stringWithFormat:
                       @"SELECT i.id, i.status, i.item, i.title, "
                       "n.contactname, n.openhours, n.areacode, n.phone, n.email "
                       "FROM item as i "
                       "LEFT JOIN iteminfo as n "
                       "on i.id=n.itemid "
                       "ORDER BY i.title ASC;"];
    
    NSArray *rawitems = [db rows:query];
    NSInteger count = rawitems.count;
    
    for(NSInteger i = 0; i < count; i++)
    {
        NSDictionary *rawitem = rawitems[i];
        NSString *rawid = rawitem[@"item"];
        NSString *rawtitle = rawitem[@"title"];
        NSString *rawcontactname = rawitem[@"contactname"];
        NSString *rawopenhours = rawitem[@"opeanhours"];
        NSString *rawareacode = rawitem[@"areacode"];
        NSString *rawphone = rawitem[@"phone"];
        NSString *rawemail = rawitem[@"email"];
        NSInteger rawitemid = [rawitem[@"id"] integerValue];
        statustype rawstatus = (statustype)[rawitem[@"status"] integerValue];
        modinitem *initem = [[modinitem alloc] init];
        initem.identifier = rawid;
        initem.itemid = rawitemid;
        initem.status = rawstatus;
        initem.title = rawtitle;
        
        if(rawphone || rawemail)
        {
            moditemcontact *contact = [[moditemcontact alloc] init];
            contact.name = rawcontactname;
            contact.openhours = rawopenhours;
            contact.areacode = rawareacode;
            contact.phone = rawphone;
            contact.email = rawemail;
            
            initem.contact = contact;
        }
        
        [initem loadimage];
        
        dict[rawid] = initem;
    }
}

-(modinitem*)fetchorcreate:(NSString*)_identifier
{
    modinitem *initem = dict[_identifier];
    
    if(!initem)
    {
        initem = [[modinitem alloc] init];
        initem.identifier = _identifier;
        
        dict[_identifier] = initem;
    }
    
    return initem;
}

-(NSArray*)asarray
{
    return dict.allValues;
}

@end

@implementation modinitem

@synthesize item;
@synthesize result;
@synthesize contact;
@synthesize image;
@synthesize identifier;
@synthesize title;
@synthesize status;
@synthesize itemid;

-(modinitem*)init
{
    self = [super init];
    
    itemid = 0;
    status = statustypeactive;
    
    return self;
}

#pragma mark public

-(void)favorite
{
    status = statustypefavorite;
    [self save];
}

-(void)trash
{
    status = statustypetrash;
    [self save];
}

-(void)nostatus
{
    status = statustypeactive;
    [self save];
}

-(void)save
{
    NSString *query;
    NSNumber *now = @([tools timestamp]);
    
    db *_db = [db begin];
    
    if(itemid)
    {
        query = [NSString stringWithFormat:
                 @"UPDATE item set "
                 "status=%@ where id=%@;",
                 @(status), @(itemid)];
        
        [_db query:query];
    }
    else
    {
        query = [NSString stringWithFormat:
                 @"INSERT INTO item (created, status, item, title) "
                 "values(%@, %@, \"%@\", \"%@\");",
                 now, @(status), identifier, title];
        
        itemid = [_db query_identity:query];
        [moddirs saveimage:result];
        image = result.picture.image;
        
        if(contact)
        {
            NSMutableString *mutquery = [NSMutableString string];
            [mutquery appendString:@"itemid"];
            NSString *strcontactname = @"";
            
            if(contact.name)
            {
                strcontactname = [NSString stringWithFormat:@", \"%@\"", contact.name];
                [mutquery appendString:@", contactname"];
            }
            
            NSString *stropenhours = @"";
            
            if(contact.openhours)
            {
                stropenhours = [NSString stringWithFormat:@", \"%@\"", contact.openhours];
                [mutquery appendString:@", openhours"];
            }
            
            NSString *strareacode = @"";
            
            if(contact.areacode)
            {
                strareacode = [NSString stringWithFormat:@", \"%@\"", contact.areacode];
                [mutquery appendString:@", areacode"];
            }
            
            NSString *strphone = @"";
            
            if(contact.phone)
            {
                strphone = [NSString stringWithFormat:@", \"%@\"", contact.phone];
                [mutquery appendString:@", phone"];
            }
            
            NSString *stremail = @"";
            
            if(contact.email)
            {
                stremail = [NSString stringWithFormat:@", \"%@\"", contact.email];
                [mutquery appendString:@", email"];
            }
            
            query = [NSString stringWithFormat:
                     @"INSERT INTO iteminfo "
                     "(%@) "
                     "values(%@%@%@%@%@%@);",
                     mutquery, @(itemid), strcontactname, stropenhours, strareacode, strphone, stremail];
            
            [_db query:query];
        }
    }
    
    [_db commit];
}

-(void)loadimage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       image = [[UIImage alloc] initWithContentsOfFile:[imagesfolder stringByAppendingPathComponent:identifier]];
                   });
}

-(void)loaditem
{
    result = [[modsearchresult alloc] init];
    result.itemid = identifier;
    result.picture = [[moditempicture alloc] init];
    result.picture.image = image;
    [result getitem];
}

@end