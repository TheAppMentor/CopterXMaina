//
//  GameScene.m
//  copterMania
//
//  Created by Prashanth Moorthy on 3/6/15.
//  Copyright (c) 2015 The App Mentor. All rights reserved.
//

#import "GameScene.h"
#import "parallaxScrollingBgNode.h"
#import "storeScene.h"
#import "settingsScene.h"
#import "GamePlayScene.h"
#import "iRate.h"
#import "GameCenterHelper.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
//#import "GameSocialShareModule.h"


//#import "gamePlayScene.h"
//#import "mainGameScene.h"

@interface GameScene ()

@property (strong,nonatomic) iRate *gameRater;

@end

@implementation GameScene{
    NSString *fontToUse;
    
    SKTexture *fullBackGround;
    SKTexture *mainBoardBack;
    SKTexture *playButtonImage;
    SKTexture *storeButtonImage;
    SKTexture *settingsRoundButtonImage;
}

-(iRate *)gameRater{
    if (!_gameRater) {
        _gameRater = [[iRate alloc] init];
    }
    return _gameRater;
}

-(void)didMoveToView:(SKView *)view {
    
    if (self.isGameRestarting) {
        [self transitionToGame];
        self.isGameRestarting = NO;
    }
    self.scaleMode = SKSceneScaleModeFill;
    
    fontToUse = @"HVDComicSerifPro";
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    NSLog(@"Screen Width = %f, Height %f",screenWidth,screenHeight);
    
    fullBackGround = [[TexturePreLoader sharedTexturePreLoader] staticBackgroundTexture];
    mainBoardBack = [[TexturePreLoader sharedTexturePreLoader] mainMenuBoardTexture];
    playButtonImage = [[TexturePreLoader sharedTexturePreLoader] mainMenuPlayButton];
    settingsRoundButtonImage = [[TexturePreLoader sharedTexturePreLoader] settingsRoundButton];
    
    // Load Background.
    SKSpriteNode *backGround = [SKSpriteNode node];
    NSLog(@"self.size is %@",NSStringFromCGRect(self.frame));
    backGround.anchorPoint = CGPointZero;
    backGround.size = CGSizeMake(self.size.width, self.size.height);
    
    SKSpriteNode *fullBgNode = [SKSpriteNode spriteNodeWithTexture:fullBackGround];
    fullBgNode.size = self.size;
    fullBgNode.anchorPoint = CGPointZero;

    [backGround addChild:fullBgNode];
    [self addChild:backGround];
    
    
    // Add Main Board.
//    SKSpriteNode *mainBoard = [SKSpriteNode spriteNodeWithImageNamed:mainBoardBack];
    SKSpriteNode *mainBoard = [SKSpriteNode spriteNodeWithTexture:mainBoardBack];
    mainBoard.anchorPoint = CGPointMake(0.5, 0.5);
    mainBoard.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    mainBoard.size = CGSizeMake(self.size.width * 3/4, self.size.height * 3/4);
    mainBoard.zPosition = 100.0;
    

    
    // Play Button
//    SKSpriteNode *playButton = [SKSpriteNode spriteNodeWithImageNamed:playButtonImage];
    SKSpriteNode *playButton = [SKSpriteNode spriteNodeWithTexture:[[TexturePreLoader sharedTexturePreLoader]  mainMenuPlayButton]];
    playButton.name = @"playButton";
    playButton.size = CGSizeMake(mainBoard.size.width/2, mainBoard.size.height/3 * mainBoard.yScale);
    playButton.zPosition = mainBoard.zPosition + 1;
    
    SKLabelNode *playLabel = [SKLabelNode labelNodeWithFontNamed:fontToUse];
    playLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] largeFontSize];
    playLabel.fontColor = [UIColor blackColor];
    playLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    playLabel.name = @"playLabel";
