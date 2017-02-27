#import "appdel.h"

#define barheight               75
#define celid                   @"cel"
#define colormain               [UIColor colorWithRed:0.9647 green:0.8745 blue:0.1058 alpha:1]
#define colorsecond             [UIColor colorWithRed:0.1137 green:0.447 blue:0.8549 alpha:1]
#define feedsize                21
#define fontname                @"HelveticaNeue-Light"
#define fontboldname            @"HelveticaNeue-Medium"
#define footerid                @"footer"
#define headerid                @"header"
#define menuwidth               200
#define notclosealert           @"closealert"
#define notclosecountryshower   @"closecountryshower"
#define notimagedetailclose     @"imagedetailclose"
#define notupdatemenu           @"updatemenu"
#define notchangeheaderpic      @"changeheaderpic"
#define notimageloaded          @"imageloaded"
#define notimageready           @"imageready"
#define notupdatesearch         @"updatesearch"
#define notbreakswipe           @"breakswipe"
#define notupdateitem           @"updateitem"
#define notupdatestatus         @"updatestatus"
#define notcleansearch          @"cleansearch"
#define notupdatefav            @"updatefav"
#define notupdateresult         @"updateresult"
#define notupdatefilters        @"updatefilters"
#define notupdateprices         @"updateprices"
#define notrestartprices        @"restartprices"
#define notfilterschanged       @"filterschanged"
#define notpurchaseupd          @"purchaseupd"
#define stringdrawing           NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin

extern NSString *documents;
extern NSString *imagesfolder;
extern NSInteger screenwidth;
extern NSInteger screenwidth_2;
extern NSInteger screenheight;
extern NSInteger screenheight_2;
extern CGRect screenrect;
extern apptype applicationtype;
extern ioslevel applicationios;
extern CGFloat resultlblwidth;

@interface updater:NSObject

+(void)launch;

@end