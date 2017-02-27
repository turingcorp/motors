#import "appdel.h"

@interface skman:NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate>

+(skman*)sha;
-(void)checkavailabilities;
-(void)purchase:(SKProduct*)_product;
-(void)restorepurchases;

@property(copy, nonatomic)NSString *error;

@end