//    playLabel.text = @"PLAY";
    playLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Play", nil)];
    playLabel.position = CGPointMake(CGRectGetMidX(playButton.frame),CGRectGetMidY(playButton.frame));
    [playButton addChild:playLabel];
    playLabel.zPosition = playButton.zPosition + 1;

    [playLabel removeAllActions];
    SKAction* scoreAction = [SKAction scaleBy:1.25 duration:0.5];
    SKAction* revertAction = [SKAction scaleTo:1 duration:0.5];
    SKAction* completeAction = [SKAction repeatActionForever:[SKAction sequence:@[scoreAction, revertAction]]];
    [playLabel runAction:completeAction];

    playButton.anchorPoint = CGPointMake(0.5, 0.5);
    playButton.position = CGPointMake(playButton.position.x, playButton.position.y + playButton.size.height/3);
    
    
    [mainBoard addChild:playButton];
    
    
     // settings Button
     SKSpriteNode *settingsButton = [SKSpriteNode spriteNodeWithTexture:settingsRoundButtonImage];
 
     settingsButton.name = @"settingsButton";
     settingsButton.size = CGSizeMake(mainBoard.size.width/9, mainBoard.size.width/9);
    // main board is a rectangle, so circle is skewed. So taking both sizes to be width.
     settingsButton.position = CGPointZero;
     settingsButton.zPosition = mainBoard.zPosition + 1;
    
    settingsButton.anchorPoint = CGPointMake(0.5, 0.5);
    settingsButton.position = CGPointMake(mainBoard.size.width/2 - settingsButton.size.width - settingsButton.size.width/4, -mainBoard.size.height/2 + settingsButton.size.width + settingsButton.size.width/4);
    [mainBoard addChild:settingsButton];

    // FaceBook Like Button
    
    SKSpriteNode *likeButtonRound = [SKSpriteNode spriteNodeWithTexture:[[TexturePreLoader sharedTexturePreLoader] likeUsFaceBookRoundButton]];
    likeButtonRound.name = @"likeUsButton";
    likeButtonRound.size = CGSizeMake(mainBoard.size.width/9, mainBoard.size.width/9); // main board is a rectangle, so circle is skewed.
    likeButtonRound.position = CGPointZero;
    likeButtonRound.zPosition = mainBoard.zPosition + 1;
    
    likeButtonRound.anchorPoint = CGPointMake(0.5, 0.5);
    likeButtonRound.position = CGPointMake(-mainBoard.size.width/2 + likeButtonRound.size.width + likeButtonRound.size.width/4, -mainBoard.size.height/2 + likeButtonRound.size.width + likeButtonRound.size.width/4);
    [mainBoard addChild:likeButtonRound];

    
    // Rate Us Button
    SKSpriteNode *rateUsButtonRound = [SKSpriteNode spriteNodeWithTexture:[[TexturePreLoader sharedTexturePreLoader] rateUsRoundButton]];
    rateUsButtonRound.name = @"rateUsButton";
    rateUsButtonRound.size = CGSizeMake(mainBoard.size.width/9, mainBoard.size.width/9); // main board is a rectangle, so circle is skewed.
    rateUsButtonRound.position = CGPointZero;
    rateUsButtonRound.zPosition = mainBoard.zPosition + 1;
    
    rateUsButtonRound.anchorPoint = CGPointMake(0.5, 0.5);
    
    rateUsButtonRound.position = CGPointMake(-mainBoard.size.width/2 + rateUsButtonRound.size.width + 1.5 * rateUsButtonRound.size.width, -mainBoard.size.height/2 + rateUsButtonRound.size.width + rateUsButtonRound.size.width);

    [mainBoard addChild:rateUsButtonRound];

    // Store Button
    SKSpriteNode *storeButtonRound = [SKSpriteNode spriteNodeWithTexture:[[TexturePreLoader sharedTexturePreLoader] storeRoundButton]];
    storeButtonRound.name = @"storeButton";
    storeButtonRound.size = CGSizeMake(mainBoard.size.width/4, mainBoard.size.width/4); // main board is a rectangle, so circle is skewed.
    storeButtonRound.position = CGPointZero;
    storeButtonRound.zPosition = mainBoard.zPosition + 1;
    
    storeButtonRound.anchorPoint = CGPointMake(0.5, 0.5);
    
    [mainBoard addChild:storeButtonRound];
    storeButtonRound.position = CGPointMake(storeButtonRound.position.x,storeButtonRound.position.y - mainBoard.size.height/3);

    // Help Round Button
    SKSpriteNode *helpButtonRound = [SKSpriteNode spriteNodeWithTexture:[[TexturePreLoader sharedTexturePreLoader] helpRoundButton]];
    helpButtonRound.name = @"helpButton";
    helpButtonRound.size = CGSizeMake(mainBoard.size.width/(9 * self.xScale), mainBoard.size.width/(9 * self.yScale)); // main board is a rectangle, so circle is skewed.
    helpButtonRound.position = CGPointZero;
    helpButtonRound.zPosition = mainBoard.zPosition + 1;
    
    helpButtonRound.anchorPoint = CGPointMake(0.5, 0.5);
    
    [mainBoard addChild:helpButtonRound];
    
    helpButtonRound.position = CGPointMake(mainBoard.size.width/2 - rateUsButtonRound.size.width - 1.5 * rateUsButtonRound.size.width, -mainBoard.size.height/2 + rateUsButtonRound.size.width + rateUsButtonRound.size.width);
    
    
    [backGround addChild:mainBoard];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKNode *touchedNode = [self nodeAtPoint:location];
        if ([touchedNode.name isEqualToString:@"playButton"]) {
            NSLog(@"Playbutton was Pressed");
            [self transitionToGame];
        }else if([touchedNode.name isEqualToString:@"playLabel"]){
            NSLog(@"Playbutton was Pressed");
            [self transitionToGame];
        }else if([touchedNode.name isEqualToString:@"storeButton"]){
            NSLog(@"storeButton was Pressed");
            [self transitionToStore];
        }else if([touchedNode.name isEqualToString:@"settingsButton"]){
            NSLog(@"settingsButton was Pressed");
            [self transitionToSettings];
        }else if([touchedNode.name isEqualToString:@"helpButton"]){
            NSLog(@"Help Button was Pressed");
            [self transitionToGamecenter];
        }else if([touchedNode.name isEqualToString:@"rateUsButton"]){
            NSLog(@"Rate us button was Pressed");
            [self askForRating];
        }else if([touchedNode.name isEqualToString:@"likeUsButton"]){
            NSLog(@"Like US button was Pressed");
            
            
//            FBSDKLikeControl *button = [[FBSDKLikeControl alloc] init];
//            button.objectID = @"https://www.facebook.com/pages/Copter-Mania-Game/721930537919164";
//            [self.view addSubview:button];
//            
            
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            content.contentURL = [NSURL URLWithString:@"https://itunes.apple.com/us/app/copter-mania-free-fun-classic/id979059687?mt=8"];
//            content.contentTitle = @"Copter Mania";
//            content.contentDescription = @"Try out Copter Mania. Its a fun new iOS Game.";
            [FBSDKShareDialog showFromViewController:self.view.window.rootViewController
                                         withContent:content
                                            delegate:nil];
        }
    }
}



