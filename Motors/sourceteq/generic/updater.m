#import "updater.h"

@implementation updater

NSString *documents;
NSString *imagesfolder;
NSInteger screenwidth;
NSInteger screenwidth_2;
NSInteger screenheight;
NSInteger screenheight_2;
CGRect screenrect;
apptype applicationtype;
ioslevel applicationios;
CGFloat resultlblwidth;

+(void)launch
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       [updater update];
                       [[modsites sha] count];
                       [[modinitems sha] refresh];
                       [[modsettings sha] loadpreferences];
                       
                       NSMutableDictionary *totalperks = [NSMutableDictionary dictionary];
                       [totalperks addEntriesFromDictionary:[modsettings sha].perks];
                       
                       NSArray *defperks = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"perks" withExtension:@"plist"]];
                       NSInteger qtyperks = defperks.count;
                       BOOL perkschanged = NO;
                       
                       for(NSInteger i = 0; i < qtyperks; i++)
                       {
                           NSDictionary *rawperk = defperks[i];
                           NSMutableDictionary *perkdict = [NSMutableDictionary dictionary];
                           NSString *perkid = rawperk[@"id"];
                           
                           if(!totalperks[perkid])
                           {
                               perkschanged = YES;
                               perkdict[@"title"] = rawperk[@"title"];
                               perkdict[@"descr"] = rawperk[@"descr"];
                               perkdict[@"status"] = @(perkstatusnew);
                               totalperks[perkid] = perkdict;
                           }
                       }
                       
                       if(perkschanged)
                       {
                           [modsettings sha].perks = totalperks;
                           [[modsettings sha] savepreferences];
                       }
                       
                       [[modperks sha] refresh];
                       
                       dispatch_async(dispatch_get_main_queue(),
                                      ^(void)
                                      {
                                          [vimaster sha].loca = [[locater alloc] init];
                                      });
                   });
}

#pragma mark private

+(void)update
{
    documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSDictionary *defaults = [tools defaultdict];
    NSUserDefaults *properties = [NSUserDefaults standardUserDefaults];
    NSInteger def_version = [defaults[@"version"] integerValue];
    NSInteger pro_version = [[properties valueForKey:@"version"] integerValue];
    
    if(def_version != pro_version)
    {
        [properties setValue:@(def_version) forKeyPath:@"version"];        
        
        if(pro_version < 101)
        {
            [updater firsttime:defaults];
            [updater changedatabase:properties defaults:defaults];
        }
    }
    
    NSString *relativedb = [properties valueForKey:@"dbname"];
    imagesfolder = [properties valueForKey:@"imagesfolder"];
    dbname = [documents stringByAppendingPathComponent:relativedb];
    imagesfolder = [documents stringByAppendingPathComponent:imagesfolder];
    
    [updater environment];
}

+(void)environment
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    screenwidth = size.width;
    screenheight = size.height;
    
    switch([UIDevice currentDevice].userInterfaceIdiom)
    {
        case UIUserInterfaceIdiomPad:
            
            applicationtype = apptypepad;
            
            if(screenwidth < screenheight)
            {
                screenwidth = size.height;
                screenheight = size.width;
            }
            
            break;
        default:
            
            applicationtype = apptypephone;
            
            if(screenwidth > screenheight)
            {
                screenwidth = size.height;
                screenheight = size.width;
            }
            
            break;
    }
    
    NSInteger iosint = [UIDevice currentDevice].systemVersion.integerValue;
    
    if(iosint <= 7)
    {
        applicationios = ioslevel7;
    }
    else if(iosint <= 8)
    {
        applicationios = ioslevel8;
    }
    else
    {
        applicationios = ioslevel9;
    }
    
    screenwidth_2 = screenwidth / 2;
    screenheight_2 = screenheight / 2;
    screenrect = CGRectMake(0, 0, screenwidth, screenheight);
    resultlblwidth = screenwidth - 20;
}

+(void)changedatabase:(NSUserDefaults*)_properties defaults:(NSDictionary*)_defaults
{
    NSString *bundledb = _defaults[@"dbname"];
    NSString *dbfolder = _defaults[@"dbfolder"];
    NSString *relativedb = [dbfolder stringByAppendingPathComponent:bundledb];
    imagesfolder = _defaults[@"imagesfolder"];
    [_properties setValue:relativedb forKey:@"dbname"];
    [_properties setValue:imagesfolder forKey:@"imagesfolder"];
    
    dbfolder = [documents stringByAppendingPathComponent:dbfolder];
    imagesfolder = [documents stringByAppendingPathComponent:imagesfolder];
    dbname = [documents stringByAppendingPathComponent:relativedb];
    NSString *originaldb = [[NSBundle mainBundle] pathForResource:bundledb ofType:@""];
    [moddirs create:[NSURL fileURLWithPath:dbfolder]];
    [moddirs create:[NSURL fileURLWithPath:imagesfolder]];
    [moddirs copy:originaldb to:dbname];
}

+(void)firsttime:(NSDictionary*)_plist
{
    NSNumber *appid = _plist[@"appid"];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:@0 forKey:@"site"];
    
    NSUserDefaults *userdef = [NSUserDefaults standardUserDefaults];
    
    [userdef removePersistentDomainForName:NSGlobalDomain];
    [userdef removePersistentDomainForName:NSArgumentDomain];
    [userdef removePersistentDomainForName:NSRegistrationDomain];
    [userdef setValue:appid forKey:@"appid"];
    [userdef setValue:[[NSUUID UUID] UUIDString] forKey:@"uuid"];
    [userdef setValue:dictionary forKey:@"settings"];
    [userdef synchronize];
}

@end