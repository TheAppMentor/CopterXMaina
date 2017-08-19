//
//  GamePlayScene.h
//  CopterXMaina
//
//  Created by Prashanth Moorthy on 3/10/15.
//  Copyright (c) 2015 The App Mentor. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "parallaxScrollingBgNode.h"
#import "ScrollingGroundNode.h"
#import "Copter.h"
#import "scoreNode.h"
//#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "GameScene.h"
#import "storeScene.h"
#import "PrashWordSmithPurchaseManager.h"
#import <Chartboost/Chartboost.h>

@interface GamePlayScene : SKScene <UIGestureRecognizerDelegate,SKPhysicsContactDelegate,ChartboostDelegate>

@property (strong,nonatomic) NSMutableArray *bombTexture;
@property (strong,nonatomic) NSMutableArray *coinTexture;

-(void)chartBoostAdLoadFailed;
-(void)rewardUser50CoinsAndRestart;
-(void)userCancelledVideoPromptToBuy;


@end
