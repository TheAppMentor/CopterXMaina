//
//  scoreNode.m
//  theCopter
//
//  Created by Prashanth Moorthy on 10/17/14.
//  Copyright (c) 2014 Sprite. All rights reserved.
//

#import "scoreNode.h"
#import "TexturePreLoader.h"

@interface scoreNode (){
    BOOL haveAlreadyDetectedHighScore;

}

@end

@implementation scoreNode{
    CGSize theNodeSize;
    SKLabelNode *scoreLabel;
    SKLabelNode *highScoreLabel;
    SKLabelNode *coinCountLabel;
    SKLabelNode *textScoreLabel;
    
    NSString* fontToUse;
    //NSUInteger roundTotalScore;
    NSUInteger currentHighScore;
    SKLabelNode* highScoreLabelDesc;
}

-(instancetype)initwithSize:(CGSize)theSize{
    if ([self init]) {
        theNodeSize = theSize;
    }
    return self;
}

-(void)makeScoreLabels{
    
    [self addObserver:[GameCenterHelper sharedGameKitHelper]
           forKeyPath:@"roundScore"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    [self addObserver:[GameCenterHelper sharedGameKitHelper]
           forKeyPath:@"roundCoinCollected"
              options:NSKeyValueObservingOptionNew
              context:nil];
    
    fontToUse = @"HVDComicSerifPro";
    
    //self.newHighScore = YES;
    haveAlreadyDetectedHighScore = NO;
    self.haveToWriteHighScoreToDisk = NO;

    // Make the High Score Label
    
    highScoreLabelDesc = [SKLabelNode labelNodeWithFontNamed:fontToUse];
    //highScoreLabelDesc.text = @"Best";
    highScoreLabelDesc.text = NSLocalizedString(@"Best_Score", nil);
    highScoreLabelDesc.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize];
    highScoreLabelDesc.position = CGPointMake(theNodeSize.width/2, theNodeSize.height - (highScoreLabelDesc.frame.size.height * 1.5));
    [self addChild:highScoreLabelDesc];

    highScoreLabel = [SKLabelNode labelNodeWithFontNamed:fontToUse];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"highScore"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"highScore"];
    }
    currentHighScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highScore"];
    highScoreLabel.text =[[NSUserDefaults standardUserDefaults] stringForKey:@"highScore"];
    highScoreLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize];
    highScoreLabel.position = CGPointMake(theNodeSize.width/2, highScoreLabelDesc.position.y - highScoreLabelDesc.frame.size.height * 1.5);

    [self addChild:highScoreLabel];
    
    // Make the Text Score Label
    SKLabelNode* textScoreLabelDesc = [SKLabelNode labelNodeWithFontNamed:fontToUse];
//    textScoreLabelDesc.text = @"Score";
    textScoreLabelDesc.text = NSLocalizedString(@"Score", nil);

    textScoreLabelDesc.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize];
    textScoreLabelDesc.position = CGPointMake(theNodeSize.width/6, highScoreLabelDesc.position.y);
    [self addChild:textScoreLabelDesc];

    scoreLabel = [SKLabelNode labelNodeWithFontNamed:fontToUse];
    
    if (![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"gameScore"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"gameScore"];
    }
    self.roundTotalScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"gameScore"];
    scoreLabel.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"gameScore"];
    scoreLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize];
    scoreLabel.position = CGPointMake(theNodeSize.width/6, textScoreLabelDesc.position.y
                                      - textScoreLabelDesc.frame.size.height * 1.5);
    [self addChild:scoreLabel];
    
    // Make the Coin Count  Label
    SKLabelNode* textCoinCountLabelDesc = [SKLabelNode labelNodeWithFontNamed:fontToUse];
//    textCoinCountLabelDesc.text = @"Coins";
    textCoinCountLabelDesc.text = NSLocalizedString(@"Gold_Coins", nil);
    
    textCoinCountLabelDesc.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize];
    textCoinCountLabelDesc.position = CGPointMake(5 * (theNodeSize.width/6), highScoreLabelDesc.position.y);
    [self addChild:textCoinCountLabelDesc];

    coinCountLabel = [SKLabelNode labelNodeWithFontNamed:fontToUse];
    if (![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"coinCount"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"coinCount"];
    }
    coinCountLabel.text =[[NSUserDefaults standardUserDefaults] stringForKey:@"coinCount"] ;
    coinCountLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize];
    coinCountLabel.position = CGPointMake((theNodeSize.width/6) * 5, textCoinCountLabelDesc.position.y - textCoinCountLabelDesc.frame.size.height * 1.5);
    [self addChild:coinCountLabel];

}

