//
//  GameCenterHelper.h
//  CopterXMaina
//
//  Created by Prashanth Moorthy on 5/27/15.
//  Copyright (c) 2015 The App Mentor. All rights reserved.
//

#import <Foundation/Foundation.h>
@import GameKit;

extern NSString *const PresentAuthenticationViewController;

@interface GameCenterHelper : NSObject <GKGameCenterControllerDelegate>

@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError;

+ (instancetype)sharedGameKitHelper;

- (void)authenticateLocalPlayer;

- (void)reportScore:(int64_t)score forLeaderboardID:(NSString*)leaderboardID;
- (void)showGKGameCenterViewController: (UIViewController *)viewController;


@property (strong,nonatomic) GKAchievement *collect50GoldAchievement;
@property (strong,nonatomic) GKAchievement *collect100GoldAchievement;
@property (strong,nonatomic) GKAchievement *score1000Achievement;
@property (strong,nonatomic) GKAchievement *score2000Achievement;

@end
