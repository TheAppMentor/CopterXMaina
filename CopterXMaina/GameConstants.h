//
//  GameConstants.h
//  theCopter
//
//  Created by Prashanth Moorthy on 10/7/14.
//  Copyright (c) 2014 Sprite. All rights reserved.
//

#ifndef theCopter_GameConstants_h
#define theCopter_GameConstants_h


#endif

static const uint32_t copterCategory        = 0X1 << 1;
static const uint32_t cometCategory         = 0X1 << 2;
static const uint32_t obstacleCategory      = 0X1 << 3;
static const uint32_t sceneEdgeCategory     = 0X1 << 4;
static const uint32_t monsterCategory       = 0X1 << 5;
static const uint32_t goldCoinCategory      = 0X1 << 6;
static const uint32_t bombCategory          = 0X1 << 7;

static const CGFloat GAME_SPEED = 400;

#define NUMBER_OF_COIN_FRAMES 8
#define NUMBER_OF_BOMB_FRAMES 2

#define GAME_SPEED [[[UIApplication sharedApplication] delegate] gameSpeed]

// Here we have all the combination of obstacles. Each element of the outer array defines, an array (3 sets) of obstacles that can appear in a scene.
// 0 = Short height Obstacle.
// 1 = Medium height obstacle.
// 2 = Long Height Obstacle.

// The First component represts the Upper obstacle. the SEcond Component represts the lower obstacle.
#define GAME_OBSTACLES @[\
@[@"00",@"00",@"01"], \
@[@"00",@"01",@"01"], \
@[@"00",@"01",@"02"], \
@[@"00",@"00",@"02"], \
@[@"01",@"01",@"10"], \
@[@"00",@"11",@"00"], \
@[@"00",@"02",@"00"], \
@[@"00",@"20",@"00"], \
@[@"02",@"02",@"01"], \
@[@"20",@"01",@"20"], \
@[@"10",@"01",@"10"]]