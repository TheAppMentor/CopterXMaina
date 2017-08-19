//
//  settingsScene.m
//  copterGameFinal
//
//  Created by Prashanth Moorthy on 10/21/14.
//  Copyright (c) 2014 Sprite. All rights reserved.
//

#import "settingsScene.h"
#import "GameScene.h"
#import "PrashWordSmithPurchaseManager.h"

@implementation settingsScene{
    SKTexture *fullBackGround;
    NSString *mainBoardBack;
    NSString *fontToUse;
    SKSpriteNode *mainBoard;
    SKSpriteNode *soundButton;
    SKSpriteNode *showDisplayButton;
}

-(void)didMoveToView:(SKView *)view{
    
    fontToUse = @"HVDComicSerifPro";
    
    mainBoardBack = @"window_panel_store";
    fullBackGround = [[TexturePreLoader sharedTexturePreLoader] staticBackgroundTexture];
    
    SKSpriteNode *backGround = [SKSpriteNode node];
    backGround.anchorPoint = CGPointZero;
    backGround.size = CGSizeMake(self.size.width, self.size.height);
    
    SKSpriteNode *fullBgNode = [SKSpriteNode spriteNodeWithTexture:fullBackGround];

    fullBgNode.size = self.size;
    fullBgNode.anchorPoint = CGPointZero;
    
    [backGround addChild:fullBgNode];
    
    [self addChild:backGround];
    
    
    // Add store Board.
    mainBoard = [SKSpriteNode spriteNodeWithImageNamed:mainBoardBack];
    mainBoard.anchorPoint = CGPointMake(0.5, 0.5);
    mainBoard.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 25);
    
    mainBoard.size = CGSizeMake(self.size.width * 3/4, self.size.height * 3/4);
    mainBoard.zPosition = 100.0;
    
    // Add Top Name Board;
    SKSpriteNode *topNameBoard = [SKSpriteNode spriteNodeWithImageNamed:@"mainMenuButton_2208"];
    topNameBoard.anchorPoint = CGPointMake(0.5, 0.5);
    topNameBoard.size = CGSizeMake(mainBoard.size.width * (1/(2 * mainBoard.xScale) ), 50/mainBoard.yScale);
    [mainBoard addChild:topNameBoard];
    
    topNameBoard.position = CGPointZero;
    topNameBoard.position = CGPointMake(topNameBoard.position.x, topNameBoard.position.y + (mainBoard.size.height/(2 * mainBoard.yScale)));
    topNameBoard.name = @"topNameBoard";
    topNameBoard.zPosition = mainBoard.zPosition + 1;
    
    // Add topBoard Label;
    SKLabelNode *labelNode = [SKLabelNode labelNodeWithFontNamed:fontToUse];
    labelNode.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize]/mainBoard.xScale;
    labelNode.fontColor = [UIColor colorWithRed:75/255 green:54.0/255 blue:33.0/255 alpha:1.0];
//    labelNode.text = @"Settings";

    labelNode.text = NSLocalizedString(@"Settings", nil);

    labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    [topNameBoard addChild:labelNode];
    labelNode.zPosition = topNameBoard.zPosition + 1;
    
    //Close Button :
    SKSpriteNode *closeButton = [SKSpriteNode spriteNodeWithImageNamed:@"btn_big_symbol_cross_red"];
    closeButton.anchorPoint = CGPointMake(0.5, 0.5);
    closeButton.size = CGSizeMake(50/mainBoard.xScale, 50/mainBoard.yScale);
    [mainBoard addChild:closeButton];
    
    closeButton.position = CGPointZero;
    closeButton.position = CGPointMake(closeButton.position.x + mainBoard.size.width/2 - closeButton.size.width/4, mainBoard.size.height/2 - closeButton.size.height/4);
    closeButton.zPosition = mainBoard.zPosition + 1;
    closeButton.name = @"closeButton";

    //Sound Button :
    
    // Build a Container Node :
    SKSpriteNode *theContainerNode = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(mainBoard.size.width * (2.0/3.0), 100)];
    
    // Create a Sound label :
    SKLabelNode *musicLabel = [SKLabelNode labelNodeWithFontNamed:fontToUse];
    musicLabel.fontSize =[[TexturePreLoader sharedTexturePreLoader] mediumFontSize];
    musicLabel.fontColor = [UIColor whiteColor];
    musicLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
   // musicLabel.text = @"Play Game Music";
    musicLabel.text = NSLocalizedString(@"music_on", nil);
    
    musicLabel.position = CGPointMake(CGRectGetMidX(theContainerNode.frame),CGRectGetMidY(theContainerNode.frame));
    [theContainerNode addChild:musicLabel];
    
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"musicStatus"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"ON" forKey:@"musicStatus"];
    }
    NSString *musicStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"musicStatus"];
        if ([musicStatus isEqualToString:@"ON"]) {
        soundButton = [SKSpriteNode spriteNodeWithImageNamed:@"element_checkmark_checked"];

    }else{
        soundButton = [SKSpriteNode spriteNodeWithImageNamed:@"element_checkmark_unchecked"];
    }
    //soundButton.anchorPoint = CGPointMake(0.5, 0.5);
    soundButton.size = CGSizeMake(50/mainBoard.xScale, 50/mainBoard.yScale);
    soundButton.position = CGPointMake(musicLabel.frame.size.width, 0);
    soundButton.name=@"musicStatusButton";
    
    [theContainerNode addChild:soundButton];
    theContainerNode.anchorPoint = CGPointZero;
    
    [mainBoard addChild:theContainerNode];
    theContainerNode.position = CGPointMake(-theContainerNode.size.width/5, theContainerNode.position.y + mainBoard.size.height/5);
    
    // Restore Purchases Button
    SKSpriteNode *restorePurchasesButton = [SKSpriteNode spriteNodeWithImageNamed:@"boards_small_red"];
    restorePurchasesButton.name = @"restorePurchasesButton";
    restorePurchasesButton.size = CGSizeMake(mainBoard.size.width/1.5, mainBoard.size.height/4);
    restorePurchasesButton.position = CGPointZero;
    restorePurchasesButton.zPosition = mainBoard.zPosition + 1;
    
    SKLabelNode *settingsLabel = [SKLabelNode labelNodeWithFontNamed:fontToUse];
    settingsLabel.fontSize =[[TexturePreLoader sharedTexturePreLoader] smallFontSize];
    settingsLabel.fontColor = [UIColor colorWithRed:75/255 green:54.0/255 blue:33.0/255 alpha:1.0];
    settingsLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    settingsLabel.text = @"Restore Past Purchases";
    settingsLabel.position = CGPointMake(CGRectGetMidX(restorePurchasesButton.frame),CGRectGetMidY(restorePurchasesButton.frame));
    [restorePurchasesButton addChild:settingsLabel];
    
    restorePurchasesButton.anchorPoint = CGPointMake(0.5, 0.5);
    
    //restorePurchasesButton.position = CGPointMake(restorePurchasesButton.position.x, (restorePurchasesButton.position.y - restorePurchasesButton.size.height - 25));
    [mainBoard addChild:restorePurchasesButton];
    
    restorePurchasesButton.position = CGPointMake(restorePurchasesButton.position.x, restorePurchasesButton.position.y - mainBoard.size.height/4);
    
    for (SKNode *anyNode in [mainBoard children]) {
        NSLog(@" %@ %f",anyNode,anyNode.zPosition);
    }
    
    [self addChild:mainBoard];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    // Pick one of the touches.
    UITouch *theTouch = [touches anyObject];
    CGPoint location = [theTouch locationInNode:self];
    
    if ([[self nodeAtPoint:location].name isEqualToString:@"closeButton"]) [self closeStore];
    if ([[self nodeAtPoint:location].name isEqualToString:@"musicStatusButton"]) [self toogleMusicSwitch];
    if ([[self nodeAtPoint:location].name isEqualToString:@"restorePurchasesButton"]) [self restorePastPurchases];
    if ([[self nodeAtPoint:location].name isEqualToString:@"showControlsButton"]) [self toggleShowDisplayButton];

    
}

