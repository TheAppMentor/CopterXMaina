//
//  GamePlayScene.m
//  CopterXMaina
//
//  Created by Prashanth Moorthy on 3/10/15.
//  Copyright (c) 2015 The App Mentor. All rights reserved.
//

#import "GamePlayScene.h"
#import "AppDelegate.h"

//[[NSUserDefaults standardUserDefaults] objectForKey:@"musicStatus"]

//NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";


@interface GamePlayScene (){
    parallaxScrollingBgNode *bgNode;
    ScrollingGroundNode *groundNode;
    SKSpriteNode *scoreNode;
    SKSpriteNode *mainBoard;
    float copterOriginalXPosition;
    SKAction *alignCopter;
    NSArray *_products;
    PrashWordSmithPurchaseManager *thePurchaseManger;
    SKLabelNode *tapHereLabel;
    SKSpriteNode *smokeNode;

    SKLabelNode *gameOverScreenIntructionsLabel1;
    SKLabelNode *gameOverScreenIntructionsLabel2;
    SKSpriteNode *gameOverScreenBuyToContinueButton;
    
    SKLabelNode *highScoreLabel;
    
    CGFloat timeIntervalForSpeedChange;
    CGFloat scoreMultiplier;


}

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastSmokeAddedTimeInterval;

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@property (nonatomic) NSTimeInterval lastSpeedChangedTimeInterval;

// Setup all the actions.
@property (strong,nonatomic) SKAction *tiltCopterUpActionSequence;
@property (strong,nonatomic) AVAudioPlayer * backgroundMusicPlayer;
@property (strong,nonatomic) AVAudioPlayer * copterLoopPlayer;
@property (strong,nonatomic) SKAction *playCoinCollectedSoundAction;
@property (strong,nonatomic) SKAction *flashingAction;
@property (strong,nonatomic) SKAction *animateSmoke;
@property (strong,nonatomic) SKAction *moveSmoke;


@end

@implementation GamePlayScene{
    Copter *theCopter;
    BOOL keepScrolling;
    BOOL keepMovingUp;
    scoreNode *scores;
    BOOL gameStarted;
    BOOL playMusic;
    CGVector moveUpGravityVector;
    CGVector moveDownGravityVector;
    SKSpriteNode *gameOverNode;
    BOOL gameAlreadyPaused;
    BOOL gameAlreadyStopped;
    
    SKLabelNode *roundCoinCollectedLabel;
}

parallaxScrollingBgNode *bgNode;


-(SKAction *)moveSmoke{
    if (!_moveSmoke) {
        _moveSmoke = [SKAction moveToX:-self.view.frame.origin.x - smokeNode.size.width/2 duration:1.5];
    }
    return _moveSmoke;
}

-(SKAction *)animateSmoke{
    
    if (!_animateSmoke) {
        _animateSmoke = [SKAction animateWithTextures:[[TexturePreLoader sharedTexturePreLoader] arrayOfEnvironmentSomkeTextures] timePerFrame:0.2];
    }
    return _animateSmoke;
}

-(SKAction *)flashingAction{
    if (!_flashingAction) {
        SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:0.2];
        SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.2];
        SKAction *fadeSequence = [SKAction sequence:@[fadeOut,fadeIn,[SKAction waitForDuration:0.2]]];
        _flashingAction = [SKAction repeatActionForever:fadeSequence];
    }
    return _flashingAction;
}

-(SKAction *)tiltCopterUpActionSequence{
    if (!_tiltCopterUpActionSequence) {
        SKAction *tiltCopterUp = [SKAction rotateToAngle:M_PI/45 duration:0.1];
        SKAction *tiltCopterDown = [SKAction rotateToAngle:0.0 duration:0.1];
        _tiltCopterUpActionSequence = [SKAction sequence:@[tiltCopterUp,tiltCopterDown]];

    }
    return _tiltCopterUpActionSequence;
}


-(void)didMoveToView:(SKView *)view {
    
    
    // Setup your scene here
    self.physicsWorld.contactDelegate = self;
    keepScrolling = NO;
    gameStarted = NO;
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    moveUpGravityVector = CGVectorMake(self.physicsWorld.gravity.dx, -[[[NSUserDefaults standardUserDefaults] valueForKey:@"gravity"] floatValue]);
    moveDownGravityVector = CGVectorMake(self.physicsWorld.gravity.dx, [[[NSUserDefaults standardUserDefaults] valueForKey:@"gravity"] floatValue]);
        
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"musicStatus"] isEqualToString:@"ON"]) {
        playMusic = YES;
        
    }else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"musicStatus"] isEqualToString:@"OFF"]){
        playMusic = NO;
    }
    
    [(AppDelegate *)[UIApplication sharedApplication].delegate setTheGamePlayScene:self];
    
    
#pragma mark - Game Backgrounds
    bgNode = [[parallaxScrollingBgNode alloc] init];
    [bgNode setupBGNodeWithSize:self.frame.size];
    //bgNode.gameSpeedF = 400.0;
    bgNode.gameSpeedF = [[TexturePreLoader sharedTexturePreLoader] GameSpeed];
    [self addChild:bgNode];
    
//    groundNode = [[ScrollingGroundNode alloc] init];
//    [groundNode setupBGNodeWithSize:self.size];
//    [self addChild:groundNode];
//    groundNode.zPosition = bgNode.zPosition + 100;

    // Create the Copter and add it to the scene.
    theCopter = [[Copter alloc] init];
    theCopter.position = CGPointMake(self.size.width/3, CGRectGetMidY(self.frame));
    theCopter.zPosition = groundNode.zPosition + 1;
