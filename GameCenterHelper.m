//
//  GameCenterHelper.m
//  CopterXMaina
//
//  Created by Prashanth Moorthy on 5/27/15.
//  Copyright (c) 2015 The App Mentor. All rights reserved.
//

#import "GameCenterHelper.h"

NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";

@implementation GameCenterHelper{
    BOOL _enableGameCenter;
}


+ (instancetype)sharedGameKitHelper {
    static GameCenterHelper *sharedGameKitHelper; static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[GameCenterHelper alloc] init];
    });
    return sharedGameKitHelper;
}


- (id)init {
    self = [super init];
    if (self) {
        _enableGameCenter = YES;
    }
    return self;
}

- (void)authenticateLocalPlayer {
    //1
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    //2
    localPlayer.authenticateHandler =
    ^(UIViewController *viewController, NSError *error) {
        //3
        [self setLastError:error];
        if(viewController != nil) { //4
            [self setAuthenticationViewController:viewController]; } else if([GKLocalPlayer localPlayer].isAuthenticated) {
                //5_enableGameCenter = YES; } else {
                //6
                _enableGameCenter = NO; }
    }; }


- (void)setAuthenticationViewController: (UIViewController *)authenticationViewController{

    if (authenticationViewController != nil) {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter] postNotificationName:PresentAuthenticationViewController object:self];
    }
}

- (void)setLastError:(NSError *)error {
            _lastError = [error copy]; if (_lastError) {
            NSLog(@"GameKitHelper ERROR: %@", [[_lastError userInfo] description]);
            }
}

- (void)reportScore:(int64_t)score forLeaderboardID:(NSString *)leaderboardID
{
    if (!_enableGameCenter) {
        NSLog(@"Local play is not authenticated"); }
    //1
    GKScore *scoreReporter = [[GKScore alloc]
                              initWithLeaderboardIdentifier:leaderboardID]; scoreReporter.value = score; scoreReporter.context = 0;
    NSArray *scores = @[scoreReporter];
    //2
    [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
        [self setLastError:error]; }];
}

- (void)showGKGameCenterViewController: (UIViewController *)viewController {
    if (!_enableGameCenter) { NSLog(@"Local play is not authenticated");
    }
    
    GKGameCenterViewController *gameCenterViewController = [[GKGameCenterViewController alloc] init];
    
    gameCenterViewController.gameCenterDelegate = self;
    
    [viewController presentViewController:gameCenterViewController animated:YES completion:nil];
    
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    // Score Achievement is Complete.
    if ([keyPath isEqualToString:@"roundScore"]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] integerValue] == 1000) {
            [self updateAchievement1000Score];
        }
        if ([[change objectForKey:NSKeyValueChangeNewKey] integerValue] == 2000) {
            [self updateAchievement2000Score];
        }
    }
    
    // Collect 50 Achievement is Complete.
    if ([keyPath isEqualToString:@"roundCoinCollected"]) {
        if ([[change objectForKey:NSKeyValueChangeNewKey] integerValue] == 50) {
            [self updateAchivement50CoinsCollected];
        }
        if ([[change objectForKey:NSKeyValueChangeNewKey] integerValue] == 100) {
            [self updateAchivement100CoinsCollected];
        }
    }
}


-(void)updateAchivement50CoinsCollected{
    
    self.collect50GoldAchievement = [[GKAchievement alloc] initWithIdentifier:@"Collect_50_Coins_Single_Game"];
    self.collect50GoldAchievement.percentComplete = 100.0;
    
    NSArray *achievements = @[self.collect50GoldAchievement];
    
    [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    
    NSLog(@"Achivemnet 50 Coins !!!!!!!!");
}


-(void)updateAchivement100CoinsCollected{
    
    self.collect100GoldAchievement = [[GKAchievement alloc] initWithIdentifier:@"Collect_100_Coins_Single_Game"];
    self.collect100GoldAchievement.percentComplete = 100.0;
    
    NSArray *achievements = @[self.collect100GoldAchievement];
    
    [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    
    NSLog(@"Achivemnet 100 Coins !!!!!!!!");
}


-(void)updateAchievement1000Score{
    
    //        Collect_50_Coins_Single_Game
    //        Collect_100_Coins_Single_Game
    //        Score_1000_Single_Game
    //        Score_2000_Single_Game
    
    self.score1000Achievement = [[GKAchievement alloc] initWithIdentifier:@"Score_1000_Single_Game"];
    self.score1000Achievement.percentComplete = 100.0;

    NSArray *achievements = @[self.score1000Achievement];
    
    [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    NSLog(@"Achivemnet 100 Distance !!!!!!!!");

}

-(void)updateAchievement2000Score{
    
    //        Collect_50_Coins_Single_Game
    //        Collect_100_Coins_Single_Game
    //        Score_1000_Single_Game
    //        Score_2000_Single_Game
    
    self.score2000Achievement = [[GKAchievement alloc] initWithIdentifier:@"Score_2000_Single_Game"];
    self.score2000Achievement.percentComplete = 100.0;
    
    NSArray *achievements = @[self.score2000Achievement];
    
    [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
    NSLog(@"Achivemnet 2000 Distance !!!!!!!!");
}




@end
