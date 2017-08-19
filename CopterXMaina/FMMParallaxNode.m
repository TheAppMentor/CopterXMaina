//
//  FMMParallaxNode.m
//  SpaceShooter
//
//  Created by Tony Dahbura on 9/9/13.
//  Copyright (c) 2013 fullmoonmanor. All rights reserved.
//

#import "FMMParallaxNode.h"
#import "GameConstants.h"
#import "TexturePreLoader.h"

//static const float BG_POINTS_PER_SEC = 50;

@interface FMMParallaxNode (){
    
    NSArray * _obstacleTypes;
    CGSize parentSceneSize;
}

// Declaring the Coin node as a property, so it does not need to recrated everytime.
@property (strong,nonatomic) SKSpriteNode *theCoinNode;
@property (strong,nonatomic) SKSpriteNode *theBombNode;

@property (strong,nonatomic) SKPhysicsBody* goldCoinPhysicsBody;

@end


@implementation FMMParallaxNode{
    
    __block NSMutableArray *_backgrounds;
    NSInteger _numberOfImagesForBackground;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _deltaTime;
    BOOL _randomizeDuringRollover;
}

-(SKPhysicsBody *)goldCoinPhysicsBody{
        // Define Gold Coin Physics Bodies.
        _goldCoinPhysicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.theCoinNode.size];
        _goldCoinPhysicsBody.categoryBitMask = goldCoinCategory;
        _goldCoinPhysicsBody.contactTestBitMask = goldCoinCategory | copterCategory;
        _goldCoinPhysicsBody.collisionBitMask = goldCoinCategory | copterCategory;
        _goldCoinPhysicsBody.affectedByGravity = NO;
        // Giving it a very small mass, so that when it hits the copter,, it doesnt affect the dynamics of the copter.
        _goldCoinPhysicsBody.mass = 0.00001;
    return _goldCoinPhysicsBody;
}

-(SKSpriteNode *)theCoinNode{
    
    _theCoinNode = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:[[TexturePreLoader sharedTexturePreLoader] theCoinNodeSize]];

    _theCoinNode.name = @"GoldCoin";
    
    [_theCoinNode runAction:self.spinCoinAction];
    
    return _theCoinNode;                                
}

-(SKSpriteNode *)theBombNode{
    // The BOMB :
    //_theBombNode = [SKSpriteNode spriteNodeWithTexture:[self.bombTextures firstObject]];
    _theBombNode = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:[[TexturePreLoader sharedTexturePreLoader] theBombNodeSize]];
//    _theBombNode.size = CGSizeMake(30, 37);
    
    [_theBombNode runAction:self.animateBomb];
    
    return _theBombNode;

}

- (instancetype)initWithBackground:(NSString *)file size:(CGSize)size pointsPerSecondSpeed:(float)pointsPerSecondSpeed{
    // we add the file 3 times to avoid image flickering
    
//#warning Prashanth testing this thing where I am loading all textues beforehand.
//    [self loadAllTextures];
        
    return [self initWithBackgrounds:@[file, file, file]
                                size:size
                pointsPerSecondSpeed:pointsPerSecondSpeed];
}

- (instancetype)initWithBackgrounds:(NSArray *)files size:(CGSize)size pointsPerSecondSpeed:(float)pointsPerSecondSpeed{
    if (self = [super init])
    {
        parentSceneSize = size;
        _obstacleTypes = @[@"singleCoin",@"bomb",@"eatingPlant",@"WheelBlade",@""];
        _pointsPerSecondSpeed = pointsPerSecondSpeed;
        _numberOfImagesForBackground = [files count];
        _backgrounds = [NSMutableArray arrayWithCapacity:_numberOfImagesForBackground];
        _randomizeDuringRollover = NO;
            [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

              SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:obj];

            node.size = size;
            node.anchorPoint = CGPointZero;
            node.position = CGPointMake(size.width * idx, 0.0);
            node.name = @"background";
            [_backgrounds addObject:node];
            [self addChild:node];
        }];
    }
    return self;
}

