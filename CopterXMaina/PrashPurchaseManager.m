//
//  PrashPurchaseManager.m
//  WordSmitherChallenge
//
//  Created by Prashanth Moorthy on 6/13/14.
//  Copyright (c) 2014 Prash. All rights reserved.
//

// 1
#import "PrashPurchaseManager.h"
#import <StoreKit/StoreKit.h>
#import <time.h>

// 2
@interface PrashPurchaseManager() <SKProductsRequestDelegate,SKPaymentTransactionObserver>
@end

UIAlertView *alert;

@implementation PrashPurchaseManager {
    // 3
    SKProductsRequest * _productsRequest;
    // 4
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

// Add new method
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Product Identifir is %@",productIdentifier);
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:@{@"productName":productIdentifier}];
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}


- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    // 1
    _completionHandler = [completionHandler copy];
    
    // 2
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products. %@",error);
    NSLog(@"\n\n\n Yipee... Prashanth The Request Finished .. Failed... %@.",error);

    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

//- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
//{
//    for (SKPaymentTransaction * transaction in transactions) {
//        switch (transaction.transactionState)
//        {
//            case SKPaymentTransactionStatePurchased:
//                [self completeTransaction:transaction];
//                break;
//            case SKPaymentTransactionStateFailed:
//                [self failedTransaction:transaction];
//                break;
//            case SKPaymentTransactionStateRestored:
//                [self restoreTransaction:transaction];
//            default:
//                break;
//        }
//    };
//}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    
    UIActivityIndicatorView *ind = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];

    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"now we are purchasing");
                alert = [[UIAlertView alloc]initWithTitle: @"Copter Mania" message: @"Processing your request..." delegate: nil cancelButtonTitle: nil otherButtonTitles: nil];
                [ind startAnimating];
                [alert addSubview: ind];
                [alert show];

                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"We got a call back here !!!! ==> Purchase Succesful");
                [alert dismissWithClickedButtonIndex:-1 animated:YES];
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"We got a call back here !!!! ==> Purchase Failed");
                [alert dismissWithClickedButtonIndex:-1 animated:YES];
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"We got a call back here !!!! ==> Purchase Restored");
                [self restoreTransaction:transaction];
            default:
                NSLog(@"We got a call back here !!!! ==> Purchase Default Case");
                [alert dismissWithClickedButtonIndex:-1 animated:YES];
                break;
        }
    };
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    UIActivityIndicatorView *ind = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    
    alert = [[UIAlertView alloc]initWithTitle: @"Copter Mania" message: @"Purchase Was Successful. Thank You." delegate: nil cancelButtonTitle: nil otherButtonTitles: nil];
    [ind startAnimating];
    [alert addSubview: ind];
    [alert show];
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:2];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
    NSLog(@"restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"failedTransaction...");
    UIActivityIndicatorView *ind = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];

    alert = [[UIAlertView alloc]initWithTitle: @"Copter Mania" message: @"Sorry Purchase Failed. Please Try Again Later." delegate: nil cancelButtonTitle: nil otherButtonTitles: nil];
    [ind startAnimating];
    [alert addSubview: ind];
    [alert show];

    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);

    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    [self performSelector:@selector(dismissAlertView:) withObject:alert afterDelay:2];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Purchase Failed" object:nil];
}

-(void)dismissAlertView:(UIAlertView *)alertView{
        [alertView dismissWithClickedButtonIndex:-1 animated:YES];
    }

-(void)restorePastPurchases{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];

}

-(void)restore {

    UIActivityIndicatorView *ind = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];

    NSLog(@"We are now Restoring Past Purchases.... ");
    alert = [[UIAlertView alloc]initWithTitle: @"Copter Mania" message: @"Processing your request..." delegate: nil cancelButtonTitle: nil otherButtonTitles: nil];
    [ind startAnimating];
    [alert addSubview: ind];
    [alert show];
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}




-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    
    NSLog(@"Checking with the app store... Restoring");
    
    UIActivityIndicatorView *ind = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];

    if (!queue.transactions || [queue.transactions count] == 0) {
        
        NSLog(@"Nothing to Restore........");

        //        [self showAlertScreenWithTitle:@"Error Restoring Subscription" message:@"No subscription was found to restore."];
        [alert dismissWithClickedButtonIndex:-1 animated:YES];
        
        alert = [[UIAlertView alloc]initWithTitle: @"Copter Mania" message:@"No subscription was found to restore." delegate: nil cancelButtonTitle: nil otherButtonTitles: nil];
        [ind startAnimating];
        [alert addSubview: ind];
        [alert show];

        
    } else {
        NSLog(@"Found Something to Restore........");

        BOOL didRestore = NO;
        
        for (SKPaymentTransaction *t in queue.transactions) {
            
            if (t.transactionState == SKPaymentTransactionStateRestored || t.transactionState == SKPaymentTransactionStatePurchased) {
                
                didRestore = YES;
            }
        }
        
        if (!didRestore)
        //            [self showAlertScreenWithTitle:@"Error Restoring Subscription" message:@"No subscription was found to restore."];
        [alert dismissWithClickedButtonIndex:-1 animated:YES];
        
        NSLog(@"Resotore Failed. Something to Restore........");
        alert = [[UIAlertView alloc]initWithTitle:@"Error Restoring Subscription" message:@"No Past Purchases To Restore" delegate: nil cancelButtonTitle: nil otherButtonTitles: nil];
        [ind startAnimating];
        [alert addSubview: ind];
        [alert show];

    }
    
    NSLog(@"Getting red of the alert view.... ");
    
    [self performSelector:@selector(dismissAlertView) withObject:nil afterDelay:2.0];
    
}


-(void)dismissAlertView{
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}

@end
