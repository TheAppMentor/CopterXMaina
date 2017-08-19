//
//  parallaxScrollingBgNode.h
//  ParallaxScrolling
//
//  Created by Prashanth Moorthy on 10/10/14.
//  Copyright (c) 2014 Sprite. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameConstants.h"
#import "TexturePreLoader.h"

@interface parallaxScrollingBgNode : SKNode

@property CGFloat gameSpeedF;

-(void)updateBGNodePositions:(CFTimeInterval)currentTime;
-(void)setupBGNodeWithSize:(CGSize)theSize;

@property (strong,nonatomic) NSMutableArray *bombTextures;
@property (strong,nonatomic) NSMutableArray *coinTextures;

@end