// Add new method, above update loop
- (CGFloat)randomValueBetween:(CGFloat)low andValue:(CGFloat)high {
    return (((CGFloat) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

- (void)randomizeNodesPositions{
    [_backgrounds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        SKSpriteNode *node = (SKSpriteNode *)obj;
        [self randomizeNodePosition:node];
        
    }];
    //flag it for random placement each main scroll through
    _randomizeDuringRollover = YES;
    
}

- (void)randomizeNodePosition:(SKSpriteNode *)node{
    
    //I liked this look better for randomizing the placement of the nodes!
    CGFloat randomYPosition = [self randomValueBetween:node.size.height/2.0
                                              andValue:(self.frame.size.height-node.size.height/2.0)];
    node.position = CGPointMake(node.position.x,randomYPosition);
    
}

- (void)update:(NSTimeInterval)currentTime{
    //To compute velocity we need delta time to multiply by points per second
    if (_lastUpdateTime) {
        _deltaTime = currentTime - _lastUpdateTime;
    } else {
        _deltaTime = 0;
    }
    _lastUpdateTime = currentTime;
    
    _pointsPerSecondSpeed = self.gameSpeedF;
    
    CGPoint bgVelocity = CGPointMake(-_pointsPerSecondSpeed, 0.0);
    CGPoint amtToMove = CGPointMake(bgVelocity.x * _deltaTime, bgVelocity.y * _deltaTime);
    self.position = CGPointMake(self.position.x+amtToMove.x, self.position.y+amtToMove.y);
    SKNode *backgroundScreen = self.parent;
    
    [_backgrounds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKSpriteNode *bg = (SKSpriteNode *)obj;
        CGPoint bgScreenPos = [self convertPoint:bg.position
                                          toNode:backgroundScreen];
        if (bgScreenPos.x <= -bg.size.width)
        {
            bg.position = CGPointMake(bg.position.x + (bg.size.width * _numberOfImagesForBackground), bg.position.y);
            if (_randomizeDuringRollover) {
                [self randomizeNodePosition:bg];
            }
        }
        
    }];
}

- (void)updateObstacles:(NSTimeInterval)currentTime{
    //To compute velocity we need delta time to multiply by points per second
    if (_lastUpdateTime) {
        _deltaTime = currentTime - _lastUpdateTime;
    } else {
        _deltaTime = 0;
    }
    _lastUpdateTime = currentTime;
    
    _pointsPerSecondSpeed = self.gameSpeedF;
    
    CGPoint bgVelocity = CGPointMake(-_pointsPerSecondSpeed, 0.0);
    CGPoint amtToMove = CGPointMake(bgVelocity.x * _deltaTime, bgVelocity.y * _deltaTime);
    self.position = CGPointMake(self.position.x+amtToMove.x, self.position.y+amtToMove.y);
    SKNode *backgroundScreen = self.parent;
    
    [_backgrounds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKSpriteNode *bg = (SKSpriteNode *)obj;
        CGPoint bgScreenPos = [self convertPoint:bg.position
                                          toNode:backgroundScreen];
        // Prashanth I doubled this coz anchor point is CGPOINt Zero and I want to obstacles to get added only after it completely goes off screen.
        if (bgScreenPos.x <= -bg.size.width * 2.5)
        {
            bg.position = CGPointMake(bg.position.x + (bg.size.width * _numberOfImagesForBackground), bg.position.y);
            [bg removeAllChildren];

            [self addObstaclesToNode:bg];
            
            if (_randomizeDuringRollover) {
                [self randomizeNodePosition:bg];
            }
        }
    }];
}