//    theCopter.size = CGSizeMake(self.size.height/7.5, self.size.height/7.5);
    theCopter.size = [[TexturePreLoader sharedTexturePreLoader] theCopterSize];
    [self addChild:theCopter];
    
    theCopter.physicsBody.restitution = 0.0;
    
    // Mehtods to align copter.. during the game.. these lines make sure the copter does not move around.
    copterOriginalXPosition = theCopter.position.x;
    alignCopter = [SKAction rotateToAngle:0.0 duration:0.1];
    
    SKSpriteNode *theGround = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor] size:CGSizeMake(self.size.width, self.size.height/6)];
    [theGround setTexture:[[TexturePreLoader sharedTexturePreLoader] backgroundLayerTexture7]];
    theGround.position = CGPointMake(CGRectGetMidX(self.frame),theGround.size.height/2);

    [self addChild:theGround];
    theGround.zPosition = bgNode.zPosition + 100;
    
    // Add a ledge around the ground Node only.
    SKSpriteNode *floorLedgeNode = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(theCopter.size.width * 3, 0)];
    floorLedgeNode.name = @"floorLedge";
    floorLedgeNode.anchorPoint = CGPointMake(0.5, 0.5);
    floorLedgeNode.position = CGPointMake(theCopter.position.x, theGround.size.height);
    
    SKPhysicsBody *floorLedge = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(-floorLedgeNode.size.width/2, 0) toPoint:CGPointMake(floorLedgeNode.size.width/2,0)];
    floorLedge.categoryBitMask = obstacleCategory;
    floorLedgeNode.physicsBody = floorLedge;
    
    [self addChild:floorLedgeNode];

    
    // Add a ledge around the Roof Node only.
    SKSpriteNode *roofLedgeNode = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(theCopter.size.width * 3, 0)];
    roofLedgeNode.name = @"roofLedge";
    roofLedgeNode.anchorPoint = CGPointMake(0.5, 0.5);;
    roofLedgeNode.position = CGPointMake(theCopter.position.x,self.frame.size.height-(self.frame.size.height* (19/20)));
    
    SKPhysicsBody *roofLedge = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(-roofLedgeNode.size.width/2, 0) toPoint:CGPointMake(roofLedgeNode.size.width/2,0)];
    roofLedge.restitution = 0.0;
    roofLedgeNode.physicsBody = roofLedge;
    
    [self addChild:roofLedgeNode];

    
    //Add Score Node:
    scores = [[scoreNode alloc] initwithSize:self.size];
    [scores makeScoreLabels];
    scores.zPosition = theCopter.zPosition + 100;
    [self addChild:scores];
    
    if (playMusic) {
        [[[TexturePreLoader sharedTexturePreLoader] backgroundMusicPlayer] play];
        self.playCoinCollectedSoundAction = [[TexturePreLoader sharedTexturePreLoader] playCoinCollectedSoundAction];
    }
    
    // Add the Tap Here Label
    [self addTapHereLabel];
    
//    // If User has not bought Remove Ads.
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CopterRemoveAllAds"]) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"startShowingAds" object:nil];
//    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if (!gameStarted) {
        // Check if User has bought the remove ads item.
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CopterRemoveAllAds"]) {
            // Check to see if We have decided to show ads during the game.
           // NSLog(@"Show Ad During Game is %@",[[NSUserDefaults standardUserDefaults] boolForKey:@"ShowAdsDuringGame"]?@"YES":@"NO");
//            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowAdsDuringGame"]) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"stopShowingAds" object:nil];
//            }
        }
        
//        NSLog(@"Ads During Game : User has bought Remove Ads %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"CopterRemoveAllAds"]);
//        NSLog(@"Ads During Game : Dev has disabled Ads %@",[[NSUserDefaults standardUserDefaults] stringForKey:@"ShowAdsDuringGame"]);

        gameStarted = YES;
        keepScrolling = YES;
        gameAlreadyPaused = NO;
        gameAlreadyStopped = NO;
        self.physicsWorld.gravity = moveDownGravityVector;                      // Starting the game by adding Gravity to physics world.
        [tapHereLabel removeFromParent];
        
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"continuingGame"]) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"continuingGame"];
            bgNode.gameSpeedF = [[NSUserDefaults standardUserDefaults] floatForKey:@"gameSpeed"];
            scoreMultiplier = [[NSUserDefaults standardUserDefaults] floatForKey:@"scoreMultiplier"];
            timeIntervalForSpeedChange = [[NSUserDefaults standardUserDefaults] floatForKey:@"timeIntervalForSpeedChange"];
        
        }else{
            bgNode.gameSpeedF = [[TexturePreLoader sharedTexturePreLoader] GameSpeed];;
            timeIntervalForSpeedChange = 20.0;
            scoreMultiplier = 1.0;
            
        }
        
    }
    
    if (keepScrolling) {
            keepMovingUp = YES;
    } else{
        /* Called when a touch begins */
        UITouch *aTouch = [touches anyObject];
        CGPoint aTouchLocation = [aTouch locationInNode:self.scene];
    
        if ([[self nodeAtPoint:aTouchLocation].name isEqualToString:@"closeButton"]) [self closeGame];
        if ([[self nodeAtPoint:aTouchLocation].name isEqualToString:@"playAgainBoard"]) [self restartGame];
        if ([[self nodeAtPoint:aTouchLocation].name isEqualToString:@"continueGameBoard"]) [self continueGame];
        if ([[self nodeAtPoint:aTouchLocation].name isEqualToString:@"goToStore"]) [self transitionToStore];
        if ([[self nodeAtPoint:aTouchLocation].name isEqualToString:@"BuyCoinsFromAppStore"]){
            
            [self buyCoinsFromAppStore];
        }
    }
}

-(void)purchaseProcessCompleted:(NSNotification *)notification{

    NSLog(@"ntofication.userinfo is %@",notification.userInfo);
    [gameOverScreenBuyToContinueButton removeAllActions];
    
    if ([[notification.userInfo objectForKey:@"productName"] isEqualToString:@"copter_buy_500_coins"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IAPHelperProductPurchasedNotification object:nil];
        [self restartGameAfterPurchase];
    }
}

-(void)pulseNode:(SKNode *)theNode byScale:(CGFloat)scale{
    [theNode removeAllActions];
    SKAction* scoreAction = [SKAction scaleBy:scale duration:0.2];
    SKAction* revertAction = [SKAction scaleTo:1 duration:0.2];
    SKAction* completeAction = [SKAction repeatActionForever:[SKAction sequence:@[scoreAction, revertAction]]];
    [theNode runAction:completeAction];
}

-(void)restartGameAfterPurchase{
    
    // Purchase was successful. Update the Gold Coin Count
    NSInteger goldCoinCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"coinCount"];
    goldCoinCount += 500;
    [[NSUserDefaults standardUserDefaults] setInteger:goldCoinCount forKey:@"coinCount"];
    [self replaceBuyButtonWithContinueButton];
    roundCoinCollectedLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"coinCount"];
    [self pulseNode:roundCoinCollectedLabel byScale:1.5];
}

