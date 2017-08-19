//
//  scoreNode.h
//  theCopter
//
//  Created by Prashanth Moorthy on 10/17/14.
//  Copyright (c) 2014 Sprite. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameCenterHelper.h"

@interface scoreNode : SKNode{

}

@property NSUInteger roundTotalScore;
@property NSUInteger roundScore;
@property NSUInteger roundCoinCollected;

@property BOOL haveToWriteHighScoreToDisk;

-(void)makeScoreLabels;
-(void)updateScoreLabels;
-(void)saveNewHighScoreToDisk;
-(void)updateCoinCountLabel;
-(void)resetGameScoreToZero;
-(void)saveGameScoreForContinueGame;
-(void)reduceCoinCountForContinueGame;
-(instancetype)initwithSize:(CGSize)theSize;
- (void)reportScoreToGameCenter;

@end
