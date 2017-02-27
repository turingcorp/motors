#import "analytics.h"

NSString *const analyticsId = @"Motors";
NSString *const analyticsKey = @"MOTORS";
NSString *const kKeyUsername = @"username";
NSString *const kKeyScreen = @"screen";
NSString *const kMofilerUrl = @"mofiler.com";

@implementation analytics
{
    NSMutableDictionary *tracked;
    NSString *userName;
}

+(instancetype)singleton
{
    static analytics *single;
    static dispatch_once_t once;
    dispatch_once(&once, ^(void) { single = [[self alloc] init]; });
    
    return single;
}

-(instancetype)init
{
    self = [super init];
    
    tracked = [NSMutableDictionary dictionary];
    userName = [NSUUID UUID].UUIDString;
    
    return self;
}

#pragma mark private

-(NSString*)countFor:(NSString*)key
{
    NSNumber *trackCounter = tracked[key];
    
    if (trackCounter == nil)
    {
        trackCounter = @1;
    }
    else
    {
        trackCounter = @(trackCounter.integerValue + 1);
    }
    
    tracked[key] = trackCounter;
    
    NSString *counterString = [NSString stringWithFormat:@"%@",
                               trackCounter];
    
    return counterString;
}

-(void)inject:(NSDictionary*)dictionary
{
    [self.mofiler injectValueWithNewValue:dictionary expirationDateInMilliseconds:nil];
    [self.mofiler flushDataToMofiler];
}

#pragma mark public

-(void)start
{
    NSMutableDictionary *identity = [NSMutableDictionary dictionary];
    identity[kKeyUsername] = @"defaultjohn";
    identity[@"email"] = @"default@mail.com";
    identity[@"name"] = @"default";
    
    NSLog(@"username %@", userName);
    
    self.mofiler = [Mofiler sharedInstance];
    [self.mofiler initializeWithAppKey:analyticsKey appName:analyticsId useLoc:true useAdvertisingId:true];
    [self.mofiler addIdentityWithIdentity:@{@"username":@"defaultJohn"}];
    [self.mofiler addIdentityWithIdentity:@{@"email":@"default@mail.com"}];
    [self.mofiler addIdentityWithIdentity:@{@"name":@"default"}];
    self.mofiler.delegate = self;
    self.mofiler.url = kMofilerUrl;
    self.mofiler.useVerboseContext = false;
    self.mofiler.debugLogging = false;
    [self.mofiler flushDataToMofiler];
}

-(void)screen:(NSString*)name
{
    NSString *screenName = [NSString stringWithFormat:@"%@.%@",
                            kKeyScreen,
                            name];
    NSString *countString = [self countFor:screenName];
    NSDictionary *log = @{screenName:countString};
    [self inject:log];
}

#pragma mark -
#pragma mark mofiler del

-(void)responseValueWithKey:(NSString *)key identityKey:(NSString *)identityKey identityValue:(NSString *)identityValue value:(NSDictionary<NSString *,id> *)value
{
    
#if DEBUG
    
    NSLog(@"analytics response: %@", value);
    
#endif
    
}

-(void)errorOcurredWithError:(NSString *)error userInfo:(NSDictionary<NSString *,NSString *> *)userInfo
{
    
#if DEBUG
    
    NSLog(@"analytics error: %@", error);
    NSLog(@"%@", userInfo);
    
#endif
    
}

@end
