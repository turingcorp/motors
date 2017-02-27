#import "modsearch.h"

@implementation modsearch
{
    NSMutableArray *array;
    BOOL pooling;
}

@synthesize resultselected;
@synthesize filters;
@synthesize totalitems;
@synthesize loadeditems;
@synthesize indexselected;
@synthesize poolable;

-(modsearch*)init
{
    self = [super init];
    
    [self retry];
    filters = [[modfilters alloc] init];
    [vimaster sha].bar.filterbar.filters = filters;
    
    return self;
}

#pragma mark functionality

-(void)parse:(NSDictionary*)_json
{
    if(_json && [_json isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *paging = _json[@"paging"];
        
        if([tools notnullorempty:paging])
        {
            totalitems = [paging[@"total"] integerValue];
        }
        
        NSArray *results = _json[@"results"];
        
        if([tools notnullorempty:results])
        {
            NSInteger count = results.count;
            loadeditems += count;
            
            if(count)
            {
                for(NSInteger i = 0; i < count; i++)
                {
                    NSDictionary *inres = results[i];
                    
                    if([tools notnullorempty:inres])
                    {
                        NSString *rawitemid = inres[@"id"];
                        
                        if([tools parsestringvalid:rawitemid])
                        {
                            NSMutableString *rawtitle = [NSMutableString string];
                            NSNumber *rawprice = inres[@"price"];
                            NSString *rawcurrency = inres[@"currency_id"];
                            NSString *rawimage = inres[@"thumbnail"];
                            NSString *rawareacode;
                            NSString *rawphone;
                            NSMutableString *address = [NSMutableString string];
                            NSArray *rawattributes = inres[@"attributes"];
                            NSDictionary *rawaddress = inres[@"address"];
                            NSDictionary *rawsellercontact = inres[@"seller_contact"];
                            
                            if([tools notnullorempty:rawattributes])
                            {
                                NSString *rawbrand;
                                NSString *rawmodel;
                                NSString *rawyear;
                                NSInteger count = rawattributes.count;
                                
                                for(NSInteger i = 0; i < count; i++)
                                {
                                    NSDictionary *inattr = rawattributes[i];
                                    
                                    if([tools notnullorempty:inattr])
                                    {
                                        NSString *attrname = inattr[@"name"];
                                        NSString *attrvalue = inattr[@"value_name"];
                                        
                                        if([tools parsestringvalid:attrname] && [tools parsestringvalid:attrvalue])
                                        {
                                            if([attrname isEqualToString:@"Marca"])
                                            {
                                                rawbrand = attrvalue;
                                            }
                                            else if([attrname isEqualToString:@"Modelo"])
                                            {
                                                rawmodel = attrvalue;
                                            }
                                            else if([attrname isEqualToString:@"Año"])
                                            {
                                                rawyear = attrvalue;
                                            }
                                        }
                                    }
                                }
                                
                                if(rawbrand)
                                {
                                    [rawtitle appendString:rawbrand];
                                }
                                
                                if(rawmodel)
                                {
                                    if(rawbrand)
                                    {
                                        [rawtitle appendString:@" "];
                                    }
                                    
                                    [rawtitle appendString:rawmodel];
                                }
                                
                                if(rawbrand || rawmodel)
                                {
                                    [rawtitle appendFormat:@" - %@", rawyear];
                                }
                                else
                                {
                                    rawtitle = inres[@"title"];
                                    
                                    if(![tools notnullorempty:rawtitle])
                                    {
                                        rawtitle = [NSMutableString string];
                                    }
                                }
                            }
                            
                            if([tools notnullorempty:rawsellercontact])
                            {
                                NSString *rawsellerphone = rawsellercontact[@"phone"];
                                NSString *rawsellerareacode = rawsellercontact[@"area_code"];
                                
                                if([tools parsestringvalid:rawsellerphone])
                                {
                                    rawphone = rawsellerphone;
                                    
                                    if([tools parsestringvalid:rawsellerareacode])
                                    {
                                        rawareacode = rawsellerareacode;
                                    }
                                }
                            }
                            
                            rawprice = [tools parsenum:rawprice];
                            rawcurrency = [tools parsestring:rawcurrency];
                            
                            if([tools notnullorempty:rawimage])
                            {
                                rawimage = [rawimage stringByReplacingOccurrencesOfString:@"I.jpg" withString:@"O.jpg"];
                            }
                            else
                            {
                                rawimage = @"";
                            }
                            
                            NSString *price;
                            
                            if([rawcurrency isEqualToString:@"USD"])
                            {
                                price = [[tools sha] pricetostringusd:rawprice];
                            }
                            else
                            {
                                price = [[tools sha] pricetostring:rawprice];
                            }
                            
                            if([tools notnullorempty:rawaddress])
                            {
                                BOOL addedcity = NO;
                                NSString *city = rawaddress[@"city_name"];
                                NSString *state = rawaddress[@"state_name"];
                                
                                if([tools notnullorempty:city])
                                {
                                    addedcity = YES;
                                    [address appendString:city];
                                }
                                
                                if([tools notnullorempty:state])
                                {
                                    if(addedcity)
                                    {
                                        [address appendString:@", "];
                                    }
                                    
                                    [address appendString:state];
                                }
                                
                                if(!rawphone)
                                {
                                    NSString *addressareacode = rawaddress[@"area_code"];
                                    NSString *addressphone = rawaddress[@"phone1"];
                                    
                                    if([tools parsestringvalid:addressphone])
                                    {
                                        rawphone = addressphone;
                                        
                                        if([tools parsestringvalid:addressareacode])
                                        {
                                            rawareacode = addressareacode;
                                        }
                                    }
                                }
                            }
                            
                            modinitem *initem = [[modinitems sha] fetchorcreate:rawitemid];
                            
                            if(initem.status != statustypetrash)
                            {
                                modsearchresult *result = [[modsearchresult alloc] init];
                                result.itemid = rawitemid;
                                result.sellerareacode = rawareacode;
                                result.sellerphone = rawphone;
                                [result changetitle:rawtitle price:price address:address];
                                [result changeimage:rawimage];
                                result.initem = initem;
                                initem.result = result;
                                initem.title = result.title;
                                
                                if(rawphone)
                                {
                                    moditemcontact *contact = [[moditemcontact alloc] init];
                                    contact.areacode = rawareacode;
                                    
                                    if([rawphone rangeOfString:@"@"].location != NSNotFound)
                                    {
                                        contact.email = rawphone;
                                    }
                                    else
                                    {
                                        contact.phone = rawphone;
                                    }
                                    
                                    initem.contact = contact;
                                }
                                
                                [array addObject:result];
                            }
                        }
                    }
                }
            }
            else
            {
                [ctralert alert:NSLocalizedString(@"search_empty", nil)];
            }
        }
        
        if(![[filters filter:0] count])
        {
            [filters parse:_json];
        }
    }
    
    if(loadeditems >= totalitems)
    {
        poolable = NO;
    }
    
    pooling = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:notupdatesearch object:nil];
}

