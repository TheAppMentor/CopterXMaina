//
//  AppDelegate.m
//  CopterXMaina
//
//  Created by Prashanth Moorthy on 3/10/15.
//  Copyright (c) 2015 The App Mentor. All rights reserved.
//

#import "AppDelegate.h"
#import "PrashWordSmithPurchaseManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSDictionary *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];

    if (notification) {
        NSLog(@"App Did Finish Launching : %@",notification);
        if ([notification objectForKey:@"bonusCoins"]) {
            NSInteger currentCoinCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"coinCount"];
            if ([[notification objectForKey:@"bonusCoins"] isKindOfClass:[NSNumber class]]) {
                
                NSInteger updatedCoinCount = currentCoinCount + [[notification objectForKey:@"bonusCoins"] integerValue];
                [[NSUserDefaults standardUserDefaults] setInteger:updatedCoinCount forKey:@"coinCount"];
            }
        }
        
        if ([notification objectForKey:@"ShowAdsDuringGame"]) {
            if ([[notification objectForKey:@"ShowAdsDuringGame"] integerValue] == 1) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShowAdsDuringGame"];
            }else if ([[notification objectForKey:@"ShowAdsDuringGame"] integerValue] == 0){
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ShowAdsDuringGame"];
            }
        }
    }
    

//    for (NSString *theKey in [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys]) {
//        NSLog(@"The Key is %@",theKey);
//    }
    
    // If First Launch set the Music to ON :
    if([[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"musicStatus"]){
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"ON" forKey:@"musicStatus"];
    }
    
    // Check with AppStore if the User has removed Ads.
    
    if(![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"CopterRemoveAllAds"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"CopterRemoveAllAds"];
    }
    
    // Initially Give the user 1000 coins.
    if (![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"coinCount"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:1000 forKey:@"coinCount"];
    }
    
    // Set the Show Ads During Game Flag to NO. During first launch.
    if (![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"ShowAdsDuringGame"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShowAdsDuringGame"];
    }
    
    // Set up ChartBoost.
    // Initialize the Chartboost library
    [Chartboost startWithAppId:@"5598c63b0d6025320d54e518"
                  appSignature:@"125bf1c9e17fff5da9b77aaaf97fcb2cecae4918"
                      delegate:self];
    
    [Chartboost setShouldRequestInterstitialsInFirstSession:NO];

    // Set up Parse.
    [Parse setApplicationId:@"DrUpRQYgj9HsgxSi5m9wH0T9OH0PvXG7pOzK1kKY"
                  clientKey:@"7cJA8HxW0wsw4mvJXRYNL20m8nds7w6tsNYk17Du"];
        
    // Register for Push Notitications
//    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
//                                                    UIUserNotificationTypeBadge |
//                                                    UIUserNotificationTypeSound);
    
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
//                                                                             categories:nil];
    
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    
    //return YES;
//#warning Prashnth this looks dangerous. Check it out.
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"=================>   Application Did REMOTE NOTIFCATOIn Launching Got Called");
    
    NSLog(@"App Did Receive LocAL NOTIFCATION : %@",userInfo);

    
    if ([userInfo objectForKey:@"bonusCoins"]) {
        
        NSInteger currentCoinCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"coinCount"];
        if ([[userInfo objectForKey:@"bonusCoins"] isKindOfClass:[NSNumber class]]) {
            
            NSInteger updatedCoinCount = currentCoinCount + [[userInfo objectForKey:@"bonusCoins"] integerValue];
            [[NSUserDefaults standardUserDefaults] setInteger:updatedCoinCount forKey:@"coinCount"];
        }
        
    
    }
    
    if ([userInfo objectForKey:@"ShowAdsDuringGame"]) {
        if ([[userInfo objectForKey:@"ShowAdsDuringGame"] integerValue] == 1) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ShowAdsDuringGame"];
        }else if ([[userInfo objectForKey:@"ShowAdsDuringGame"] integerValue] == 0){
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ShowAdsDuringGame"];
        }
    }

   // [PFPush handlePush:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}



-(void)didFailToLoadRewardedVideo:(CBLocation)location withError:(CBLoadError)error{
    NSLog(@"The Video Load From ChartBoost Failed with the Error %lu",(unsigned long)error);
    //[self.theGamePlayScene chartBoostAdLoadFailed];
}

- (void)didDismissRewardedVideo:(CBLocation)location{
    NSLog(@"User Dismissed the Reward Video");
}

-(void)didCloseRewardedVideo:(CBLocation)location{
    NSLog(@"User Did Close the Reward Video");
    [self.theGamePlayScene userCancelledVideoPromptToBuy];
    
}


- (void)didCompleteRewardedVideo:(CBLocation)location
                      withReward:(int)reward{

    NSLog(@"Now I am rewarding the User");
    [self.theGamePlayScene rewardUser50CoinsAndRestart];
}







@end