-(void)updateScoreLabels{
    
    // Increment the Score Label.
    self.roundTotalScore++;
    self.roundScore++;
    
    char cString[20];
    sprintf (cString, "%lu", (unsigned long)self.roundTotalScore);
    scoreLabel.text = [[NSString alloc] initWithUTF8String:cString];
    
    if (self.roundTotalScore >= currentHighScore) {
        
        highScoreLabel.text = [[NSString alloc] initWithUTF8String:cString];
        
        if (!haveAlreadyDetectedHighScore) {
            haveAlreadyDetectedHighScore = YES;
            self.haveToWriteHighScoreToDisk = YES;
            
            [self runAction:[[TexturePreLoader sharedTexturePreLoader] playNewHighScoreSoundAction]];
            
            // Add the New Label to the Screen
            //******************************************************************************************************************************************
            // New High Score Node
            
            // New High Score Label
            SKSpriteNode *newHighScoreNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"element_new_score"] size:CGSizeMake(40, 30)];
            newHighScoreNode.zPosition = highScoreLabelDesc.zPosition + 1;
            newHighScoreNode.position = CGPointMake(highScoreLabelDesc.position.x - highScoreLabelDesc.frame.size.width/2, highScoreLabelDesc.position.y + newHighScoreNode.size.height/2);
            
            SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:0.2];
            SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.2];
            SKAction *fadeSequence = [SKAction sequence:@[fadeOut,fadeIn,[SKAction waitForDuration:0.2]]];
            SKAction *repeatFade = [SKAction repeatActionForever:fadeSequence];
            [newHighScoreNode runAction:repeatFade];
            //******************************************************************************************************************************************
            [self addChild:newHighScoreNode];
            
        }
    }
}

-(void)updateCoinCountLabel{
    
    self.roundCoinCollected++;
    
    //NSUInteger coinCount = [[coinCountLabel text] integerValue];
    NSUInteger coinCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"coinCount"];
    coinCount++;
    coinCountLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)coinCount];
    [[NSUserDefaults standardUserDefaults] setInteger:coinCount forKey:@"coinCount"];
}

-(void)saveNewHighScoreToDisk{
    if (self.haveToWriteHighScoreToDisk) {
        NSLog(@"NOW I am Saving the New Hight Score to Disk");
        [[NSUserDefaults standardUserDefaults] setObject:scoreLabel.text forKey:@"highScore"];
        
    }
}


- (void)reportScoreToGameCenter {
    NSLog(@"Now I am Reporting my RoundScore to Game Center");

    int64_t timeToComplete = [[[NSUserDefaults standardUserDefaults] valueForKey:@"gameScore"] integerValue];
    [[GameCenterHelper sharedGameKitHelper] reportScore:timeToComplete forLeaderboardID:@"TAM_APP_MENTOR"];
}

- (void)reportScoreHighScoreToGameCenter {
    int64_t timeToComplete = [[[NSUserDefaults standardUserDefaults] valueForKey:@"highScore"] integerValue];
    [[GameCenterHelper sharedGameKitHelper] reportScore:timeToComplete forLeaderboardID:@"TAM_APP_MENTOR"];
}

-(void)resetGameScoreToZero{
    NSLog(@"Now I am re-setting game Score to Zero");
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"gameScore"];
}

-(void)saveGameScoreForContinueGame{
    [[NSUserDefaults standardUserDefaults] setInteger:self.roundTotalScore forKey:@"gameScore"];
}

-(void)reduceCoinCountForContinueGame{
    NSUInteger coinCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"coinCount"];
    if (coinCount >= 50) {
        coinCount -= 50;
    }else{
        coinCount = 0;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:coinCount forKey:@"coinCount"];
}

-(void)dealloc{
    [self removeObserver:[GameCenterHelper sharedGameKitHelper] forKeyPath:@"roundScore"];
    [self removeObserver:[GameCenterHelper sharedGameKitHelper] forKeyPath:@"roundCoinCollected"];

}

@end


//-(void)updateScoreLabels{
//    
//    self.roundTotalScore++;
//    
//    if (self.roundTotalScore <= currentHighScore) {
//        self.newHighScore = NO;
//    }
//    
//    char cString[20];
//    sprintf (cString, "%lu", (unsigned long)self.roundTotalScore);
//    scoreLabel.text = [[NSString alloc] initWithUTF8String:cString];
//    
//    if (self.newHighScore) {
//        highScoreLabel.text = [[NSString alloc] initWithUTF8String:cString];
//        return;
//    }
//    
//    if (self.roundTotalScore > [highScoreLabel.text integerValue]) {
//        self.newHighScore = YES;
//        //[self runAction:[SKAction playSoundFileNamed:@"NewHighScore.wav" waitForCompletion:YES]];
//        [self runAction:[[TexturePreLoader sharedTexturePreLoader] playNewHighScoreSoundAction]];
//        
//        // Add the New Label to the Screen
//        //******************************************************************************************************************************************
//        // New High Score Node
//        
//        // New High Score Label
//        SKSpriteNode *newHighScoreNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:@"element_new_score"] size:CGSizeMake(40, 30)];
//        newHighScoreNode.zPosition = highScoreLabelDesc.zPosition + 1;
//        newHighScoreNode.position = CGPointMake(highScoreLabelDesc.position.x - highScoreLabelDesc.frame.size.width/2, highScoreLabelDesc.position.y + newHighScoreNode.size.height/2);
//        
//        SKAction *fadeOut = [SKAction fadeAlphaTo:0.0 duration:0.2];
//        SKAction *fadeIn = [SKAction fadeAlphaTo:1.0 duration:0.2];
//        SKAction *fadeSequence = [SKAction sequence:@[fadeOut,fadeIn,[SKAction waitForDuration:0.2]]];
//        SKAction *repeatFade = [SKAction repeatActionForever:fadeSequence];
//        [newHighScoreNode runAction:repeatFade];
//        //******************************************************************************************************************************************
//        [self addChild:newHighScoreNode];
//    }
//}
