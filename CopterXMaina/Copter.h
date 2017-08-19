//
//  Copter.h
//  CopterGame
//
//  Created by Prashanth Moorthy on 10/6/14.
//  Copyright (c) 2014 Sprite. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GameConstants.h"
#import "TexturePreLoader.h"

@interface Copter : SKSpriteNode

-(void)moveUp;
-(void)moveDown;
-(void)collideWithObstacle;



@end
