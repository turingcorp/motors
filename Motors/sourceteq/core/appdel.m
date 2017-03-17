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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger ttl = [[defaults valueForKey:@"ttl"] integerValue];
    
    if(ttl > 5)
    {
        ttl = 0;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 3000), dispatch_get_main_queue(),
                       ^
                       {
                           [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ttl_title", nil) message:NSLocalizedString(@"ttl_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ttl_cancel", nil) otherButtonTitles:NSLocalizedString(@"ttl_rate", nil), nil] show];
                       });
    }
    else
    {
        ttl++;
    }
    
    [defaults setValue:@(ttl) forKey:@"ttl"];
}

-(void)applicationWillTerminate:(UIApplication*)_app
{
}

#pragma mark -
#pragma mark alert del

-(void)alertView:(UIAlertView*)alert clickedButtonAtIndex:(NSInteger)index
{
    if(index)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@(-6) forKey:@"ttl"];
        
        NSURL *url = [NSURL URLWithString:
                      @"https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1052383125&type=Purple+Software&mt=8"];
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