- (void)addObstaclesToNode:(SKSpriteNode *)node{
    
    // Set Obstacle Width
//    float obstacleWidth = node.size.width/12;
    float obstacleWidth = [[TexturePreLoader sharedTexturePreLoader] obstacleWidth];
    float obstacleUnitSize = node.size.height;
    
    NSArray *chosenObst = GAME_OBSTACLES[(NSUInteger)[self randomValueBetween:0 andValue:GAME_OBSTACLES.count]];
    
    
    for (int i=1; i<= chosenObst.count; i++) {
        NSString *obs = [chosenObst objectAtIndex:(i-1)];
        int subStr1 = [[obs substringToIndex:1] intValue];
        int subStr2 = [[obs substringWithRange:NSMakeRange(1, 1)] intValue];
        
        SKTexture *theUpperObstacleTexture = nil;
        if (subStr1 == 2) {
            theUpperObstacleTexture = [[TexturePreLoader sharedTexturePreLoader] upperObstacleTallTexture];
            //obstacleWidth = 70.0f;

        }else if (subStr1 == 1){
            theUpperObstacleTexture = [[TexturePreLoader sharedTexturePreLoader] upperObstacleMediumTexture];
            //obstacleWidth = 65.0f;

        }else if (subStr1 == 0){
            theUpperObstacleTexture = [[TexturePreLoader sharedTexturePreLoader] upperObstacleShortTexture];
            //obstacleWidth = 60.0f;

        }
        //        //Create Upper Obstacle.

        // Sometimes the upper obstacle is a too long, making the game tough. so shortening it a little.
        float theSubString1 = subStr1 == 2 ? 1.90 : subStr1;
        
        SKSpriteNode *upperObstacle = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor]
                                                                   size:CGSizeMake(obstacleWidth, obstacleUnitSize * (theSubString1/4.0))];
        
        [upperObstacle setTexture:theUpperObstacleTexture];
        
        SKTexture *theLowerObstacleTexture = nil;
        if (subStr2 == 2) {
            theLowerObstacleTexture = [[TexturePreLoader sharedTexturePreLoader] lowerObstacleTallTexture];
           // obstacleWidth = 70.0f;

        }else if (subStr2 == 1){
            theLowerObstacleTexture = [[TexturePreLoader sharedTexturePreLoader] lowerObstacleMediumTexture];
          //  obstacleWidth = 65.0f;

        }else if (subStr2 == 0){
            theLowerObstacleTexture = [[TexturePreLoader sharedTexturePreLoader] lowerObstacleShortTexture];
            //obstacleWidth = 60.0f;

        }
        //Create Lower Obstacle.
        SKSpriteNode *lowerObstacle = [SKSpriteNode spriteNodeWithColor:[UIColor redColor]
                                                                   size:CGSizeMake(obstacleWidth, obstacleUnitSize * (subStr2/4.0))];

        [lowerObstacle setTexture:theLowerObstacleTexture];
        
        upperObstacle.position = CGPointMake(node.size.width+obstacleWidth/2 + (i * node.size.width/3), node.size.height-upperObstacle.size.height/2);
        lowerObstacle.position = CGPointMake(node.size.width+obstacleWidth/2 + (i * node.size.width/3), lowerObstacle.size.height/2);
        upperObstacle.anchorPoint = CGPointMake(0.5, 0.5);
        lowerObstacle.anchorPoint = CGPointMake(0.5, 0.5);
        
        SKPhysicsBody *upperPhyBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(upperObstacle.size.width, upperObstacle.size.height)];
        upperPhyBody.dynamic = NO;
        upperPhyBody.affectedByGravity = NO;
        upperPhyBody.categoryBitMask = obstacleCategory;
        upperPhyBody.contactTestBitMask = obstacleCategory | copterCategory;
        upperPhyBody.collisionBitMask = obstacleCategory | copterCategory;
        upperObstacle.physicsBody = upperPhyBody;
        if (upperPhyBody) {
//            NSLog(@"UpperPhyBody %@",upperPhyBody);
//            NSLog(@"UpperObstacle %@",upperObstacle);
        }
        
        SKPhysicsBody *lowerPhyBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(lowerObstacle.size.width, lowerObstacle.size.height)];
        lowerPhyBody.dynamic = NO;
        lowerPhyBody.affectedByGravity = NO;
        lowerPhyBody.categoryBitMask = obstacleCategory;
        lowerPhyBody.contactTestBitMask = obstacleCategory | copterCategory;
        lowerPhyBody.collisionBitMask = obstacleCategory | copterCategory;
        lowerObstacle.physicsBody = lowerPhyBody;
        
        [node addChild:upperObstacle];
        [node addChild:lowerObstacle];
     
        [self addGemsToNode:node atUpperNode:upperObstacle lowerNode:lowerObstacle];
    }
}

