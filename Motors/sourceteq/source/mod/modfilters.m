#import "modfilters.h"

@implementation modfilters
{
    NSMutableArray *array;
}

-(modfilters*)init
{
    self = [super init];
    
    array = [NSMutableArray array];
    [array addObject:[[modfilter alloc] init:filtercomyear]];
    [array addObject:[[modfilter alloc] init:filtercomcat]];
    [array addObject:[[modfilter alloc] init:filtercomloc]];
    
    return self;
}

#pragma mark public

-(void)parse:(NSDictionary*)_json
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       NSArray *rawfilters = _json[@"available_filters"];
                       
                       if([tools notnullorempty:rawfilters])
                       {
                           NSInteger count = rawfilters.count;
                           
                           for(NSInteger i = 0; i < count; i++)
                           {
                               NSDictionary *inrawfilter = rawfilters[i];
                               
                               if([tools notnullorempty:inrawfilter])
                               {
                                   NSArray *rawvalues = inrawfilter[@"values"];
                                   NSString *rawfilterid = inrawfilter[@"id"];
                                   
                                   if([tools notnullorempty:rawfilterid] && [tools notnullorempty:rawvalues])
                                   {
                                       NSInteger qtyvalues = rawvalues.count;
                                       
                                       if(qtyvalues)
                                       {
                                           BOOL filterfound = NO;
                                           filtercom component = filtercomcat;
                                           
                                           if([rawfilterid isEqualToString:@"category"])
                                           {
                                               component = filtercomcat;
                                               filterfound = YES;
                                           }
                                           else if([rawfilterid isEqualToString:@"state"])
                                           {
                                               component = filtercomloc;
                                               filterfound = YES;
                                           }
                                           else if([rawfilterid isEqualToString:@"years"])
                                           {
                                               component = filtercomyear;
                                               filterfound = YES;
                                           }
                                           
                                           if(filterfound)
                                           {
                                               modfilter *insidefilter = [self filterbycomponent:component];
                                               insidefilter.filterid = rawfilterid;
                                               
                                               for(NSInteger j = 0; j < qtyvalues; j++)
                                               {
                                                   NSDictionary *invaluefilter = rawvalues[j];
                                                   
                                                   if([tools notnullorempty:invaluefilter])
                                                   {
                                                       NSString *invalueid = invaluefilter[@"id"];
                                                       NSString *invaluename = invaluefilter[@"name"];
                                                       NSNumber *invalueresults = invaluefilter[@"results"];
                                                       
                                                       if([tools notnullorempty:invalueid] && [tools notnullorempty:invaluename])
                                                       {
                                                           modfilterelement *newfilter = [[modfilterelement alloc] init];
                                                           newfilter.valueid = invalueid;
                                                           newfilter.valuename = invaluename;
                                                           newfilter.container = insidefilter;
                                                           newfilter.results = invalueresults.integerValue;
                                                           
                                                           [insidefilter add:newfilter];
                                                       }
                                                   }
                                               }
                                               
                                               [insidefilter sort];
                                           }
                                           
                                           [[NSNotificationCenter defaultCenter] postNotificationName:notupdatefilters object:nil];
                                       }
                                   }
                               }
                           }
                       }
                   });
}

-(NSInteger)count
{
    return array.count;
}

-(modfilter*)filter:(NSInteger)_index
{
    return array[_index];
}

-(modfilter*)filterbycomponent:(filtercom)_component
{
    modfilter *filter;
    
    NSInteger qty = array.count;
    
    for(NSInteger i = 0; i < qty; i++)
    {
        modfilter *infilter = array[i];
        
        if(infilter.component == _component)
        {
            filter = infilter;
            
            break;
        }
    }
    
    return filter;
}

@end

@implementation modfilter
{
    NSMutableArray *array;
}

@synthesize selected;
@synthesize filterid;
@synthesize component;
@synthesize defaulttitle;

-(modfilter*)init:(filtercom)_component
{
    self = [super init];
    
    component = _component;
    array = [NSMutableArray array];
    
    switch(component)
    {
        case filtercomcat:
            
            defaulttitle = NSLocalizedString(@"filters_default_category", nil);
            
            break;
            
        case filtercomloc:
            
            defaulttitle = NSLocalizedString(@"filters_default_location", nil);
            
            break;
            
        case filtercomyear:
            
            defaulttitle = NSLocalizedString(@"filters_default_year", nil);
            
            break;
            
    }
    
    return self;
}

#pragma mark public

-(NSInteger)count
{
    return array.count;
}

-(modfilterelement*)element:(NSInteger)_index
{
    return array[_index];
}

-(void)add:(modfilterelement*)_filter
{
    [array addObject:_filter];
}

-(NSInteger)indexof:(modfilterelement*)_element
{
    return [array indexOfObject:_element];
}

-(void)sort
{
    [array sortUsingComparator:[tools sha].comparerfilter];
}

@end

@implementation modfilterelement

@synthesize children;
@synthesize valueid;
@synthesize valuename;
@synthesize container;
@synthesize parent;
@synthesize results;

@end