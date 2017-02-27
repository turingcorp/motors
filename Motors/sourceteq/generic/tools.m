#import "tools.h"

@implementation tools
{
    NSDateFormatter *apidateformatter;
    NSDictionary *attrresulttitle;
    NSDictionary *attrresultprice;
    NSDictionary *attrresultaddress;
    NSNumberFormatter *formatter;
    NSNumberFormatter *formattercurrencylocal;
    NSNumberFormatter *formattercurrencyusd;
    CFStringRef stringref;
    CGSize resultsize;
}

@synthesize motion;
@synthesize comparerfilter;

+(tools*)sha
{
    static tools *sha;
    static dispatch_once_t once;
    dispatch_once(&once,
                  ^(void)
                  {
                      sha = [[self alloc] init];
                  });
    return sha;
}

+(void)dataexport:(NSArray*)_array view:(UIView*)_view
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    UIActivityViewController *act = [[UIActivityViewController alloc] initWithActivityItems:_array applicationActivities:nil];
    
    if([UIPopoverPresentationController class])
    {
        act.popoverPresentationController.sourceView = _view;
        act.popoverPresentationController.sourceRect = CGRectMake((_view.frame.size.width / 2) - 2, _view.frame.size.height / 2, 1, 1);
        act.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown;
    }
    
    [[ctrmain sha] presentViewController:act animated:YES completion:nil];
}

+(void)rateapp
{
    NSUserDefaults *properties = [NSUserDefaults standardUserDefaults];
    
    [[UIApplication sharedApplication] openURL:
     [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", [properties valueForKey:@"appid"]]]];
}

+(NSDictionary*)defaultdict
{
    return [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defs" ofType:@"plist"]];
}

+(NSInteger)timestamp
{
    return [NSDate date].timeIntervalSince1970;
}

+(NSString*)parsestring:(id)_value
{
    NSString *str = @"";
    
    if([tools notnullorempty:_value])
    {
        str = _value;
    }
    
    return str;
}

+(NSString*)parsestringvalid:(id)_value
{
    NSString *str = [tools parsestring:_value];
    
    if(!str.length)
    {
        str = nil;
    }
    
    return str;
}

+(NSNumber*)parsenum:(id)_value
{
    NSNumber *num = @0;
    
    if([tools notnullorempty:_value])
    {
        num = _value;
    }
    
    return num;
}

+(BOOL)notnullorempty:(id)_value
{
    return _value && ![_value isKindOfClass:[NSNull class]];
}

#pragma mark -

-(tools*)init
{
    self = [super init];
    
    stringref = (CFStringRef)@"!*'();:@&=+$,/?%#[]";
    formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    apidateformatter = [[NSDateFormatter alloc] init];
    [apidateformatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [apidateformatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'000Z'"];
    
    formattercurrencylocal = [[NSNumberFormatter alloc] init];
    [formattercurrencylocal setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formattercurrencylocal setCurrencySymbol:@"$ "];
    
    formattercurrencyusd = [[NSNumberFormatter alloc] init];
    [formattercurrencyusd setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formattercurrencyusd setCurrencySymbol:@"US$ "];
    
    attrresulttitle = @{NSFontAttributeName:[UIFont fontWithName:fontname size:13], NSForegroundColorAttributeName:[UIColor colorWithWhite:0.1 alpha:1]};
    attrresultaddress = @{NSFontAttributeName:[UIFont fontWithName:fontname size:11], NSForegroundColorAttributeName:[UIColor colorWithWhite:0.1 alpha:1]};
    attrresultprice = @{NSFontAttributeName:[UIFont fontWithName:fontname size:17], NSForegroundColorAttributeName:[UIColor colorWithWhite:0.6 alpha:1]};
    resultsize = CGSizeMake(resultlblwidth, 1000);
    
    comparerfilter = ^NSComparisonResult(modfilterelement *comp1, modfilterelement *comp2)
    {
        return [comp1.valuename compare:comp2.valuename];
    };
    
    return self;
}

#pragma mark public

-(NSString*)urlencode:(NSString*)_string
{
    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(nil, (__bridge CFStringRef)_string, nil, stringref, kCFStringEncodingUTF8);
}

-(NSString*)numbertostring:(NSNumber*)_number
{
    return [formatter stringFromNumber:_number];
}

-(NSNumber*)numberfromstring:(NSString*)_string
{
    return [formatter numberFromString:_string];
}

-(NSString*)pricetostring:(NSNumber*)_number
{
    return [formattercurrencylocal stringFromNumber:_number];
}

-(NSString*)pricetostringusd:(NSNumber*)_number
{
    return [formattercurrencyusd stringFromNumber:_number];
}

-(NSAttributedString*)resultstring:(NSString*)_title price:(NSString*)_price address:(NSString*)_address
{
    NSMutableAttributedString *mut = [[NSMutableAttributedString alloc] init];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:_price attributes:attrresultprice]];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attrresultprice]];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:_title attributes:attrresulttitle]];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attrresulttitle]];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:_address attributes:attrresultaddress]];
    
    return mut;
}

-(NSDate*)stringtodate:(NSString*)_string
{
    return [apidateformatter dateFromString:_string];
}

@end