- (void)addGemsToNode:(SKSpriteNode *)node atUpperNode:(SKSpriteNode *)upperNode lowerNode:(SKSpriteNode *)lowerNode {

 // At Appropriate Places.. add Gems to the Scene...
    
    /* Choose From one of these Options :
    
     When there is an Obstacle at the Scene.
        1. NO Gems at any Obstacle ... Use this when you have both Upper and Lower obstacles.
        2. Gem only at Upper Obstacle.
        3. Gem only at Lower Obstacle.
        4. Gem at Random Position.

     When Both Upper and Lower Obstacles are Missing :
        1. No Gems on the scene.
        2. String of Gems in middle of the Screen.
        3. String of Gems Close to the Floor.
        4. String of Gems Close to the Roof.
     */
    
//   #warning Prashanth this is what is causing the stutter problem.
    // Detect if there is an Obstacle at the Scene.
    
    
    // Check if we have Any Obstacle on the Scene.
    if (upperNode.size.height > 0.0f || lowerNode.size.height > 0.0f) {

        if (upperNode.size.height > 0.0f && lowerNode.size.height == 0.0f) {
            // We Have only Upper Obstacle.
            
            if ((int)[self randomValueBetween:0.0 andValue:4.0] == 1){
                // If we are showing an obstacle.
                SKSpriteNode *theObstacle = [self chooseARandomObstacle];
                
                if ([theObstacle.name isEqualToString:@"goldCoinHolder"]) {
                    
                    float xSpacing = theObstacle.children.count == 1 ? 12.5 : 25.0;
                    float ySpacing = 50.0;

                    theObstacle.position = CGPointMake(upperNode.position.x - [theObstacle calculateAccumulatedFrame].size.width/2 + xSpacing, upperNode.position.y - upperNode.size.height/2 - ySpacing);
                }else{
                    theObstacle.position = CGPointMake(upperNode.position.x, upperNode.position.y - upperNode.size.height/2 - theObstacle.size.height);
                }
                
                theObstacle.zPosition = node.zPosition + 1;
                
                [node addChild:theObstacle];
            }
        }
        else if (upperNode.size.height == 0 && lowerNode.size.height > 0){
            // We have Only Lower Obstacle
            // Choose a Random Option 0-1  i.e 0 = No Obstacle, 1 = Obstacle.
            
            if ((int)[self randomValueBetween:0.0 andValue:3.0] == 1){
            SKSpriteNode *theObstacle = [self chooseARandomObstacle];

                
                if ([theObstacle.name isEqualToString:@"goldCoinHolder"]) {
                    float xSpacing = theObstacle.children.count == 1 ? 12.5 : 25.0;
                    float ySpacing = 50.0;

                    theObstacle.position = CGPointMake(lowerNode.position.x - [theObstacle calculateAccumulatedFrame].size.width/2 + xSpacing
, lowerNode.position.y + lowerNode.size.height/2 + ySpacing);
                    
                }
            theObstacle.zPosition = node.zPosition + 1;
            [node addChild:theObstacle];
            }
        }
        else if (upperNode.size.height > 0 && lowerNode.size.height > 0){
            // We have both Upper and Lower obstacles.
            // Choose a Random Option 0-2

            int min = 0;
            NSUInteger max = 3;
            int chooseObst =  arc4random()%(max - min) + min;
            
            if (chooseObst == 0) {
                // Gem Only at Upper Obstacle.
                SKSpriteNode *theObstacle =  [self chooseARandomObstacle];
                
                if ([theObstacle.name isEqualToString:@"goldCoinHolder"]) {
                    float xSpacing = theObstacle.children.count == 1 ? 12.5 : 25.0;
                    float ySpacing = 50.0;
                    
                    theObstacle.position = CGPointMake(upperNode.position.x - [theObstacle calculateAccumulatedFrame].size.width/2
+ xSpacing, upperNode.position.y - upperNode.size.height/2 - ySpacing);
                }
                
                theObstacle.zPosition = node.zPosition + 1;
                [node addChild:theObstacle];
                
            }else if (chooseObst == 1){
                // Gem Only At Lower Obstacle.
                SKSpriteNode *theObstacle = [self chooseARandomObstacle];
                float xSpacing = theObstacle.children.count == 1 ? 12.5 : 25.0;
                float ySpacing = 50.0;

                
                if ([theObstacle.name isEqualToString:@"goldCoinHolder"]) {
                    theObstacle.position = CGPointMake(lowerNode.position.x - [theObstacle calculateAccumulatedFrame].size.width/2 + xSpacing
, lowerNode.position.y + lowerNode.size.height/2 + ySpacing);

                }
                
                theObstacle.zPosition = node.zPosition + 1;
                [node addChild:theObstacle];
                
            }else if (chooseObst == 2){
                // Gem at Both Obstacles.
                SKSpriteNode *theObstacleUpper = [self chooseARandomObstacle];

                
                if ([theObstacleUpper.name isEqualToString:@"goldCoinHolder"]) {
                    float xSpacing = theObstacleUpper.children.count == 1 ? 12.5 : 25.0;
                    float ySpacing = theObstacleUpper.children.count == 1 ? 50 : 50;

                    theObstacleUpper.position = CGPointMake(upperNode.position.x - [theObstacleUpper calculateAccumulatedFrame].size.width/2 + xSpacing
, upperNode.position.y - upperNode.size.height/2 - ySpacing);
                }
                
                theObstacleUpper.zPosition = node.zPosition + 1;
                [node addChild:theObstacleUpper];
                
                SKSpriteNode *theObstacleLower = [self chooseARandomObstacle];

                
                
                if ([theObstacleLower.name isEqualToString:@"goldCoinHolder"]) {
                    float xSpacing = theObstacleLower.children.count == 1 ? 12.5 : 25.0;
                    float ySpacing = theObstacleLower.children.count == 1 ? 50 : 50;

                    theObstacleLower.position = CGPointMake(lowerNode.position.x - [theObstacleLower calculateAccumulatedFrame].size.width/2 + xSpacing
, lowerNode.position.y + lowerNode.size.height/2 + ySpacing);
                }
                
                theObstacleLower.zPosition = node.zPosition + 1;
                [node addChild:theObstacleLower];
                
            }else if (chooseObst == 3){
                // Put gem in between the two Obstacles.

            }
        }
    }
    else if (upperNode.size.height == 0.0f && lowerNode.size.height == 0.0f){
    }
}