-(void)replaceBuyButtonWithContinueButton{
    [gameOverScreenIntructionsLabel1 removeFromParent];
    [gameOverScreenIntructionsLabel2 removeFromParent];
    [gameOverScreenBuyToContinueButton removeFromParent];
    
    gameOverScreenIntructionsLabel2 = nil;
    gameOverScreenIntructionsLabel1 = nil;
    gameOverScreenBuyToContinueButton = nil;
    [self addContinueGameButtonToGameOverScreen];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //    NSLog(@"Touches Ended");
    keepMovingUp = NO;
    self.physicsWorld.gravity = moveDownGravityVector;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    //    NSLog(@"touches cancelled method");
    keepMovingUp = NO;
   // self.physicsWorld.gravity = CGVectorMake(self.physicsWorld.gravity.dx, [[[NSUserDefaults standardUserDefaults] valueForKey:@"gravity"] floatValue]);
    self.physicsWorld.gravity = moveDownGravityVector;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    // Code to Speed up Game based on time.
    // Need to check for the keep scrolling coz, this update runs even when game has ended.
    if (keepScrolling) {
        if (!self.lastSpeedChangedTimeInterval) {
            self.lastSpeedChangedTimeInterval = currentTime;
        }
        CFTimeInterval timeSinceLastSpeedChange = currentTime - self.lastSpeedChangedTimeInterval;

    if (timeSinceLastSpeedChange > timeIntervalForSpeedChange) {
        self.lastSpeedChangedTimeInterval = currentTime;
        [self speedUpGame];
    }
    }
    
    if (keepScrolling) {
        [self updateWithTimeSinceLastUpdate:timeSinceLast];
        [bgNode updateBGNodePositions:currentTime];

        // Sometimes when the copter hits a coin etc.. it loses its orientation.. and tilts.. so setting it to zero in the update loop.
        [theCopter runAction:alignCopter];
        theCopter.position = CGPointMake(copterOriginalXPosition, theCopter.position.y);
    }
    
    if (keepMovingUp) {
        // Move the Copter UP
        self.physicsWorld.gravity = moveUpGravityVector;
        [theCopter runAction:self.tiltCopterUpActionSequence];
    }
    
//    [self enumerateChildNodesWithName:@"heliSmoke" usingBlock:^(SKNode *node, BOOL *stop) {
//        if (node.position.x < 0) {
//            [node removeFromParent];
//        }
//    }];
}

-(void)speedUpGame{
    
    // Display Speeding up Label
    // If there are any old labels remove it.
    SKLabelNode *speedingUpLabel = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
    
//    speedingUpLabel.text = @"Speeding Up";
    speedingUpLabel.text = NSLocalizedString(@"Speeding_Up", nil);
    speedingUpLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize];
    [speedingUpLabel removeAllActions];
    
    SKAction* scoreAction = [SKAction scaleBy:1.25 duration:0.5];
    SKAction* revertAction = [SKAction scaleTo:1 duration:0.5];
    SKAction* completeAction = [SKAction repeatActionForever:[SKAction sequence:@[scoreAction, revertAction]]];
    
    [speedingUpLabel runAction:completeAction];
    
    [self addChild:speedingUpLabel];
    speedingUpLabel.zPosition = theCopter.zPosition + 100;
    speedingUpLabel.fontColor = [UIColor whiteColor];
    speedingUpLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height/5);
    
    timeIntervalForSpeedChange *= 3;
    scoreMultiplier /= 0.50;

    NSLog(@"Old Game Speed is %lf",bgNode.gameSpeedF);
    
    CGFloat newSpeed = bgNode.gameSpeedF * 0.20;
    CGFloat oneThirdOfNewSpeed = newSpeed/3.0;

    // Speed up the game in phases
    SKAction *speedUpGame = [SKAction runBlock:^{
        bgNode.gameSpeedF += oneThirdOfNewSpeed;
        NSLog(@"Inc Game Speed is %lf",bgNode.gameSpeedF);

    }];
    
    SKAction *waitAction = [SKAction waitForDuration:1.0];
    
    // Remove Speeding up Label
    SKAction *removeLabel = [SKAction runBlock:^{
        [speedingUpLabel removeFromParent];
    }];
    SKAction *theSequence = [SKAction sequence:@[speedUpGame,waitAction,speedUpGame,waitAction,speedUpGame,waitAction,removeLabel]];
    [self runAction:theSequence];

    NSLog(@"Final Game Speed is %lf",bgNode.gameSpeedF);


}

-(void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    self.lastSmokeAddedTimeInterval += timeSinceLast;
    
    if (self.lastSmokeAddedTimeInterval > 0.25) {
        self.lastSmokeAddedTimeInterval = 0.0;
    [self addSmokeBehindCopter];
    }

    
    if (self.lastSpawnTimeInterval > (0.75/scoreMultiplier)) {
        self.lastSpawnTimeInterval = 0.0;
        [scores updateScoreLabels];
    }
}

-(void)addSmokeBehindCopter{

     smokeNode = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(10, 10)];
    
    //SKAction *animateSmoke = [SKAction animateWithTextures:[[TexturePreLoader sharedTexturePreLoader] arrayOfEnvironmentSomkeTextures] timePerFrame:0.2];
    [smokeNode runAction:self.animateSmoke];

    smokeNode.name = @"heliSmoke";
    smokeNode.size = CGSizeMake(theCopter.size.width/2.5, theCopter.size.height/2.5);
    smokeNode.zPosition = theCopter.zPosition;