#pragma mark public

-(void)retry
{
    array = [NSMutableArray array];
    totalitems = 0;
    loadeditems = 0;
    pooling = NO;
    poolable = YES;
    indexselected = -1;
}

-(NSInteger)count
{
    return array.count;
}

-(modsearchresult*)searchresult:(NSInteger)_index
{
    return array[_index];
}

-(void)pull
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       if(!pooling)
                       {
                           pooling = YES;
                           poolable = YES;
                           
                           NSMutableString *vars = [NSMutableString string];
                           [vars appendString:@"has_pictures=yes"];
                           [vars appendFormat:@"&limit=%@", @(feedsize)];
                           [vars appendFormat:@"&offset=%@", @(loadeditems)];
                           
                           if([modsettings sha].searchquery)
                           {
                               [vars appendFormat:@"&q=%@", [[tools sha] urlencode:[modsettings sha].searchquery]];
                           }
                           
                           BOOL categorydefined = NO;
                           NSInteger count = [filters count];
                           
                           for(NSInteger i = 0; i < count; i++)
                           {
                               modfilter *infilter = [filters filter:i];
                               
                               if(infilter.selected)
                               {
                                   if(infilter.component == filtercomcat)
                                   {
                                       categorydefined = YES;
                                   }
                                   
                                   [vars appendFormat:@"&%@=%@", infilter.filterid, infilter.selected.valueid];
                               }
                           }
                           
                           if(!categorydefined)
                           {
                               NSDictionary *urls = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"url" withExtension:@"plist"]];
                               NSString *supercat = urls[@"supercategory"];
                               [vars appendFormat:@"&category=%@", supercat];
                           }
                           
                           [cloudreq type:cloudreqtypesearch delegate:self variables:vars];
                       }
                   });
}

