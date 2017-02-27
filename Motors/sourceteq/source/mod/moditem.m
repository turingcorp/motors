#import "moditem.h"

@implementation moditem

@synthesize site;
@synthesize pictures;
@synthesize location;
@synthesize contact;
@synthesize attributes;
@synthesize datepublished;
@synthesize itemid;
@synthesize title;
@synthesize descr;
@synthesize sellerid;
@synthesize categoryid;
@synthesize price;
@synthesize currencyid;

-(moditem*)init
{
    self = [super init];
    
    pictures = [[moditempictures alloc] init];
    location = [[moditemlocation alloc] init];
    contact = [[moditemcontact alloc] init];
    attributes = [[moditemattributes alloc] init];
    
    return self;
}

@end

@implementation moditempictures
{
    NSMutableArray *array;
}

-(moditempictures*)init
{
    self = [super init];
    
    array = [NSMutableArray array];
    
    return self;
}

#pragma mark public

-(NSInteger)count
{
    return array.count;
}

-(void)add:(moditempicture*)_picture
{
    [array addObject:_picture];
}

-(moditempicture*)picture:(NSInteger)_index
{
    return array[_index];
}

@end

@implementation moditempicture

@synthesize url;
@synthesize image;

+(moditempicture*)parse:(NSNotification*)_notification
{
    return _notification.userInfo[@"image"];
}

-(moditempicture*)init:(NSString*)_url
{
    self = [super init];
    
    url = _url;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedimageloaded:) name:notimageloaded object:nil];
    [[cloudimg sha] image:url];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark notifications

-(void)notifiedimageloaded:(NSNotification*)_notification
{
    UIImage *newimage = [cloudimgreference userinfo:_notification.userInfo equals:url];
    
    if(newimage)
    {
        image = newimage;
        
        dispatch_async(dispatch_get_main_queue(),
                       ^(void)
                       {
                           [[NSNotificationCenter defaultCenter] postNotificationName:notimageready object:nil userInfo:[self userinfo]];
                       });
    }
}

#pragma mark public

-(NSDictionary*)userinfo
{
    return @{@"image":self};
}

-(BOOL)equalsuserinfo:(NSDictionary*)_userinfo
{
    return _userinfo[@"image"] == self;
}

@end

@implementation moditemlocation

@synthesize addressline;
@synthesize zipcode;
@synthesize neightbourhood;
@synthesize city;
@synthesize state;
@synthesize country;
@synthesize latitude;
@synthesize longitude;

-(moditemlocation*)init
{
    self = [super init];
    
    latitude = 0;
    longitude = 0;
    
    return self;
}

@end

@implementation moditemcontact

@synthesize name;
@synthesize openhours;
@synthesize areacode;
@synthesize phone;
@synthesize email;

-(void)call
{
    NSMutableString *mut = [NSMutableString string];
    [mut appendString:@"tel:"];
    
    if(areacode.length)
    {
        [mut appendString:areacode];
    }
    
    if(phone.length)
    {
        [mut appendString:phone];
    }
    
    NSURL *url = [NSURL URLWithString:mut];
    
    [[UIApplication sharedApplication] openURL:url];
}

-(void)write
{
    NSMutableString *mut = [NSMutableString string];
    [mut appendString:@"mailto:"];
    [mut appendString:email];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mut]];
}

@end

@implementation moditemattributes
{
    NSMutableArray *array;
}

-(moditemattributes*)init
{
    self = [super init];
    
    array = [NSMutableArray array];
    
    return self;
}

#pragma mark public

-(NSInteger)count
{
    return array.count;
}

-(moditemattribute*)attribute:(NSInteger)_index
{
    return array[_index];
}

-(void)add:(moditemattribute*)_attribute
{
    [array addObject:_attribute];
}

-(void)prepend:(moditemattribute*)_attribute
{
    [array insertObject:_attribute atIndex:0];
}

-(void)insertafternum:(moditemattribute*)_attribute
{
    NSInteger count = array.count;
    NSInteger index = 0;
    
    for(index = 0; index < count; index++)
    {
        moditemattribute *attr = array[index];
        
        if(![attr isKindOfClass:[moditemattributenum class]])
        {
            break;
        }
    }
    
    [array insertObject:_attribute atIndex:index];
}

@end

@implementation moditemattribute

@end

@implementation moditemattributesimple

@synthesize title;

@end

@implementation moditemattributecomplex

@synthesize name;
@synthesize value;

@end

@implementation moditemattributenum

@synthesize name;
@synthesize value;

@end