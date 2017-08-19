//
//  AppDelegate.h
//  CopterXMaina
//
//  Created by Prashanth Moorthy on 3/10/15.
//  Copyright (c) 2015 The App Mentor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <Chartboost/Chartboost.h>
#import <Chartboost/CBNewsfeed.h>
#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>
#import "GamePlayScene.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,ChartboostDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) GamePlayScene *theGamePlayScene;

@end