-(void)selectresult:(NSInteger)_index
{
    indexselected = _index;
    resultselected = array[indexselected];
}

-(void)remove:(modsearchresult*)_result
{
    NSInteger remindex = [array indexOfObject:_result];
    
    if(remindex == indexselected)
    {
        if(indexselected > array.count - 2)
        {
            indexselected = 0;
            
            if(!array.count)
            {
                indexselected = -1;
            }
        }
    }
    
    [array removeObject:_result];
}

#pragma mark -
#pragma mark cloud del

-(void)requestsuccess:(cloudreq*)_request
{
    [self parse:_request.response];
}

-(void)request:(cloudreq*)_request error:(NSString*)_error
{
    [ctralert alert:_error];
    pooling = NO;
    poolable = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:notupdatesearch object:nil];
}

@end

@implementation modsearchresult
{
    BOOL gettingitem;
}

@synthesize initem;
@synthesize item;
@synthesize picture;
@synthesize itemid;
@synthesize title;
@synthesize price;
@synthesize address;
@synthesize sellerareacode;
@synthesize sellerphone;
@synthesize attr;

-(modsearchresult*)init
{
    self = [super init];

    gettingitem = NO;
    
    return self;
}

#pragma mark functionality

-(void)parseitem:(NSDictionary*)_item
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       NSString *rawitemid = _item[@"id"];
                       
                       if([tools notnullorempty:rawitemid])
                       {
                           NSDictionary *rawgeolocation = _item[@"geolocation"];
                           NSDictionary *rawlocation = _item[@"location"];
                           NSDictionary *rawselleraddress = _item[@"seller_address"];
                           NSDictionary *rawsellercontact = _item[@"seller_contact"];
                           NSArray *pictures = _item[@"pictures"];
                           NSArray *rawattributes = _item[@"attributes"];
                           NSDate *rawdatepublished;
                           NSString *rawtitle = _item[@"title"];
                           NSString *rawsellerid = _item[@"seller_id"];
                           NSString *rawcatid = _item[@"category_id"];
                           NSString *rawcurrency = _item[@"currency_id"];
                           NSString *rawstarttime = _item[@"start_time"];
                           NSString *rawaddressline = @"";
                           NSString *rawzipcode = @"";
                           NSString *rawneightbourhood = @"";
                           NSString *rawcity = @"";
                           NSString *rawstate = @"";
                           NSString *rawcountry = @"";
                           NSString *rawcontactname = @"";
                           NSString *rawcontactopenhours = @"";
                           NSString *rawcontactareacode = @"";
                           NSString *rawcontactphone = @"";
                           NSString *rawcontactemail = @"";
                           NSNumber *rawprice = _item[@"price"];
                           CGFloat latitude = 0;
                           CGFloat longitude = 0;
                           
                           if(![tools parsestringvalid:rawtitle])
                           {
                               rawtitle = title;
                           }
                           
                           if([tools parsestringvalid:rawstarttime])
                           {
                               rawdatepublished = [[tools sha] stringtodate:rawstarttime];
                           }
                           else
                           {
                               rawdatepublished = [NSDate date];
                           }
                           
                           if([tools notnullorempty:rawgeolocation])
                           {
                               latitude = [rawgeolocation[@"latitude"] floatValue];
                               longitude = [rawgeolocation[@"longitude"] floatValue];
                           }
                           
                           if([tools notnullorempty:rawlocation])
                           {
                               NSDictionary *rawrawneight = rawlocation[@"neighborhood"];
                               NSDictionary *rawrawcity = rawlocation[@"city"];
                               NSDictionary *rawrawstate = rawlocation[@"state"];
                               NSDictionary *rawrawcountry = rawlocation[@"country"];
                               rawaddressline = [tools parsestring:rawlocation[@"address_line"]];
                               rawzipcode = [tools parsestring:rawlocation[@"zip_code"]];
                               
                               if([tools notnullorempty:rawrawneight])
                               {
                                   rawneightbourhood = [tools parsestring:rawrawneight[@"name"]];
                               }
                               
                               if([tools notnullorempty:rawrawcity])
                               {
                                   rawcity = [tools parsestring:rawrawcity[@"name"]];
                                   
                                   if([rawcity rangeOfString:@"."].location != NSNotFound)
                                   {
                                       if([tools notnullorempty:rawselleraddress])
                                       {
                                           NSDictionary *rawsellercity = rawselleraddress[@"city"];
                                           
                                           if([tools notnullorempty:rawsellercity])
                                           {
                                               NSString *rawsellercityname = rawsellercity[@"name"];
                                               
                                               rawcity = [tools parsestring:rawsellercityname];
                                           }
                                       }
                                   }
                               }
                               
                               if([tools notnullorempty:rawrawstate])
                               {
                                   rawstate = [tools parsestring:rawrawstate[@"name"]];
                                   
                                   if([rawstate rangeOfString:@"."].location != NSNotFound)
                                   {
                                       if([tools notnullorempty:rawselleraddress])
                                       {
                                           NSDictionary *rawsellerstate = rawselleraddress[@"state"];
                                           
                                           if([tools notnullorempty:rawsellerstate])
                                           {
                                               NSString *rawsellerstatename = rawsellerstate[@"name"];
                                               
                                               rawstate = [tools parsestring:rawsellerstatename];
                                           }
                                       }
                                   }
                               }
                               
                               if([tools notnullorempty:rawrawcountry])
                               {
                                   rawcountry = [tools parsestring:rawrawcountry[@"name"]];
                               }
                               
                               if(!latitude || !longitude)
                               {
                                   latitude = [rawlocation[@"latitude"] floatValue];
                                   longitude = [rawlocation[@"longitude"] floatValue];
                               }
                               
                               if(!rawcontactopenhours.length)
                               {
                                   rawcontactopenhours = [tools parsestring:rawlocation[@"open_hours"]];
                               }
                           }
                           
                           if([tools notnullorempty:rawsellercontact])
                           {
                               rawcontactname = [tools parsestring:rawsellercontact[@"contact"]];
                               rawcontactareacode = [tools parsestring:rawsellercontact[@"area_code"]];
                               rawcontactphone = [tools parsestring:rawsellercontact[@"phone"]];
                           }
                           
                           if(!rawcontactphone.length && sellerphone.length)
                           {
                               rawcontactphone = sellerphone;
                               rawcontactareacode = sellerareacode;
                           }
                           
                           if([rawcontactphone rangeOfString:@"@"].location != NSNotFound)
                           {
                               rawcontactemail = rawcontactphone;
                               rawcontactareacode = nil;
                               rawcontactphone = nil;
                           }
                           
                           rawsellerid = [tools parsestring:rawsellerid];
                           rawcatid = [tools parsestring:rawcatid];
                           rawcurrency = [tools parsestring:rawcurrency];
                           rawprice = [tools parsenum:rawprice];
                           
                           item = [[moditem alloc] init];
                           item.site = [modsettings sha].site;
                           item.itemid = rawitemid;
                           item.title = rawtitle;
                           item.sellerid = rawsellerid;
                           item.categoryid = rawcatid;
                           item.currencyid = rawcurrency;
                           item.price = rawprice;
                           item.datepublished = rawdatepublished;
                           item.location.addressline = rawaddressline;
                           item.location.zipcode = rawzipcode;
                           item.location.neightbourhood = rawneightbourhood;
                           item.location.city = rawcity;
                           item.location.state = rawstate;
                           item.location.country = rawcountry;
                           item.location.latitude = latitude;
                           item.location.longitude = longitude;
                           item.contact.name = rawcontactname;
                           item.contact.openhours = rawcontactopenhours;
                           item.contact.areacode = rawcontactareacode;
                           item.contact.phone = rawcontactphone;
                           item.contact.email = rawcontactemail;
                           
                           if([tools notnullorempty:pictures])
                           {
                               NSInteger count = pictures.count;
                               
                               for(NSInteger i = 0; i < count; i++)
                               {
                                   NSDictionary *rawpicture = pictures[i];
                                   
                                   if([tools notnullorempty:rawpicture])
                                   {
                                       NSString *rawurl = rawpicture[@"url"];
                                       
                                       if([tools parsestringvalid:rawurl])
                                       {
                                           [item.pictures add:[[moditempicture alloc] init:rawurl]];
                                       }
                                   }
                               }
                           }
                           
                           if([tools notnullorempty:rawattributes])
                           {
                               NSInteger count = rawattributes.count;
                               
                               for(NSInteger i = 0; i < count; i++)
                               {
                                   NSDictionary *inattr = rawattributes[i];
                                   
                                   if([tools notnullorempty:inattr])
                                   {
                                       NSString *rawname = inattr[@"name"];
                                       NSString *rawvalue = inattr[@"value_name"];
                                       NSString *valuenocaps = rawvalue.lowercaseString;
                                       
                                       if([tools parsestringvalid:rawname] && [tools parsestringvalid:rawvalue])
                                       {
                                           if([rawname isEqualToString:@"Horario de contacto"])
                                           {
                                               if(!item.contact.openhours.length)
                                               {
                                                   item.contact.openhours = rawvalue;
                                               }
                                           }
                                           else
                                           {
                                               if([valuenocaps isEqualToString:@"sí"] || [valuenocaps isEqualToString:@"si"] || [valuenocaps isEqualToString:@"y"])
                                               {
                                                   moditemattributesimple *rawattr = [[moditemattributesimple alloc] init];
                                                   rawattr.title = rawname;
                                                   [item.attributes add:rawattr];
                                               }
                                               else if(![valuenocaps isEqualToString:@"no"] && ![valuenocaps isEqualToString:@"n"] && ![valuenocaps isEqualToString:@"n/a"])
                                               {
                                                   if([[tools sha] numberfromstring:rawvalue])
                                                   {
                                                       moditemattributenum *rawattr = [[moditemattributenum alloc] init];
                                                       rawattr.name = rawname;
                                                       rawattr.value = @(rawvalue.floatValue);
                                                       [item.attributes prepend:rawattr];
                                                   }
                                                   else
                                                   {
                                                       moditemattributecomplex *rawattr = [[moditemattributecomplex alloc] init];
                                                       rawattr.name = rawname;
                                                       rawattr.value = rawvalue;
                                                       [item.attributes insertafternum:rawattr];
                                                   }
                                               }
                                           }
                                       }
                                   }
                               }
                           }
                       }
                       
                       gettingitem = NO;
                       [[NSNotificationCenter defaultCenter] postNotificationName:notupdateitem object:nil userInfo:[self userinfo]];
                   });
}

#pragma mark public

-(void)getitem
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       if(!item && !gettingitem)
                       {
                           gettingitem = YES;
                           NSString *vars = [NSString stringWithFormat:@"%@", itemid];
                           [cloudreq type:cloudreqtypeitem delegate:self variables:vars];
                       }
                   });
}

-(void)changetitle:(NSString*)_title price:(NSString*)_price address:(NSString*)_address
{
    title = _title;
    price = _price;
    address = _address;
    attr = [[tools sha] resultstring:title price:price address:address];
}

-(void)changeimage:(NSString*)_image
{
    picture = [[moditempicture alloc] init:_image];
}

-(NSDictionary*)userinfo
{
    return @{@"item":self};
}

-(BOOL)equalsuserinfo:(NSDictionary*)_userinfo
{
    return _userinfo[@"item"] == self;
}

#pragma mark -
#pragma mark cloud del

-(void)requestsuccess:(cloudreq*)_request
{
    [self parseitem:_request.response];
}

-(void)request:(cloudreq*)_request error:(NSString*)_error
{
    gettingitem = NO;
    [ctralert alert:_error];
}

@end