//    smokeNode.position = CGPointMake(smokeNode.position.x - theCopter.size.width/2, smokeNode.position.y);
    smokeNode.position = CGPointMake(theCopter.position.x - theCopter.size.width/1.5, theCopter.position.y);

    //SKAction *moveSmoke = [SKAction moveToX:-self.view.frame.origin.x - smokeNode.size.width/2 duration:1.5];
    [smokeNode runAction:self.moveSmoke];
    [self addChild:smokeNode];
}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    if ((contact.bodyA.categoryBitMask == copterCategory) | (contact.bodyB.categoryBitMask == copterCategory)) {
        SKPhysicsBody *other = (contact.bodyA.categoryBitMask == copterCategory ? contact.bodyB : contact.bodyA);
        
        if (other.categoryBitMask == obstacleCategory) {
            //NSLog(@"I hit an OBSTACLE");
            
            keepScrolling = NO;
            moveUpGravityVector = CGVectorMake(0, -3.0);
            //moveUpGravityVector = moveDownGravityVector;
            
            if (playMusic) {
                [[[TexturePreLoader sharedTexturePreLoader] copterCrashSoundPlayer] play];
            }
            
            [theCopter collideWithObstacle];
            //[scores updateHighScoreLabel];
            [self doVolumeFade];
            [self stopGame];
        }
        
        if (other.categoryBitMask == goldCoinCategory) {
            //NSLog(@"I hit an GoldCoin");
            //keepScrolling = YES;
            
            if (playMusic) {
                // Settting up this audio player is too costly, causing a stutter.
                //[[[TexturePreLoader sharedTexturePreLoader] coinCollectedSoundPlayer] play];
                [self runAction:self.playCoinCollectedSoundAction];
            }
            [scores updateCoinCountLabel];
            // Remove the Gold Coin from the Scene and Play a sound & Increment the score here.
            [other.node removeFromParent];
        }
        
        if (other.categoryBitMask == bombCategory) {
            keepScrolling = NO;
            
            SKAction *explode = [SKAction animateWithTextures:[[TexturePreLoader sharedTexturePreLoader] arrayOfEnvironmentSomkeTextures] timePerFrame:0.2];
                [other.node runAction:explode completion:^{
                [other.node removeFromParent];
            }];
            
            // Negating the Move Up vector, so copter does not fly after crashing.
            moveUpGravityVector = CGVectorMake(0, -3.0);
            //moveUpGravityVector = moveDownGravityVector;

            [theCopter collideWithObstacle];
            //[scores updateHighScoreLabel];
            [self doVolumeFade];
            
            other.node.name = @"monster_hit";
            
            [self stopGame];
        }
    }
}

-(void)pauseGame{
    keepScrolling = NO;
}

-(void)stopGame{
    
    // Ok We have a crash here. Reset the Round Scores.
    scores.roundScore = 0;
    scores.roundCoinCollected = 0;
    
    // Need to do this gameAlreadyStopped thing, coz the stop game gets called multiple times during a collision.
    if (!gameAlreadyStopped) {
        gameAlreadyStopped = YES;
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CopterRemoveAllAds"]) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowAdsDuringGame"]) {
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"startShowingAds" object:nil];
            }
        }
    }
    
    // Ask the user if he wants to Continue the game by paying 50 coins.
    if (!gameAlreadyPaused) {
        gameAlreadyPaused = YES;
        [self performSelector:@selector(presentGameOverScreen) withObject:nil afterDelay:1.5];
    }
}

-(void)restartGame{
    
    SKTransition *transitionToMainScreen = [SKTransition fadeWithDuration:0.0];
//    GameScene *theGameScene = [GameScene sceneWithSize:CGSizeMake(1024, 768)];
    GameScene *theGameScene = [GameScene sceneWithSize:self.size];

    theGameScene.scaleMode = SKSceneScaleModeAspectFill;
    theGameScene.isGameRestarting = YES;
    
    [self.view presentScene:theGameScene transition:transitionToMainScreen];
}

-(void)continueGame{
    
    if (!gameStarted) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CopterRemoveAllAds"]) {
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ShowAdsDuringGame"]) {
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"startShowingAds" object:nil];
            }
        }
        }
    // Set the Game Score to be equal to the current Score.
    [scores saveGameScoreForContinueGame];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"continuingGame"];
    [[NSUserDefaults standardUserDefaults] setFloat:bgNode.gameSpeedF forKey:@"gameSpeed"];
    [[NSUserDefaults standardUserDefaults] setFloat:scoreMultiplier forKey:@"scoreMultiplier"];
    [[NSUserDefaults standardUserDefaults] setFloat:timeIntervalForSpeedChange  forKey:@"timeIntervalForSpeedChange"];
    
    // If User says Yes.. Then..
    SKTransition *transitionToMainScreen = [SKTransition fadeWithDuration:0.0];
    //    GameScene *theGameScene = [GameScene sceneWithSize:CGSizeMake(1024, 768)];
    GameScene *theGameScene = [GameScene sceneWithSize:self.size];
    
    theGameScene.scaleMode = SKSceneScaleModeAspectFill;
    theGameScene.isGameRestarting = YES;
    
    // Reduce the number of Gold Coins by 50.
    [scores reduceCoinCountForContinueGame];
    [self.view presentScene:theGameScene transition:transitionToMainScreen];
}

-(void)presentGameOverScreen{
    // Reset the Score to Zero & Update the High Score count.
    [scores reportScoreToGameCenter];
    [scores saveNewHighScoreToDisk];
    [scores resetGameScoreToZero];
    
    gameOverNode = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.0 green:0.0 blue:100/255 alpha:0.8] size:self.size];
    [gameOverNode setAnchorPoint:CGPointZero];
    
    // Add store Board.
    mainBoard = [SKSpriteNode spriteNodeWithImageNamed:@"window_panel_store"];
    mainBoard.anchorPoint = CGPointMake(0.5, 0.5);
    mainBoard.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    mainBoard.size = CGSizeMake(self.size.width * 3/4, self.size.height * 3/4);
    mainBoard.zPosition = 100.0;
    
    // Add Top Name Board;
    SKSpriteNode *topNameBoard = [SKSpriteNode spriteNodeWithImageNamed:@"mainMenu_Play_Button_2208"];
    topNameBoard.anchorPoint = CGPointMake(0.5, 0.5);
    topNameBoard.size = CGSizeMake(mainBoard.size.width * (1/(2 * mainBoard.xScale) ), 50/mainBoard.yScale);
    [mainBoard addChild:topNameBoard];
    
    topNameBoard.position = CGPointZero;
    topNameBoard.position = CGPointMake(topNameBoard.position.x, topNameBoard.position.y + (mainBoard.size.height/(2 * mainBoard.yScale)));
    topNameBoard.name = @"topNameBoard";
    topNameBoard.zPosition = mainBoard.zPosition + 1;
    
    // Add topBoard Label;
    SKLabelNode *labelNode = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
    labelNode.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize]/mainBoard.xScale;
    labelNode.fontColor = [UIColor colorWithRed:75/255 green:54.0/255 blue:33.0/255 alpha:1.0];
