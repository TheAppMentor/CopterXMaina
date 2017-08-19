//
//  ScrollingGroundNode.m
//  copterTester
//
//  Created by Prashanth Moorthy on 2/26/15.
//  Copyright (c) 2015 CTS. All rights reserved.
//

#import "ScrollingGroundNode.h"
#import "FMMParallaxNode.h"
#import "TexturePreLoader.h"

@implementation ScrollingGroundNode{
    NSString *groundLayer;
    NSString *bgGround;

}

FMMParallaxNode *_parallaxGroundLayer;
FMMParallaxNode *_parallaxGround;


-(void)setupBGNodeWithSize:(CGSize)theSize{
    
    // Ground Layer
    NSArray *parallaxBackground7Names = @[[[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture7],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture7],
                                          [[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture7]];
    _parallaxGroundLayer = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackground7Names
                                                              size:theSize
                                              pointsPerSecondSpeed:self.gameSpeedF];
    _parallaxGroundLayer.position = CGPointMake(0, 0);
    
    
       [self addChild:_parallaxGroundLayer];
}

-(void)updateBGNodePositions:(CFTimeInterval)currentTime {
    //Update Ground (parallax) position
    [_parallaxGroundLayer update:currentTime];
}


@end
