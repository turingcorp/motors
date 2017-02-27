typedef enum
{
    apptypephone,
    apptypepad
}apptype;

typedef enum
{
    ioslevel7,
    ioslevel8,
    ioslevel9
}ioslevel;

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import <Mofiler/Mofiler-Swift.h>
#import <StoreKit/StoreKit.h>
#import "analytics.h"
#import "timerbg.h"
#import "db.h"
#import "mod.h"
#import "ctr.h"
#import "generic.h"
#import "vi.h"
#import "cloud.h"
#import "sk.h"

@interface appdel:UIResponder<UIApplicationDelegate>

@end
