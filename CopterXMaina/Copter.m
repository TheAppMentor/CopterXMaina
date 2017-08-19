//
//  Copter.m
//  CopterGame
//
//  Created by Prashanth Moorthy on 10/6/14.
//  Copyright (c) 2014 Sprite. All rights reserved.
//

#import "Copter.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>



@interface Copter ()

@property (strong,nonatomic) SKTextureAtlas *characterAtlas;
@property (strong,nonatomic) NSMutableArray *copterIdleTextures;
@property (strong,nonatomic) NSMutableArray *copterGameOverTextures;
@property (strong,nonatomic) NSMutableArray *copterAttackTextures;
@property (strong,nonatomic) NSMutableArray *copterFireCometTextures;
@property (strong,nonatomic) NSMutableArray *copterFireMissleATextures;
@property (strong,nonatomic) NSMutableArray *copterCollisionTextures;

@property (strong,nonatomic) AVAudioPlayer *copterSoundPlayer;

@end

@implementation Copter{
    SKTextureAtlas *fireAtlas;
}

-(instancetype)init{
      self = [super init];
    if (self) {
        [self setupCopteState];
    }
    return self;
}

-(AVAudioPlayer *)copterSoundPlayer{
    if (!_copterSoundPlayer) {
        NSError *error;
        NSURL * chopperSoundURL = [[NSBundle mainBundle] URLForResource:@"chopperLoop" withExtension:@"mp3"];
        _copterSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:chopperSoundURL error:&error];
        _copterSoundPlayer.numberOfLoops = -1;
        _copterSoundPlayer.volume = 0.25;
        _copterSoundPlayer.rate = 0.25;
    }
    return _copterSoundPlayer;
}



-(void)setupCopteState{
    
    self.copterIdleTextures = [[TexturePreLoader sharedTexturePreLoader] arrayOfCopterIdleTextures];
    self.copterGameOverTextures = [[TexturePreLoader sharedTexturePreLoader] arrayOfCopterGameOverTextures];
    self.copterCollisionTextures = [[TexturePreLoader sharedTexturePreLoader] arrayOfCopterCollisionTextures];

    self.name = @"copter";
    self.size = CGSizeMake(100, 100);
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    // Setup Actions for Copter.
    SKAction *idleCopter = [SKAction animateWithTextures:self.copterIdleTextures timePerFrame:0.1];
    SKAction *idleRep = [SKAction repeatActionForever:idleCopter];
    [self runAction:idleRep];
    
    // Setup Physics Body for the Copter
    //SKPhysicsBody *copterPhyBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.size.width/2.5, self.size.height/2.5)];
    // Keep the Physics body at 90% of the copter size, coz when collisions happen it should look like the image of the copter actulally hit the obstacle. If its at 100% then there is a gap between the copter at the obstacle when the collission happens.
    SKPhysicsBody *copterPhyBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake([[TexturePreLoader sharedTexturePreLoader] theCopterSize].width * 0.9 , [[TexturePreLoader sharedTexturePreLoader] theCopterSize].height * 0.9)];

    self.physicsBody = copterPhyBody;
    self.physicsBody.dynamic = YES;
    
    self.physicsBody.categoryBitMask = copterCategory;
    self.physicsBody.collisionBitMask = copterCategory | sceneEdgeCategory | obstacleCategory | monsterCategory | goldCoinCategory | bombCategory;
    self.physicsBody.contactTestBitMask = copterCategory | sceneEdgeCategory | obstacleCategory | monsterCategory | goldCoinCategory | bombCategory;
    
    // Setting the mass to some big value.. so that heli is not affected when colliding with coins.
    self.physicsBody.mass = 1000.0;
    
    // Setup the Copter Sound here.
    // chopperLoop
  //  [self.copterSoundPlayer play];
    
//    SKAction *theCopterSound = [SKAction playSoundFileNamed:@"chopperLoop.mp3" waitForCompletion:YES];
//    SKAction *repeatTheCopterSound = [SKAction repeatActionForever:theCopterSound];
//    [self runAction:repeatTheCopterSound];
}

-(void)moveUp{
    self.physicsBody.dynamic = YES;
  //  SKAction *tiltCopter = [SKAction rotateByAngle:M_PI/5 duration:0.3];
  //  [self runAction:tiltCopter];
    // Added this line to stop many impulses from accumulating, when there are mulitple clicks, if you remember in the past bird was flying off the top of the screen.
    SKAction *tiltCopterUp = [SKAction rotateToAngle:M_PI/20 duration:0.1];
    SKAction *tiltCopterDown = [SKAction rotateToAngle:0.0 duration:0.1];
    SKAction *tiltSequence = [SKAction sequence:@[tiltCopterUp,tiltCopterDown]];
 //   [self removeAllActions];
    [self runAction:tiltSequence];

    self.physicsBody.velocity = CGVectorMake(0, 0);
    [self.physicsBody applyImpulse:CGVectorMake(0, [[[NSUserDefaults standardUserDefaults] valueForKey:@"moveUpVector"] floatValue])];
}


-(void)moveDown{
    self.physicsBody.dynamic = YES;
    //  SKAction *tiltCopter = [SKAction rotateByAngle:M_PI/5 duration:0.3];
    //  [self runAction:tiltCopter];
    // Added this line to stop many impulses from accumulating, when there are mulitple clicks, if you remember in the past bird was flying off the top of the screen.
    self.physicsBody.velocity = CGVectorMake(0, 0);
    [self.physicsBody applyImpulse:CGVectorMake(0, -25)];
    
}

-(void)collideWithObstacle{
    [self removeAllActions];
    [self enumerateChildNodesWithName:@"exhaust" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    // Stop Playing the sound.
  //  [self.copterSoundPlayer stop];
    
    SKTexture *blastTexture = [SKTexture textureWithImageNamed:@"Got-hit"];
    SKAction *showBlast = [SKAction setTexture:blastTexture];
    SKAction *explode = [SKAction scaleBy:2.0 duration:0.2];
    SKAction *restore = [SKAction scaleTo:1.0 duration:0.2];
    
    SKAction *explodeSequence = [SKAction group:@[showBlast,explode,restore]];
    
    
    [self runAction:explodeSequence completion:^{
        SKAction *collision = [SKAction animateWithTextures:self.copterCollisionTextures timePerFrame:0.1];
        SKAction *repeatCollision = [SKAction repeatActionForever:collision];
        [self runAction:repeatCollision];
    }];
    
  //  self.physicsBody.dynamic = YES;
    
    SKAction *wait = [SKAction waitForDuration:2.0];
    [self runAction:wait completion:^{
        [self removeAllActions];
        SKAction *crashAnimation = [SKAction animateWithTextures:self.copterGameOverTextures timePerFrame:0.1];
        [self runAction:crashAnimation];
    }];
}

@end