-(void)toogleMusicSwitch{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"musicStatus"] isEqualToString:@"ON"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"OFF" forKey:@"musicStatus"];
        [soundButton setTexture:[SKTexture textureWithImageNamed:@"element_checkmark_unchecked"]];

    }else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"musicStatus"] isEqualToString:@"OFF"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"ON" forKey:@"musicStatus"];
        [soundButton setTexture:[SKTexture textureWithImageNamed:@"element_checkmark_checked"]];
    }
}

-(void)restorePastPurchases{
    [[PrashWordSmithPurchaseManager sharedInstance] restore];
}

-(void)closeStore{
    SKTransition *transitionToMainScreen = [SKTransition fadeWithDuration:1.0];
//#warning Prashanth Need to find a better way tof ix this. The sizes are hard coded here... change it.
     GameScene *theGameScene = [GameScene sceneWithSize:CGSizeMake(1024, 768)];
    theGameScene.scaleMode = SKSceneScaleModeAspectFill;
    
    [self.view presentScene:theGameScene transition:transitionToMainScreen];
}



-(void)displayControls{
    //Sound Button :
    
    // Build a Container Node :
    SKSpriteNode *theContainerNode = [[SKSpriteNode alloc] initWithColor:[UIColor clearColor] size:CGSizeMake(mainBoard.size.width * (2.0/3.0), 100)];
    
    // Create a Sound label :
    SKLabelNode *musicLabel = [SKLabelNode labelNodeWithFontNamed:fontToUse];
    musicLabel.fontSize =[[TexturePreLoader sharedTexturePreLoader] mediumFontSize];
    musicLabel.fontColor = [UIColor whiteColor];
    musicLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    musicLabel.text = @"Show Game Controls";
    musicLabel.position = CGPointMake(CGRectGetMidX(theContainerNode.frame),CGRectGetMidY(theContainerNode.frame));
    [theContainerNode addChild:musicLabel];
    
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"showControls"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showControls"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showControls"]) {
        showDisplayButton = [SKSpriteNode spriteNodeWithImageNamed:@"element_checkmark_checked"];
        
    }else{
        showDisplayButton = [SKSpriteNode spriteNodeWithImageNamed:@"element_checkmark_unchecked"];
    }
    //soundButton.anchorPoint = CGPointMake(0.5, 0.5);
    showDisplayButton.size = CGSizeMake(50/mainBoard.xScale, 50/mainBoard.yScale);
    showDisplayButton.position = CGPointMake(musicLabel.frame.size.width, 0);
    showDisplayButton.name=@"showControlsButton";
    
    [theContainerNode addChild:showDisplayButton];
    theContainerNode.anchorPoint = CGPointZero;
    
    [mainBoard addChild:theContainerNode];
    theContainerNode.position = CGPointMake(-theContainerNode.size.width/5, theContainerNode.position.y);
}

-(void)toggleShowDisplayButton{
    
    NSLog(@"TOggle button Got Called");
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showControls"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"showControls"];
        [showDisplayButton setTexture:[SKTexture textureWithImageNamed:@"element_checkmark_unchecked"]];
        
    }else if (![[NSUserDefaults standardUserDefaults] boolForKey:@"showControls"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showControls"];
        [showDisplayButton setTexture:[SKTexture textureWithImageNamed:@"element_checkmark_checked"]];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dispalyControlsChanged" object:nil];
}

@end
