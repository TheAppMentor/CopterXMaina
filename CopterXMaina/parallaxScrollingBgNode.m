//
//  parallaxScrollingBgNode.m
//  ParallaxScrolling
//
//  Created by Prashanth Moorthy on 10/10/14.
//  Copyright (c) 2014 Sprite. All rights reserved.
//



#import "parallaxScrollingBgNode.h"
#import "FMMParallaxNode.h"

@interface parallaxScrollingBgNode ()

@property (strong,nonatomic) SKAction *spinCoinAction;
@property (strong,nonatomic) SKAction *animateBomb;

@end

@implementation parallaxScrollingBgNode{

}

FMMParallaxNode *_parallaxGround;
FMMParallaxNode *_parallaxObstacle;

FMMParallaxNode *_staticBackground;


FMMParallaxNode *_parallaxLayer1;
FMMParallaxNode *_parallaxLayer2;
FMMParallaxNode *_parallaxLayer3;
FMMParallaxNode *_parallaxLayer4;
FMMParallaxNode *_parallaxLayer5;
FMMParallaxNode *_parallaxLayer6;
FMMParallaxNode *_parallaxLayer7;


-(void)setupBGNodeWithSize:(CGSize)theSize{
    
   // [[NSUserDefaults standardUserDefaults] setValue:@"400" forKey:@"gameSpeed"];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    NSLog(@"Screen Width = %f, Height %f",screenWidth,screenHeight);

    // Sky Layer
    NSArray *staticBackgroundNames = @[[[TexturePreLoader sharedTexturePreLoader] staticBackgroundTexture],
                                          [[TexturePreLoader sharedTexturePreLoader] staticBackgroundTexture],
                                          [[TexturePreLoader sharedTexturePreLoader] staticBackgroundTexture]];
    _staticBackground = [[FMMParallaxNode alloc] initWithBackgrounds:staticBackgroundNames
                                                              size:theSize
                                              pointsPerSecondSpeed:self.gameSpeedF/2];
    _staticBackground.position = CGPointMake(0, 0);

    
    // Sky Layer
    NSArray *parallaxBackground1Names = @[[[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture1],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture1],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture1]];
    _parallaxLayer1 = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackground1Names
                                                           size:theSize
                                           pointsPerSecondSpeed:self.gameSpeedF/7];
    _parallaxLayer1.position = CGPointMake(0, 0);
    

    // Clouds Layer
    NSArray *parallaxBackground2Names = @[[[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture2],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture2],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture2]];
    _parallaxLayer2 = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackground2Names
                                                              size:theSize
                                              pointsPerSecondSpeed:self.gameSpeedF/5];
    _parallaxLayer2.position = CGPointMake(0, 0);

    // Clouds Layer
    NSArray *parallaxBackground3Names = @[[[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture3],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture3],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture3]];
    _parallaxLayer3 = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackground3Names
                                                              size:theSize
                                              pointsPerSecondSpeed:self.gameSpeedF/4];
    _parallaxLayer3.position = CGPointMake(0, 0);

    // Clouds Layer
    NSArray *parallaxBackground4Names = @[[[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture4],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture4],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture4]];
    _parallaxLayer4 = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackground4Names
                                                              size:theSize
                                              pointsPerSecondSpeed:self.gameSpeedF/2.5];
    _parallaxLayer4.position = CGPointMake(0, 0);

    // Clouds Layer
    NSArray *parallaxBackground5Names = @[[[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture5],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture5],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture5]];
    _parallaxLayer5 = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackground5Names
                                                              size:theSize
                                              pointsPerSecondSpeed:self.gameSpeedF/2];
    _parallaxLayer5.position = CGPointMake(0, 0);

    // Clouds Layer
    NSArray *parallaxBackground6Names = @[[[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture6],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture6],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture6]];
    _parallaxLayer6 = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackground6Names
                                                              size:theSize
                                              pointsPerSecondSpeed:self.gameSpeedF/1.5];
    _parallaxLayer6.position = CGPointMake(0, 0);

        
    // Obstacle Layer
    NSArray *parallaxObstacleNames = @[[[TexturePreLoader sharedTexturePreLoader] backgroundLayerObstaclesTexture],
                                       [[TexturePreLoader sharedTexturePreLoader] backgroundLayerObstaclesTexture],
                                       [[TexturePreLoader sharedTexturePreLoader] backgroundLayerObstaclesTexture]];
    _parallaxObstacle = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxObstacleNames
                                                                size:theSize
                                                pointsPerSecondSpeed:self.gameSpeedF];
    _parallaxObstacle.position = CGPointZero;
    _parallaxObstacle.zPosition = self.zPosition + 5;
    
    // Pass the coin and bomb textures here.....
    _parallaxObstacle.spinCoinAction = self.spinCoinAction;
    _parallaxObstacle.animateBomb = self.animateBomb;
    
    
    
//    [self addChild:_parallaxLayer1];
//    [self addChild:_parallaxLayer2];
//    [self addChild:_parallaxLayer3];
//    [self addChild:_parallaxLayer4];
//    [self addChild:_parallaxLayer5];
//    [self addChild:_parallaxLayer6];

    [self addChild:_staticBackground];
    [self addChild:_parallaxObstacle];
    
}

-(void)updateBGNodePositions:(CFTimeInterval)currentTime {
    //Update background (parallax) position

    [_staticBackground setGameSpeedF:self.gameSpeedF/2];
    [_staticBackground update:currentTime];
    
    [_parallaxObstacle setGameSpeedF:self.gameSpeedF];
    [_parallaxObstacle updateObstacles:currentTime];
}

// Initializing.. all the textures needed for bombs/Coins etc here.. it becomes expensive to create it once the game has started running.
// This was what was causing the stuttering problem.

-(SKAction *)spinCoinAction{
    if (!_spinCoinAction) {
        // Rotate the Coin :
        SKAction *spinCoin = [SKAction animateWithTextures:[[TexturePreLoader sharedTexturePreLoader] arrayOfEnvironmentCoinTextures] timePerFrame:0.2];
        _spinCoinAction = [SKAction repeatActionForever:spinCoin];
    }
    return _spinCoinAction;
}

-(SKAction *)animateBomb{
    if (!_animateBomb) {
        // Animate the Bomb :
        SKAction *animateBomb = [SKAction animateWithTextures:[[TexturePreLoader sharedTexturePreLoader] arrayOfEnvironmentBombTextures] timePerFrame:0.2];
        _animateBomb = [SKAction repeatActionForever:animateBomb];
    }
    return _animateBomb;
}



@end