//    labelNode.text = @"Game Over";
    labelNode.text = NSLocalizedString(@"Game_Over", nil);
    
    labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [topNameBoard addChild:labelNode];
    labelNode.zPosition = topNameBoard.zPosition + 1;
    
    // Share on Shop Button.
    SKSpriteNode *storeButton = [SKSpriteNode spriteNodeWithImageNamed:@"btn_big_menu_shop_grey"];
    storeButton.anchorPoint = CGPointMake(0.5, 0.5);
    storeButton.size = CGSizeMake(mainBoard.size.height * (1.0/4.0)/mainBoard.yScale, mainBoard.size.height * (1.0/4.0)/mainBoard.yScale);
    [mainBoard addChild:storeButton];
    
    // playAgainNameBoard.position = CGPointMake(mainBoard.frame.size.width/2,150);
    storeButton.position = CGPointZero;
    storeButton.position = CGPointMake(mainBoard.size.width/3, storeButton.position.y - mainBoard.size.height/4);
    
    storeButton.name = @"goToStore";
    storeButton.zPosition = mainBoard.zPosition + 1;
    
    // Rate Us Button Title
    SKLabelNode *storeLabel = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
    //storeLabel.text = @"Store";
    storeLabel.text = NSLocalizedString(@"Store", nil);
    storeLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] smallFontSize]/mainBoard.xScale;
    storeLabel.position = CGPointMake(storeButton.position.x, storeButton.position.y + storeButton.size.height/2 + storeLabel.frame.size.height/2);
    
    [mainBoard addChild:storeLabel];
    
    // Rate us Button.
    // Play Again Round Button;
    SKSpriteNode *rateUsButton = [SKSpriteNode spriteNodeWithImageNamed:@"btn_big_menu_play_grey"];
    rateUsButton.anchorPoint = CGPointMake(0.5, 0.5);
    rateUsButton.size = CGSizeMake(mainBoard.size.height * (1.0/4.0)/mainBoard.yScale, mainBoard.size.height * (1.0/4.0)/mainBoard.yScale);
    [mainBoard addChild:rateUsButton];
    
    // playAgainNameBoard.position = CGPointMake(mainBoard.frame.size.width/2,150);
    rateUsButton.position = CGPointZero;
    rateUsButton.position = CGPointMake(-mainBoard.size.width/3, rateUsButton.position.y - mainBoard.size.height/4);
    
    rateUsButton.name = @"playAgainBoard";
    rateUsButton.zPosition = mainBoard.zPosition + 1;
    
    // Rate Us Button Title
    SKLabelNode *rateUsLabel = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
    //rateUsLabel.text = @"Play Again";
    rateUsLabel.text = NSLocalizedString(@"Restart_Game", nil);
    
    rateUsLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] smallFontSize]/mainBoard.xScale;

    rateUsLabel.position = CGPointMake(rateUsButton.position.x, rateUsButton.position.y + rateUsButton.size.height/2 + rateUsLabel.frame.size.height/2);
    [mainBoard addChild:rateUsLabel];
    
    //Round Score Holder Node
    SKSpriteNode *roundScoreHolder = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(mainBoard.size.width * (1.0/(2.0 * mainBoard.xScale) ), mainBoard.size.height * (1.0/3.0)/mainBoard.yScale)];
    roundScoreHolder.anchorPoint = CGPointMake(0.0, 0.5);
    //roundScoreHolder.anchorPoint = CGPointMake(1.0, 0.5);
    [mainBoard addChild:roundScoreHolder];
    
    roundScoreHolder.position = CGPointMake(roundScoreHolder.position.x, roundScoreHolder.position.y + mainBoard.size.height/4);    //roundScoreHolder.position = CGPointMake(roundScoreHolder.position.x, roundScoreHolder.position.y + mainBoard.size.height/4);
   // roundCoinCollectedHolder.position = CGPointMake(roundCoinCollectedHolder.position.x, roundCoinCollectedHolder.position.y + mainBoard.size.height/4);

    roundScoreHolder.zPosition = mainBoard.zPosition + 1;
    
    // Round Score Title;
    SKLabelNode *roundTitleLabel = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
    roundTitleLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] smallFontSize]/mainBoard.xScale;
    roundTitleLabel.fontColor = [UIColor whiteColor];

