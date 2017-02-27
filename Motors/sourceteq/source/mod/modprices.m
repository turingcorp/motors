#import "modprices.h"

@implementation modprices
{
    NSMutableArray *array;
    NSMutableArray *costs;
    NSInteger offset;
    BOOL busy;
}

@synthesize prevselected;
@synthesize error;
@synthesize leaf;

-(modprices*)init
{
    self = [super init];
    
    leaf = NO;
    busy = NO;
    
    return self;
}

#pragma mark functionality

-(void)parse:(NSDictionary*)_json
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       NSInteger qty = 0;
                       NSArray *children = _json[@"children_categories"];
                       
                       if([tools notnullorempty:children])
                       {
                           qty = children.count;
                       }
                       
                       if(qty)
                       {
                           for(NSInteger i = 0; i < qty; i++)
                           {
                               NSDictionary *inarr = children[i];
                               NSString *rawid = inarr[@"id"];
                               NSString *rawname = inarr[@"name"];
                               NSInteger rawqty = [inarr[@"total_items_in_this_category"] integerValue];
                               
                               if([tools notnullorempty:inarr])
                               {
                                   [self add:[[modprice alloc] init:rawid name:rawname qty:rawqty]];
                               }
                           }
                           
                           busy = NO;
                       }
                       else
                       {
                           [self requestmore:YES];
                       }
                       
                       [[NSNotificationCenter defaultCenter] postNotificationName:notupdateprices object:nil];
                   });
}

-(void)parsefilters:(NSDictionary*)_json
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       NSArray *filters = _json[@"available_filters"];
                       NSInteger qtyfilters = filters.count;
                       
                       if(qtyfilters)
                       {
                           for(NSInteger i = 0; i < qtyfilters; i++)
                           {
                               NSDictionary *infilter = filters[i];
                               NSString *infilterid = infilter[@"id"];
                               
                               if([infilterid isEqualToString:@"years"])
                               {
                                   NSArray *invalues = infilter[@"values"];
                                   NSInteger qtyvalues = invalues.count;
                                   NSString *catid = prevselected.catid;
                                   NSString *name = prevselected.name;
                                   
                                   for(NSInteger j = 0; j < qtyvalues; j++)
                                   {
                                       NSDictionary *rawvalue = invalues[j];
                                       NSString *rawvalueid = rawvalue[@"id"];
                                       NSString *rawvaluename = rawvalue[@"name"];
                                       NSInteger rawvalueresults = [rawvalue[@"results"] integerValue];
                                       NSString *completename = [NSString stringWithFormat:@"%@ %@", name, rawvaluename];
                                       
                                       modprice *price = [[modprice alloc] init:catid name:completename qty:rawvalueresults];
                                       price.filter = [NSString stringWithFormat:@"%@=%@", infilterid, rawvalueid];
                                       [self add:price];
                                   }
                                   
                                   busy = NO;
                                   [[NSNotificationCenter defaultCenter] postNotificationName:notupdateprices object:nil];
                                   
                                   break;
                               }
                           }
                       }
                       else
                       {
                           [self request:nil error:NSLocalizedString(@"prices_error_nodata", nil)];
                       }
                   });
}

