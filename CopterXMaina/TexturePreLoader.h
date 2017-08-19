//
//  TexturePreLoader.h
//  CopterXMaina
//
//  Created by Prashanth Moorthy on 3/21/15.
//  Copyright (c) 2015 The App Mentor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "GameViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <Chartboost/Chartboost.h>

@interface TexturePreLoader : NSObject

@property (strong,nonatomic) NSString *textureDimensionLoaded;

@property (strong,nonatomic) SKTexture *staticBackgroundTexture;
@property (strong,nonatomic) SKTexture *mainMenuBoardTexture;
@property (strong,nonatomic) SKTexture *mainMenuPlayButton;
@property (strong,nonatomic) SKTexture *settingsRoundButton;
@property (strong,nonatomic) SKTexture *storeRoundButton;
@property (strong,nonatomic) SKTexture *rateUsRoundButton;
@property (strong,nonatomic) SKTexture *likeUsFaceBookRoundButton;
@property (strong,nonatomic) SKTexture *helpRoundButton;

@property (strong,nonatomic) NSMutableArray *arrayOfCopterIdleTextures;
@property (strong,nonatomic) NSMutableArray *arrayOfCopterCollisionTextures;
@property (strong,nonatomic) NSMutableArray *arrayOfCopterGameOverTextures;

@property (strong,nonatomic) NSMutableArray *arrayOfEnvironmentCoinTextures;
@property (strong,nonatomic) NSMutableArray *arrayOfEnvironmentBombTextures;
@property (strong,nonatomic) NSMutableArray *arrayOfEnvironmentSomkeTextures;
@property (strong,nonatomic) NSMutableArray *arrayOfObstaclesTextures;

@property (strong,nonatomic) AVAudioPlayer *backgroundMusicPlayer;
@property (strong,nonatomic) AVAudioPlayer *coinCollectedSoundPlayer;
@property (strong,nonatomic) AVAudioPlayer *copterCrashSoundPlayer;

@property (strong,nonatomic) SKTexture *backgroundLayerTexture1;
@property (strong,nonatomic) SKTexture *backgroundLayerTexture2;
@property (strong,nonatomic) SKTexture *backgroundLayerTexture3;
@property (strong,nonatomic) SKTexture *backgroundLayerTexture4;
@property (strong,nonatomic) SKTexture *backgroundLayerTexture5;
@property (strong,nonatomic) SKTexture *backgroundLayerTexture6;
@property (strong,nonatomic) SKTexture *backgroundLayerTexture7;
@property (strong,nonatomic) SKTexture *backgroundLayerObstaclesTexture;

@property (strong,nonatomic) SKTexture *lowerObstacleTallTexture;
@property (strong,nonatomic) SKTexture *lowerObstacleMediumTexture;
@property (strong,nonatomic) SKTexture *lowerObstacleShortTexture;

@property (strong,nonatomic) SKTexture *upperObstacleTallTexture;
@property (strong,nonatomic) SKTexture *upperObstacleMediumTexture;
@property (strong,nonatomic) SKTexture *upperObstacleShortTexture;

@property float smallFontSize;
@property float mediumFontSize;
@property float largeFontSize;

@property float GameSpeed;
@property CGSize theCopterSize;
@property CGSize theCoinNodeSize;
@property CGSize theBombNodeSize;
@property float obstacleWidth;
@property float obstacleUnitSize;

@property (strong,nonatomic) SKAction* playCoinCollectedSoundAction;
@property (strong,nonatomic) SKAction* playNewHighScoreSoundAction;

+(TexturePreLoader *)sharedTexturePreLoader;
-(void)preLoadAllTextures:(GameViewController *)sender;

@end
