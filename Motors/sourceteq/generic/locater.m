#import "locater.h"

@implementation locater

@synthesize loc;

-(locater*)init
{
    self = [super init];
    
    loc = [[locman alloc] init];
    [loc setDelegate:self];
    
    if(applicationios == ioslevel7)
    {
        [loc startUpdatingLocation];
    }
    
    return self;
}

-(void)dealloc
{
    [loc stopUpdatingLocation];
}

#pragma mark functionality

-(void)locationfound:(CLLocation*)_location
{
    [loc stopUpdatingLocation];
    
    [[[CLGeocoder alloc] init] reverseGeocodeLocation:_location completionHandler:
     ^(NSArray<CLPlacemark*>* _Nullable _placemarks, NSError* _Nullable _error)
    {
        if(_error)
        {
            [ctralert alert:_error.localizedDescription];
        }
        else if(_placemarks && _placemarks.count)
        {
            CLPlacemark *mark = _placemarks[0];
            NSString *country = mark.addressDictionary[(NSString*)kABPersonAddressCountryKey];
            country = country.lowercaseString;
            country = [country stringByReplacingOccurrencesOfString:@"á" withString:@"a"];
            country = [country stringByReplacingOccurrencesOfString:@"é" withString:@"e"];
            country = [country stringByReplacingOccurrencesOfString:@"í" withString:@"i"];
            country = [country stringByReplacingOccurrencesOfString:@"ó" withString:@"o"];
            country = [country stringByReplacingOccurrencesOfString:@"ú" withString:@"u"];
            NSInteger siteindex = [[modsites sha] siteforname:country];
            
            if(siteindex >= 0)
            {
                [[modsettings sha] changecountry:siteindex];
                [vicountryshower showcurrent];
            }
            else
            {
                [ctralert alert:NSLocalizedString(@"error_nocountry", nil)];
            }
        }
        else
        {
            [ctralert alert:NSLocalizedString(@"error_nolocation", nil)];
        }
        
        [self finished];
    }];
}

-(void)finished
{
    loc = nil;
    
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [[vimaster sha] firstload];
                   });
}

-(void)failedlocation
{
    [ctralert alert:NSLocalizedString(@"error_nolocation", nil)];
    [self finished];
}

#pragma mark -
#pragma mark location del

-(void)locationManager:(CLLocationManager*)_manager didChangeAuthorizationStatus:(CLAuthorizationStatus)_status
{
    if(_status == kCLAuthorizationStatusAuthorizedAlways || _status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [self locationfound:_manager.location];
    }
    else if(_status == kCLAuthorizationStatusDenied)
    {
        [self failedlocation];
    }
}

-(void)locationManager:(CLLocationManager*)_manager didFailWithError:(NSError*)_error
{
    [self failedlocation];
}

-(void)locationManager:(CLLocationManager*)_manager didUpdateLocations:(NSArray<CLLocation*>*)_locations
{
    if(_locations.count)
    {
        CLLocation *location = _locations[0];
        
        [self locationfound:location];
    }
}

@end