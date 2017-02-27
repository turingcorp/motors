#import "modperks.h"

@implementation modperks
{
    NSMutableArray *array;
    NSNumberFormatter *priceformater;
}

+(modperks*)sha
{
    static modperks *sha;
    static dispatch_once_t once;
    dispatch_once(&once,
                  ^(void)
                  {
                      sha = [[self alloc] init];
                  });
    return sha;
}

-(modperks*)init
{
    self = [super init];
    
    priceformater = [[NSNumberFormatter alloc] init];
    [priceformater setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    return self;
}

#pragma mark functionality

-(void)editstatus:(NSString*)_productid status:(perkstatus)_status
{
    NSInteger qty = array.count;
    
    for(NSInteger i = 0; i < qty; i++)
    {
        modperkelement *e = array[i];
        
        if([e.prodid isEqualToString:_productid])
        {
            e.status = _status;
            
            break;
        }
    }
    
    [modsettings sha].perks = [self asdictionary];
    [[modsettings sha] savepreferences];
}

#pragma mark public

-(void)refresh
{
    array = [NSMutableArray array];
    
    NSDictionary *perks = [modsettings sha].perks;
    NSArray *keys = perks.allKeys;
    NSInteger qty = keys.count;
    
    for(NSInteger i = 0; i < qty; i++)
    {
        NSString *key = keys[i];
        NSDictionary *value = perks[key];
        NSString *title = value[@"title"];
        NSString *descr = value[@"descr"];
        perkstatus status = (perkstatus)[value[@"status"] integerValue];
        
        modperkelement *element = [[modperkelement alloc] init];
        element.prodid = key;
        element.title = title;
        element.descr = descr;
        element.status = status;
        [array addObject:element];
    }
}

-(void)loadperk:(SKProduct*)_product
{
    NSString *prodid = _product.productIdentifier;
    NSInteger qty = [self count];
    
    for(NSInteger i = 0; i < qty; i++)
    {
        modperkelement *tryelement = [self perk:i];
        
        if([tryelement.prodid isEqualToString:prodid])
        {
            [priceformater setLocale:_product.priceLocale];
            NSString *strprice = [priceformater stringFromNumber:_product.price];
            tryelement.pricestr = strprice;
            tryelement.skproduct = _product;
            
            break;
        }
    }
}

-(NSInteger)count
{
    return array.count;
}

-(modperkelement*)perk:(NSInteger)_index
{
    return array[_index];
}

-(void)productpurchased:(NSString*)_productid
{
    [self editstatus:_productid status:perkstatuspurchased];
}

-(void)productpurchasing:(NSString*)_productid
{
    [self editstatus:_productid status:perkstatuspurchasing];
}

-(void)productdeferred:(NSString*)_productid
{
    [self editstatus:_productid status:perkstatusdeferred];
}

-(void)productcanceled:(NSString*)_productid
{
    [self editstatus:_productid status:perkstatusnew];
}

-(NSDictionary*)asdictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSInteger qty = [self count];
    
    for(NSInteger i = 0; i < qty; i++)
    {
        modperkelement *e = [self perk:i];
        NSMutableDictionary *indict = [NSMutableDictionary dictionary];
        indict[@"title"] = e.title;
        indict[@"descr"] = e.descr;
        indict[@"status"] = @(e.status);
        
        dictionary[e.prodid] = indict;
    }
    
    return dictionary;
}

-(NSSet*)asaset
{
    NSMutableSet *set = [NSMutableSet set];
    NSInteger qty = [self count];
    
    for(NSInteger i = 0; i < qty; i++)
    {
        modperkelement *e = [self perk:i];
        [set addObject:e.prodid];
    }
    
    return set;
}

-(BOOL)buyed:(NSString*)_perkid;
{
    BOOL purchased = NO;
    
    NSInteger qty = [self count];
    
    for(NSInteger i = 0; i < qty; i++)
    {
        modperkelement *perk = [self perk:i];
        
        if([perk.prodid isEqualToString:_perkid])
        {
            if(perk.status == perkstatuspurchased)
            {
                purchased = YES;
            }
            
            break;
        }
    }
    
    return purchased;
}

@end

@implementation modperkelement

@synthesize skproduct;
@synthesize prodid;
@synthesize title;
@synthesize descr;
@synthesize pricestr;
@synthesize status;

#pragma mark public

-(void)purchase
{
    [[skman sha] purchase:skproduct];
}

@end