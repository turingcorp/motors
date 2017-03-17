#import "appdel.h"

@implementation appdel
{
    UIWindow *window;
}

-(BOOL)application:(UIApplication*)_app didFinishLaunchingWithOptions:(NSDictionary*)_options
{
    window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [window makeKeyAndVisible];
    [window setRootViewController:[ctrmain sha]];
    
    [updater launch];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[skman sha]];
    
    return YES;
}

-(void)applicationWillResignActive:(UIApplication*)_app
{
}

-(void)applicationDidEnterBackground:(UIApplication*)_app
{
}

-(void)applicationWillEnterForeground:(UIApplication*)_app
{
}

-(void)applicationDidBecomeActive:(UIApplication*)_app
{
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
}

-(void)applicationWillTerminate:(UIApplication*)_app
{
}

@end