//    roundTitleLabel.text = @"Score";
    roundTitleLabel.text = NSLocalizedString(@"Score", nil);
    
    roundTitleLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [roundScoreHolder addChild:roundTitleLabel];
    roundTitleLabel.position = CGPointMake(roundScoreHolder.size.width/2, (roundTitleLabel.position.y + (roundScoreHolder.size.height/4.0)));
    
    roundTitleLabel.zPosition = mainBoard.zPosition + 1;
    
    // Round Score Label;
    SKLabelNode *roundScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
    roundScoreLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize]/mainBoard.xScale;
    roundScoreLabel.fontColor = [UIColor yellowColor];
    roundScoreLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)scores.roundTotalScore];
    
    roundScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [roundScoreHolder addChild:roundScoreLabel];
    
    //roundScoreLabel.position = CGPointMake(roundScoreHolder.size.width/2, (roundScoreLabel.position.y - (roundScoreHolder.size.height/4.0)));
    roundScoreLabel.position = CGPointMake(roundScoreHolder.size.width/2, roundScoreLabel.position.y/2);

    roundScoreLabel.zPosition = mainBoard.zPosition + 1;
    
    //High Score Holder Node
    SKSpriteNode *highScoreHolder = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(mainBoard.size.width * (1.0/(2.0 * mainBoard.xScale) ), mainBoard.size.height * (1.0/3.0)/mainBoard.yScale)];
    highScoreHolder.anchorPoint = CGPointMake(0.0, 0.5);
    [mainBoard addChild:highScoreHolder];
    highScoreHolder.position = CGPointMake(highScoreHolder.position.x, highScoreHolder.position.y + highScoreHolder.size.height/4);
    //   highScoreHolder.position = CGPointMake(highScoreHolder.position.x, highScoreHolder.position.y + highScoreHolder.size.height/4);
    
    highScoreHolder.zPosition = mainBoard.zPosition + 1;
    
    // High Score Title;
    SKLabelNode *highScoreTitleLabel = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
    highScoreTitleLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] smallFontSize]/mainBoard.xScale;
    highScoreTitleLabel.fontColor = [UIColor whiteColor];
    highScoreTitleLabel.text = @"Best";
    highScoreTitleLabel.text = NSLocalizedString(@"Best_Score", nil);
    highScoreTitleLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [highScoreHolder addChild:highScoreTitleLabel];
    
    highScoreTitleLabel.position = CGPointMake(highScoreHolder.position.x/2, (highScoreTitleLabel.position.y + (mainBoard.size.height/4.0)));
    // highScoreTitleLabel.position = CGPointMake(highScoreHolder.position.x/2, (highScoreTitleLabel.position.y + (highScoreHolder.size.height/4.0)));
    // highScoreTitleLabel.position = CGPointMake(highScoreHolder.size.width/2, (highScoreTitleLabel.position.y + (highScoreHolder.size.height/4.0)));
    
    highScoreTitleLabel.zPosition = mainBoard.zPosition + 1;
    
    // High Score Label;
    highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
    highScoreLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize]/mainBoard.xScale;
    highScoreLabel.fontColor = [UIColor yellowColor];
    highScoreLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"];
    highScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [highScoreHolder addChild:highScoreLabel];
    
    highScoreLabel.position = CGPointMake(highScoreHolder.position.x/2, highScoreTitleLabel.position.y - (highScoreTitleLabel.frame.size.height * 1.5));
    //  highScoreLabel.position = CGPointMake(roundScoreHolder.size.width/2, roundScoreLabel.position.y/2);
    
    highScoreLabel.zPosition = mainBoard.zPosition + 1;
    //    roundCoinCollectedTitleLabel.position = CGPointMake(roundCoinCollectedHolder.position.x/2, (roundCoinCollectedTitleLabel.position.y + (roundCoinCollectedHolder.size.height/4.0)));
    
    if (scores.haveToWriteHighScoreToDisk) {
        
        //******************************************************************************************************************************************
        // New High Score Node
        
        // New High Score Label
        SKSpriteNode *newHighScoreNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"element_new_score"] size:CGSizeMake(40, 30)];
        newHighScoreNode.zPosition = highScoreTitleLabel.zPosition + 1;
        [highScoreHolder addChild:newHighScoreNode];
        newHighScoreNode.position = CGPointMake(highScoreTitleLabel.position.x - highScoreTitleLabel.frame.size.width/2, highScoreTitleLabel.position.y + newHighScoreNode.size.height/2);
        
        [newHighScoreNode runAction:self.flashingAction];
        //******************************************************************************************************************************************
    }
    
    // Coin Collected Holder
    
    SKSpriteNode *roundCoinCollectedHolder = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(mainBoard.size.width * (1.0/(2.0 * mainBoard.xScale) ), mainBoard.size.height * (1.0/3.0)/mainBoard.yScale)];
    roundCoinCollectedHolder.anchorPoint = CGPointMake(0.0, 0.5);
    
    [mainBoard addChild:roundCoinCollectedHolder];
    roundCoinCollectedHolder.position = CGPointMake(roundCoinCollectedHolder.position.x, roundCoinCollectedHolder.position.y + mainBoard.size.height/4);
    roundCoinCollectedHolder.zPosition = mainBoard.zPosition + 1;
    // Tyring to place the end of label align to the center of the main board.
    
    // Coin Collected Title;
    SKLabelNode *roundCoinCollectedTitleLabel = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
    roundCoinCollectedTitleLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] smallFontSize]/mainBoard.xScale;
    roundCoinCollectedTitleLabel.fontColor = [UIColor whiteColor];
//    roundCoinCollectedTitleLabel.text = @"Coins";
    roundCoinCollectedTitleLabel.text = NSLocalizedString(@"Gold_Coins", nil);

    
    roundCoinCollectedTitleLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [roundCoinCollectedHolder addChild:roundCoinCollectedTitleLabel];
    //    roundCoinCollectedTitleLabel.position = CGPointMake(roundCoinCollectedHolder.position.x/2, (roundCoinCollectedTitleLabel.position.y + (roundCoinCollectedHolder.size.height/4.0)));
    roundCoinCollectedTitleLabel.position = CGPointMake(-roundCoinCollectedHolder.size.width/2, (roundCoinCollectedTitleLabel.position.y + (roundCoinCollectedHolder.size.height/4.0)));
    
    
    roundCoinCollectedTitleLabel.zPosition = mainBoard.zPosition + 1;
    
    // Coin Collected Score Label;
    roundCoinCollectedLabel = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
    
    roundCoinCollectedLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize]/mainBoard.xScale;
    roundCoinCollectedLabel.fontColor = [UIColor yellowColor];
    roundCoinCollectedLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"coinCount"];
    roundCoinCollectedLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [roundCoinCollectedHolder addChild:roundCoinCollectedLabel];
    
    roundCoinCollectedLabel.position = CGPointMake(-roundCoinCollectedHolder.size.width/2, roundCoinCollectedLabel.position.y/2 );
    roundCoinCollectedLabel.zPosition = mainBoard.zPosition + 1;
    
    //Close Button :
    SKSpriteNode *closeButton = [SKSpriteNode spriteNodeWithImageNamed:@"btn_big_symbol_cross_red"];
    closeButton.anchorPoint = CGPointMake(0.5, 0.5);
    closeButton.size = CGSizeMake((mainBoard.size.width/7.5)/mainBoard.xScale, (mainBoard.size.width/7.5)/mainBoard.yScale);
    [mainBoard addChild:closeButton];
    
    closeButton.position = CGPointZero;
    closeButton.position = CGPointMake(closeButton.position.x + mainBoard.size.width/2 - closeButton.size.width/4, mainBoard.size.height/2 - closeButton.size.height/4);
    closeButton.zPosition = mainBoard.zPosition + 1;
    closeButton.name = @"closeButton";
    
    gameOverNode.zPosition = 10000;
    [gameOverNode addChild:mainBoard];

    // Determine if we should show the "Continue" or the "Buy Coins Button"
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"coinCount"] >= 50) {
        [self addContinueGameButtonToGameOverScreen];
    }else{
        if([Chartboost hasRewardedVideo:CBLocationHomeScreen]) {
            NSLog(@"ChartBoost Has an Ad");
            [Chartboost showRewardedVideo:CBLocationHomeScreen];
        }else{
            NSLog(@"ChartBoost has no ad at GameOverScreen");
            [self addBuyCoinsToContinueButtonToGameOverScreen];
        }
    }

    [self addChild:gameOverNode];
}


