#import "skman.h"

@implementation skman
{
    NSNotification *notification;
}

@synthesize error;

+(skman*)sha
{
    static skman *sha;
    static dispatch_once_t once;
    dispatch_once(&once,
                  ^(void)
                  {
                      sha = [[self alloc] init];
                  });
    return sha;
}

-(skman*)init
{
    self = [super init];
    notification = [NSNotification notificationWithName:notpurchaseupd object:nil];
    
    return self;
}

#pragma mark functionality

-(void)sendnotification
{
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

#pragma mark public

-(void)checkavailabilities
{
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[[modperks sha] asaset]];
    request.delegate = self;
    [request start];
}

-(void)purchase:(SKProduct*)_product
{
    [[SKPaymentQueue defaultQueue] addPayment:[SKMutablePayment paymentWithProduct:_product]];
}

-(void)restorepurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark -
#pragma mark sk del

-(void)request:(SKRequest*)_request didFailWithError:(NSError*)_error
{
    error = NSLocalizedString(@"error_connectionfailed", nil);
    [self sendnotification];
}

-(void)productsRequest:(SKProductsRequest*)_request didReceiveResponse:(SKProductsResponse*)_response
{
    NSArray *prods = _response.products;
    NSInteger qty = prods.count;
    
    for(NSInteger i = 0; i < qty; i++)
    {
        [[modperks sha] loadperk:prods[i]];
    }
    
    [self sendnotification];
}

-(void)paymentQueue:(SKPaymentQueue*)_queue updatedTransactions:(NSArray*)_transactions
{
    NSInteger qty = _transactions.count;
    for(NSInteger i = 0; i < qty; i++)
    {
        SKPaymentTransaction *tran = _transactions[i];
        NSString *prodid = tran.payment.productIdentifier;
        
        switch(tran.transactionState)
        {
            case SKPaymentTransactionStateDeferred:
                
                [[modperks sha] productdeferred:prodid];
                
                break;
                
            case SKPaymentTransactionStateFailed:
                
                [[modperks sha] productcanceled:prodid];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                
                break;
                
            case SKPaymentTransactionStatePurchased:
                
                [[modperks sha] productpurchased:prodid];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                
                break;
                
            case SKPaymentTransactionStatePurchasing:
                
                [[modperks sha] productpurchasing:prodid];
                
                break;
                
            case SKPaymentTransactionStateRestored:
                
                [[modperks sha] productpurchased:prodid];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                
                break;
        }
    }
    
    [self sendnotification];
}

-(void)paymentQueue:(SKPaymentQueue*)_queue removedTransactions:(NSArray*)_transactions
{
    NSInteger qty = _transactions.count;
    for(NSInteger i = 0; i < qty; i++)
    {
        SKPaymentTransaction *tran = _transactions[i];
        NSString *prodid = tran.payment.productIdentifier;
        
        switch(tran.transactionState)
        {
            case SKPaymentTransactionStateDeferred:
                
                [[modperks sha] productdeferred:prodid];
                
                break;
                
            case SKPaymentTransactionStateFailed:
                
                [[modperks sha] productcanceled:prodid];
                
                break;
                
            case SKPaymentTransactionStatePurchased:
                
                [[modperks sha] productpurchased:prodid];
                
                break;
                
            case SKPaymentTransactionStatePurchasing:
                
                [[modperks sha] productpurchasing:prodid];
                
                break;
                
            case SKPaymentTransactionStateRestored:
                
                [[modperks sha] productpurchased:prodid];
                
                break;
        }
    }
    
    [self sendnotification];
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue*)_queue
{
    [self sendnotification];
}

-(void)paymentQueue:(SKPaymentQueue*)_queue restoreCompletedTransactionsFailedWithError:(NSError*)_error
{
    error = _error.localizedDescription;
    [self sendnotification];
}

@end