//
//  PrashWordSmithPurchaseManager.m
//  WordSmitherChallenge
//
//  Created by Prashanth Moorthy on 6/13/14.
//  Copyright (c) 2014 Prash. All rights reserved.
//

#import "PrashWordSmithPurchaseManager.h"

@implementation PrashWordSmithPurchaseManager

+ (PrashWordSmithPurchaseManager *)sharedInstance {
    static dispatch_once_t once;
    static PrashWordSmithPurchaseManager * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"Copter_Maina_Remove_Ads",
                                      @"copter_buy_2000_coins",
                                      @"copter_buy_500_coins",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
