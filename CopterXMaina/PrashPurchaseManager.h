//
//  PrashPurchaseManager.h
//  WordSmitherChallenge
//
//  Created by Prashanth Moorthy on 6/13/14.
//  Copyright (c) 2014 Prash. All rights reserved.
//

#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface PrashPurchaseManager : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restorePastPurchases;
- (void)restore;

@end