-(void)parsereport:(NSDictionary*)_json
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       NSArray *results = _json[@"results"];
                       
                       if([tools notnullorempty:results])
                       {
                           NSInteger newres = results.count;
                           
                           for(NSInteger i = 0; i < newres; i++)
                           {
                               NSDictionary *inres = results[i];
                               
                               if([tools notnullorempty:inres])
                               {
                                   BOOL priceable = YES;
                                   NSString *currency = inres[@"currency_id"];
                                   
                                   if([tools notnullorempty:currency])
                                   {
                                       if([currency.lowercaseString isEqualToString:@"usd"])
                                       {
                                           priceable = NO;
                                       }
                                   }
                                   
                                   if(priceable)
                                   {
                                       NSNumber *price = inres[@"price"];
                                       
                                       if([tools notnullorempty:price])
                                       {
                                           [costs addObject:price];
                                           
                                           NSLog(@"%@", price);
                                       }
                                   }
                               }
                           }
                       }
                       
                       NSInteger qty = [costs count];
                       
                       if(offset < prevselected.qty)
                       {
                           [self requestmore:NO];
                       }
                       else
                       {
                           double sum = 0;
                           double average = 0;
                           double deviation = 0;
                           double min = 0;
                           double max = 0;
                           
                           if(qty > 3)
                           {
                               double innersum = 0;
                               double innerroot = 0;
                               
                               for(NSInteger i = 0; i < qty; i++)
                               {
                                   sum += [costs[i] doubleValue];
                               }
                               
                               average = sum / qty;
                               
                               for(NSInteger i = 0; i < qty; i++)
                               {
                                   double val = [costs[i] doubleValue];
                                   double valminus = val - average;
                                   innersum += pow(valminus, 2);
                               }
                               
                               innerroot = innersum / (qty - 1);
                               deviation = sqrt(innerroot);
                               min = average - deviation;
                               max = average + deviation;
                           }
                           else
                           {
                               for(NSInteger i = 0; i < qty; i++)
                               {
                                   double val = [costs[i] doubleValue];
                                   
                                   if(!min || val < min)
                                   {
                                       min = val;
                                   }
                                   
                                   if(val > max)
                                   {
                                       max = val;
                                   }
                               }
                           }
                           
                           prevselected.report = [[modpricereport alloc] init];
                           prevselected.report.min = min;
                           prevselected.report.max = max;
                           [[NSNotificationCenter defaultCenter] postNotificationName:notupdateprices object:nil];
                       }
                   });
}

-(void)requestmore:(BOOL)_firsttime
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       cloudreqtype reqtype = cloudreqtypepricesfetch;
                       NSInteger limit = feedsize;
                       
                       if(_firsttime)
                       {
                           reqtype = cloudreqtypepricesfilters;
                           offset = 0;
                           limit = 0;
                       }
                       
                       NSMutableString *vars = [NSMutableString string];
                       [vars appendFormat:@"limit=%@", @(limit)];
                       [vars appendFormat:@"&offset=%@", @(offset)];
                       [vars appendFormat:@"&category=%@", prevselected.catid];
                       
                       if(prevselected.filter)
                       {
                           [vars appendFormat:@"&%@", prevselected.filter];
                       }
                       
                       offset += limit;
                       
                       [cloudreq type:reqtype delegate:self variables:vars];
                   });
}

#pragma mark public

-(NSInteger)count
{
    return array.count;
}

-(void)add:(modprice*)_price
{
    [array addObject:_price];
}

-(modprice*)price:(NSInteger)_index
{
    return array[_index];
}

-(void)pull
{
    array = [NSMutableArray array];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       if(!busy)
                       {
                           busy = YES;
                           
                           if(prevselected.filter)
                           {
                               leaf = YES;
                               costs = [NSMutableArray array];
                               
                               [self requestmore:NO];
                           }
                           else
                           {
                               NSMutableString *vars = [NSMutableString string];
                               
                               if(prevselected)
                               {
                                   [vars appendFormat:@"%@", prevselected.catid];
                               }
                               else
                               {
                                   NSDictionary *urls = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"url" withExtension:@"plist"]];
                                   NSString *supercat = urls[@"supercategory"];
                                   [vars appendFormat:@"%@%@", [modsettings sha].site.identifier, supercat];
                               }
                               
                               [cloudreq type:cloudreqtypepricesselect delegate:self variables:vars];
                           }
                       }
                   });
}

#pragma mark -
#pragma mark cloud del

-(void)requestsuccess:(cloudreq*)_request
{
    switch(_request.type)
    {
        case cloudreqtypepricesselect:
            
            [self parse:_request.response];
            
            break;
            
        case cloudreqtypepricesfilters:
            
            [self parsefilters:_request.response];
            
            break;
            
        case cloudreqtypepricesfetch:
            
            [self parsereport:_request.response];
            
            break;
            
        default:
            break;
    }
}

-(void)request:(cloudreq*)_request error:(NSString*)_error
{
    busy = NO;
    error = _error;
    [[NSNotificationCenter defaultCenter] postNotificationName:notupdateprices object:nil];
}

@end

@implementation modprice

@synthesize report;
@synthesize name;
@synthesize catid;
@synthesize filter;
@synthesize qty;

-(modprice*)init:(NSString*)_catid name:(NSString*)_name qty:(NSInteger)_qty
{
    self = [super init];
    
    catid = _catid;
    name = _name;
    qty = _qty;
    
    return self;
}

@end

@implementation modpricereport

@synthesize min;
@synthesize max;

@end