// Sound Methods

-(void)doVolumeFade{
    
    AVAudioPlayer *_backGroundMusicPlayer = [[TexturePreLoader sharedTexturePreLoader] backgroundMusicPlayer];
    
    
    if (_backGroundMusicPlayer.volume > 0.1) {
        _backGroundMusicPlayer.volume = self.backgroundMusicPlayer.volume - 0.1;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.2];
    } else {
        // Stop and get the sound ready for playing again
        [_backGroundMusicPlayer stop];
        _backGroundMusicPlayer.currentTime = 0;
        _backGroundMusicPlayer.volume = 1.0;
    }
}

-(void)doVolumeBoostUp{
    if (self.backgroundMusicPlayer.volume < 1.0) {
        self.backgroundMusicPlayer.volume = self.backgroundMusicPlayer.volume + 0.1;
        [self performSelector:@selector(doVolumeBoostUp) withObject:nil afterDelay:0.2];
    } else {
        // Stop and get the sound ready for playing again
        // [self.backgroundMusicPlayer stop];
        // self.backgroundMusicPlayer.currentTime = 0;
        // [self.backgroundMusicPlayer prepareToPlay];
        // self.backgroundMusicPlayer.volume = 1.0;
    }
}

-(void)crashCopterSound{
    //play background sound
    NSError *error;
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"crash" withExtension:@"mp3"];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    
    self.backgroundMusicPlayer.numberOfLoops = -1;
    //[self.backgroundMusicPlayer prepareToPlay];
    //  self.backgroundMusicPlayer.volume = 0.5;
    
    //[self.backgroundMusicPlayer play];
    [self performSelectorInBackground:@selector(playMusicBackground) withObject:nil];
    //    [self doVolumeBoostUp];
}

-(void)playMusicBackground{
    [self.backgroundMusicPlayer play];
}

-(void)transitionToStore{
    SKTransition *transitionToStore = [SKTransition fadeWithDuration:1.0];
    storeScene *theStore = [storeScene sceneWithSize:self.view.bounds.size];
    theStore.scaleMode = SKSceneScaleModeAspectFill;
    
    [self.view presentScene:theStore transition:transitionToStore];
}

-(void)closeGame{
    SKTransition *transitionToMainScreen = [SKTransition fadeWithDuration:1.0];
   //Prashanth this is hard coded here.. coz the first screen, with the play pubtton of class GameScene is hared coded by the .sks file. need to work on this later. and see how it behaves on other devices, for now lets just keep this like this.

    GameScene *theGameScene = [GameScene sceneWithSize:CGSizeMake(1024, 768)];

    //UIScreen *mainScreen = [UIScreen mainScreen];
    //GameScene *theGameScene = [GameScene sceneWithSize:CGSizeMake(self.size.width * mainScreen.scale, self.size.height * mainScreen.scale)];
    //GameScene *theGameScene = [GameScene sceneWithSize:CGSizeMake(self.size.width, self.size.height)];

    theGameScene.scaleMode = SKSceneScaleModeAspectFill;
     
    [self doVolumeFade];
    
    [self.view presentScene:theGameScene transition:transitionToMainScreen];
}

-(BOOL)buyCoinsFromAppStore{
    
    // Start Pulsing the Buy Button.
    [self pulseNode:gameOverScreenBuyToContinueButton byScale:1.1];
    
    BOOL __block purchaseInProgress;
    [[PrashWordSmithPurchaseManager sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            for (SKProduct *prod in products) {
                NSLog(@"SKProduct is %@",prod);
                if ([prod.productIdentifier isEqualToString:@"copter_buy_500_coins"]) {
                    [[PrashWordSmithPurchaseManager sharedInstance] buyProduct:prod];
                    purchaseInProgress = YES;
                    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"copterBought500Coins"];
                    
                    NSLog(@"Now I Am Observing the Notificaiton.. Waiting for Purchase to comploete.");
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(purchaseProcessCompleted:)
                                                                 name:IAPHelperProductPurchasedNotification
                                                               object:nil];
                    break;
                }
            }
        }
        else if (!success){
            purchaseInProgress = NO;
        }
    }];
    return purchaseInProgress;
}

-(void)addTapHereLabel{
    // If there are any old labels remove it.
    [tapHereLabel removeFromParent];
    
    tapHereLabel = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
//    tapHereLabel.text = @"TAP TO FLY";
  
    tapHereLabel.text = NSLocalizedString(@"Tap_To_Begin", nil);
    [tapHereLabel removeAllActions];
    
    SKAction* scoreAction = [SKAction scaleBy:1.25 duration:0.5];
    SKAction* revertAction = [SKAction scaleTo:1 duration:0.5];
    SKAction* completeAction = [SKAction repeatActionForever:[SKAction sequence:@[scoreAction, revertAction]]];

    [tapHereLabel runAction:completeAction];
//    tapHereLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize]f;
    
    [self addChild:tapHereLabel];
    tapHereLabel.zPosition = theCopter.zPosition + 1;
    tapHereLabel.fontColor = [UIColor whiteColor];
    tapHereLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height/5);
    tapHereLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize];
}

