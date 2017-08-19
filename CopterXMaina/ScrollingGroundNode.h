//
//  ScrollingGroundNode.h
//  copterTester
//
//  Created by Prashanth Moorthy on 2/26/15.
//  Copyright (c) 2015 CTS. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ScrollingGroundNode : SKNode

@property CGFloat gameSpeedF;

-(void)updateBGNodePositions:(CFTimeInterval)currentTime;
-(void)setupBGNodeWithSize:(CGSize)theSize;

@end