-(void)update:(CFTimeInterval)currentTime {
    /* Called before 
     each frame is rendered */
}

-(void)transitionToStore{
    SKTransition *transitionToStore = [SKTransition fadeWithDuration:1.0];
    storeScene *theStore = [storeScene sceneWithSize:self.view.bounds.size];
    theStore.scaleMode = SKSceneScaleModeAspectFill;
    
    [self.view presentScene:theStore transition:transitionToStore];
}

-(void)transitionToSettings{
    SKTransition *transitionToStore = [SKTransition fadeWithDuration:1.0];
    settingsScene *theSettings = [settingsScene sceneWithSize:self.view.bounds.size];
    theSettings.scaleMode = SKSceneScaleModeAspectFill;
    
    [self.view presentScene:theSettings transition:transitionToStore];
}

-(void)transitionToGame{
    SKTransition *transitionToGame = [SKTransition fadeWithDuration:0.2];
    GamePlayScene *theGameScreen = [GamePlayScene sceneWithSize:self.view.bounds.size];
    theGameScreen.scaleMode = SKSceneScaleModeAspectFill;
    
    [self.view presentScene:theGameScreen transition:transitionToGame];
}

-(void)transitionToHelpScreen{
    SKTransition *transitionToGame = [SKTransition fadeWithDuration:0.2];
    GamePlayScene *theGameScreen = [GamePlayScene sceneWithSize:self.view.bounds.size];
    theGameScreen.scaleMode = SKSceneScaleModeAspectFit;
    
    [self.view presentScene:theGameScreen transition:transitionToGame];
}

-(void)transitionToFaceBookScreen{
    
//    GameSocialShareModule *socialShareModule = [[GameSocialShareModule alloc] init];
//    [socialShareModule presentShareOnFBDialog];
    
    NSLog(@"Now I will Transition to Facebook Screen");
//    GamePlayScene *theGameScreen = [GamePlayScene sceneWithSize:self.view.bounds.size];
//    theGameScreen.scaleMode = SKSceneScaleModeAspectFit;
//    
//    [self.view presentScene:theGameScreen transition:transitionToGame];
}

-(void)askForRating{
    [self.gameRater promptForRating];
}

-(void)transitionToGamecenter{
    [[GameCenterHelper sharedGameKitHelper] showGKGameCenterViewController:self.view.window.rootViewController];
}

@end