// Add Random Gem/Bomb at Position
- (SKSpriteNode *)chooseARandomObstacle{
    
    int chooseObst =  (int)[self randomValueBetween:0.0 andValue:4.0];
    SKSpriteNode *tempNode = [SKSpriteNode node];
    
    if (chooseObst == 0) {
        // Here I will place a single Coin.
        
        tempNode = [self makeGoldCoinStringContainingCoinCount:[NSNumber numberWithInt:1]];
        tempNode.anchorPoint = CGPointMake(0.0, 0.5);
        
    }else if (chooseObst == 1){
        // Here we will place a Bomb.
        tempNode = self.theBombNode;
        
        // Define Gold Coin Physics Bodies.
        SKPhysicsBody *bombBody = [SKPhysicsBody bodyWithRectangleOfSize:tempNode.size];
        bombBody.categoryBitMask = bombCategory;
        bombBody.contactTestBitMask = bombCategory | copterCategory;
        bombBody.collisionBitMask = bombCategory | copterCategory;
        bombBody.dynamic = NO;
        bombBody.affectedByGravity = NO;
        tempNode.physicsBody = bombBody;
        
    }else{
        // Here is we will palce multiple coins. How many coins.. is decided in makeGoldCoin method.
        tempNode = [self makeGoldCoinStringContainingCoinCount:nil];
        tempNode.anchorPoint = CGPointMake(0.5, 0.5);
        
    }
   return tempNode;
}

- (SKSpriteNode *)makeGoldCoinStringContainingCoinCount:(NSNumber *)coinCount{
    
    int randomNumberOfCollectibles;
    
    if (coinCount.integerValue ==  0 || !coinCount) {
        randomNumberOfCollectibles = (int)[self randomValueBetween:0.0 andValue:4.0];

    }else{
        randomNumberOfCollectibles = coinCount.intValue;
    }
    
    int randomPattern = (int)[self randomValueBetween:0.0 andValue:3.0];
    
    SKSpriteNode *goldCoinHolder = [SKSpriteNode node];
    goldCoinHolder.name = @"goldCoinHolder";
    
    for (int i = 0 ; i<randomNumberOfCollectibles; i++) {
        SKSpriteNode *tempNode = nil;
        tempNode = self.theCoinNode;
        
        tempNode.physicsBody = self.goldCoinPhysicsBody;
        
        // Prashanth Forcing this Random pattern thing to a straight line.
        randomPattern = 0;
        
        // Arrange Gold Coins in  pattern.
        switch (randomPattern) {
            case 0:
                // Arrange coins in a straight line.
                tempNode.position = CGPointMake(i * 100, self.parent.position.y);
                break;
                
            case 1:
                // Arrange coins in a sin Wave.
                tempNode.position = CGPointMake(i * 100, (50 * sinf(M_PI/2 * i) + self.parent.position.y));
                break;
                
            case 2:
                // Arrange coins in a cos wave.
                tempNode.position = CGPointMake(i * 100, (50 * cosf(M_PI/2 * i) + self.parent.position.y));
                break;
                
            default:
                break;
        }
        [goldCoinHolder addChild:tempNode];
    }

    goldCoinHolder.anchorPoint = CGPointMake(0.5, 0.0);
    
    return goldCoinHolder;
}

@end