-(void)addContinueGameButtonToGameOverScreen{
    // Continue Game Round Button;
    gameOverScreenBuyToContinueButton = [SKSpriteNode spriteNodeWithImageNamed:@"btn_big_menu_play_green"];
    gameOverScreenBuyToContinueButton.anchorPoint = CGPointMake(0.5, 0.5);
    gameOverScreenBuyToContinueButton.size = CGSizeMake(mainBoard.size.height * (1.0/2.25)/mainBoard.yScale, mainBoard.size.height * (1.0/2.25)/mainBoard.yScale);
    [mainBoard addChild:gameOverScreenBuyToContinueButton];
    
    gameOverScreenBuyToContinueButton.position = CGPointZero;
    gameOverScreenBuyToContinueButton.position = CGPointMake(gameOverScreenBuyToContinueButton.position.x, gameOverScreenBuyToContinueButton.position.y - mainBoard.size.height/4);
    
    gameOverScreenBuyToContinueButton.name = @"continueGameBoard";
    gameOverScreenBuyToContinueButton.zPosition = mainBoard.zPosition + 1;
    
    // Game Instructions.
//    gameOverScreenIntructionsLabel2 = [SKLabelNode labelNodeWithText:@"(50 Coins)"];
    gameOverScreenIntructionsLabel2 = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
//    [gameOverScreenIntructionsLabel2 setText:@"(50 Coins)"];
    [gameOverScreenIntructionsLabel2 setText:[NSString stringWithFormat:@"(50 %@)",NSLocalizedString(@"Gold_Coins", nil)]];
    
    [mainBoard addChild:gameOverScreenIntructionsLabel2];
    gameOverScreenIntructionsLabel2.position = CGPointMake(gameOverScreenIntructionsLabel2.position.x, gameOverScreenBuyToContinueButton.position.y + gameOverScreenBuyToContinueButton.size.height/2 + gameOverScreenIntructionsLabel2.frame.size.height/3);
    gameOverScreenIntructionsLabel2.fontColor = [UIColor yellowColor];
    gameOverScreenIntructionsLabel2.fontSize = [[TexturePreLoader sharedTexturePreLoader] smallFontSize]/mainBoard.xScale;
    
//    gameOverScreenIntructionsLabel1 = [SKLabelNode labelNodeWithText:@"Continue?"];
    gameOverScreenIntructionsLabel1 = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];

//    [gameOverScreenIntructionsLabel1 setText:@"Continue?"];
    [gameOverScreenIntructionsLabel1 setText:NSLocalizedString(@"Continue_Game", nil)];
    
    
    gameOverScreenIntructionsLabel1.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize]/mainBoard.xScale;
    [mainBoard addChild:gameOverScreenIntructionsLabel1];
    gameOverScreenIntructionsLabel1.position = CGPointMake(gameOverScreenIntructionsLabel1.position.x, gameOverScreenIntructionsLabel2.position.y + gameOverScreenIntructionsLabel2.frame.size.height);

}

-(void)addBuyCoinsToContinueButtonToGameOverScreen{
    
    // Continue Game Round Button;
    gameOverScreenBuyToContinueButton = [SKSpriteNode spriteNodeWithImageNamed:@"btn_medium_buy"];
    gameOverScreenBuyToContinueButton.anchorPoint = CGPointMake(0.5, 0.5);
    gameOverScreenBuyToContinueButton.size = CGSizeMake(mainBoard.size.height * (1.0/3)/mainBoard.yScale, mainBoard.size.height * (1.0/3)/mainBoard.yScale);
    [mainBoard addChild:gameOverScreenBuyToContinueButton];
    
    gameOverScreenBuyToContinueButton.position = CGPointMake(gameOverScreenBuyToContinueButton.position.x, gameOverScreenBuyToContinueButton.position.y - mainBoard.size.height/4);
    gameOverScreenBuyToContinueButton.name = @"BuyCoinsFromAppStore";
    gameOverScreenBuyToContinueButton.zPosition = mainBoard.zPosition + 1;
    
    // Game Instructions.
    gameOverScreenIntructionsLabel2 = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
#warning Localization Missing Here.
    [gameOverScreenIntructionsLabel2 setText:@"(Buy 500 Coins)"];

    [mainBoard addChild:gameOverScreenIntructionsLabel2];
    
    gameOverScreenIntructionsLabel2.position = CGPointMake(gameOverScreenIntructionsLabel2.position.x, gameOverScreenBuyToContinueButton.position.y + gameOverScreenBuyToContinueButton.size.height/2 + gameOverScreenIntructionsLabel2.frame.size.height/3);
    
    gameOverScreenIntructionsLabel2.fontColor = [UIColor yellowColor];
    gameOverScreenIntructionsLabel2.fontSize = [[TexturePreLoader sharedTexturePreLoader] smallFontSize]/mainBoard.xScale;
    gameOverScreenIntructionsLabel2.name = @"buyCoinsIntructionsLabel2";
    
    gameOverScreenIntructionsLabel1 = [SKLabelNode labelNodeWithFontNamed:@"HVDComicSerifPro"];
#warning Localization Missing Here.
    [gameOverScreenIntructionsLabel1 setText:@"Not Enough Coins !"];
    gameOverScreenIntructionsLabel1.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize]/mainBoard.xScale;
    [mainBoard addChild:gameOverScreenIntructionsLabel1];
    gameOverScreenIntructionsLabel1.position = CGPointMake(gameOverScreenIntructionsLabel1.position.x, gameOverScreenIntructionsLabel2.position.y + gameOverScreenIntructionsLabel2.frame.size.height);
    gameOverScreenIntructionsLabel1.name = @"buyCoinsIntructionsLabel1";
}

-(void)rewardUser50CoinsAndRestart{
    
    // Purchase was successful. Update the Gold Coin Count
    NSInteger goldCoinCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"coinCount"];
    goldCoinCount += 50;
    
    [[NSUserDefaults standardUserDefaults] setInteger:goldCoinCount forKey:@"coinCount"];
    [self addContinueGameButtonToGameOverScreen];
    roundCoinCollectedLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"coinCount"];
    [self pulseNode:roundCoinCollectedLabel byScale:1.5];
}

-(void)userCancelledVideoPromptToBuy{
    NSLog(@"The User Cancelled the Rewward thing.. So I am going to amke him buy.");
    
    // FOr Some reason Chartboost is calling cancelled the video, even if we see the complete Video.
    // SO I am chaninging this to check and show the buy screen only if
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"coinCount"] <= 50) {
        [self addBuyCoinsToContinueButtonToGameOverScreen];
    }    
}




@end

