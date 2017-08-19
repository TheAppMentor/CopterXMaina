//
//  storeScene.m
//  copterGameFinal
//
//  Created by Prashanth Moorthy on 10/21/14.
//  Copyright (c) 2014 Sprite. All rights reserved.
//

#import "storeScene.h"
#import "GameScene.h"
#import "GameViewController.h"

@interface storeScene (){
    NSArray *_products;
    SKLabelNode *loadingLabel;
    SKLabelNode *contactingAppStore;
    NSTimeInterval timeWhenWeContactedAppstore;
    BOOL haveConcatedAppStore;
    BOOL purchaseInProgress;
}

@property (strong,nonatomic) UISlider *sledSlider;

@end

@implementation storeScene{
    SKTexture *fullBackGround;
    NSString *bgSky;
    NSString *bgGround;
    NSString *bgClouds;
    NSString *mainBoardBack;
    NSString *fontToUse;
    SKSpriteNode *storeItemHolderNode;
    SKSpriteNode *moveableNode;
    SKSpriteNode *leftArrow;
    SKSpriteNode *rightArrow;
    
    SKLabelNode *buylabelNode;
    
    SKSpriteNode *mainBoard;
    SKSpriteNode *centerMarkerNode;
    SKSpriteNode *allStoreItemsNode;
    
    NSMutableArray *storeItems;
     int currentlyShowingItem;
}

-(void)requestForProductList{
    
    [[PrashWordSmithPurchaseManager sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            NSLog(@"Product List is %@",_products);
            for (SKProduct *theProduct in _products) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [numberFormatter setLocale:theProduct.priceLocale];
                NSString *formattedPriceString = [numberFormatter stringFromNumber:theProduct.price];
                
                NSDictionary *tempDictionary = @{@"product":theProduct,@"itemDescription":theProduct.localizedDescription,@"itemPrice":formattedPriceString};
                [storeItems addObject:tempDictionary];
            }
            NSLog(@"OK we now have the complete list of prodcuts. Lets load the UI");
                            //[self populateUIWithProductList];


            if (storeItems.count > 0) {
                NSLog(@"The Store Items are : %@",storeItems);
                purchaseInProgress = NO;
                [self populateUIWithProductList];}
        }
        else if (!success){
            purchaseInProgress = NO;
            
            NSLog(@"Ok We failed to get alist of products");
//            [self displayMessage:@"Oops! Please try again"];
            [self displayMessage:NSLocalizedString(@"Oops_Try_Again", nil)];
          
            
            [self closeStoreAfterWatingFor:3.0];
        }
    }];
}


-(void)didMoveToView:(SKView *)view{
    // Show the "Contacting Appstore Message"
    [self showBlankScreen];
//    [self displayMessage:@"Loading..."];
    [self displayMessage:NSLocalizedString(@"Loading", nil)];
    haveConcatedAppStore = YES;
    
    storeItems = [[NSMutableArray alloc] init];
    [self requestForProductList];
}

-(void)populateUIWithProductList{
    
    [loadingLabel removeFromParent];
    [contactingAppStore removeFromParent];

    fontToUse = @"HVDComicSerifPro";
    
    mainBoardBack = @"window_panel_store";
    fullBackGround = [[TexturePreLoader sharedTexturePreLoader] staticBackgroundTexture];

    
    SKSpriteNode *backGround = [SKSpriteNode node];
    NSLog(@"self.size is %@",NSStringFromCGRect(self.frame));
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
//    labelNode.text = @"Store";
    labelNode.text = NSLocalizedString(@"Store", nil);

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
    
    //Add Left Arrow :
    leftArrow = [SKSpriteNode spriteNodeWithImageNamed:@"btn_big_arrow_left_green"];
    leftArrow.anchorPoint = CGPointMake(0.5, 0.5);
    leftArrow.size = CGSizeMake(50/mainBoard.xScale, 50/mainBoard.yScale);
    [mainBoard addChild:leftArrow];
    
    leftArrow.position = CGPointZero;
    leftArrow.position = CGPointMake(leftArrow.position.x - (mainBoard.size.width/(2 * mainBoard.xScale)), leftArrow.position.y);
    leftArrow.zPosition = 200;
    leftArrow.name = @"leftArrow";
    
    //Add Right Arrow :
    rightArrow = [SKSpriteNode spriteNodeWithImageNamed:@"btn_big_arrow_right_green"];
    rightArrow.anchorPoint = CGPointMake(0.5, 0.5);
    rightArrow.size = CGSizeMake(50/mainBoard.xScale, 50/mainBoard.yScale);
    [mainBoard addChild:rightArrow];
    
    rightArrow.position = CGPointZero;
    rightArrow.position = CGPointMake(rightArrow.position.x + (mainBoard.size.width/(2 * mainBoard.xScale)), rightArrow.position.y);
    rightArrow.zPosition = 200;
    rightArrow.name = @"rightArrow";
    
    // Call method to make individual store items.
    [self addChild:[self makeStoreItemAtIndex:0]];
    
    currentlyShowingItem = 0;
    
    //Hide the Left Arrow;
    [leftArrow setHidden:YES];
    
    //NSLog(@"mainBoards Children are %@",[mainBoard children]);
    
    for (SKNode *anyNode in [mainBoard children]) {
        NSLog(@" %@ %f",anyNode,anyNode.zPosition);
    }
}

-(SKSpriteNode *)makeStoreItemAtIndex:(int)index{
    
    SKSpriteNode *theMask = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(mainBoard.size.width * 3/4,mainBoard.size.height * 3/4)];
    SKCropNode *cropNode = [SKCropNode node];
    cropNode.name = @"cropNode";
    
    allStoreItemsNode = [self makeStoreItemBoard];
    
    float position_First_Buy_Item = [(SKSpriteNode *)[[allStoreItemsNode children] firstObject] position].x;
    
    allStoreItemsNode.position = CGPointMake(allStoreItemsNode.position.x - position_First_Buy_Item, allStoreItemsNode.position.y);
//    NSLog(@"The all store Item node Position is %@",NSStringFromCGPoint(allStoreItemsNode.position));
//    NSLog(@"The all store Item node Position is %@",allStoreItemsNode.children);
    
    [cropNode addChild:allStoreItemsNode];
    [cropNode setMaskNode:theMask];
    
    [mainBoard addChild:cropNode];
    cropNode.zPosition = mainBoard.zPosition + 1;
  
    return mainBoard;
}


-(SKSpriteNode *)makeStoreItemBoard{
    allStoreItemsNode = [SKSpriteNode node];
    
    for (int i=0; i<storeItems.count; i++) {

        storeItemHolderNode = [SKSpriteNode node];
        
        // Add Name Board:
        SKSpriteNode *itemsNode = [SKSpriteNode spriteNodeWithImageNamed:@"boards_large_brown"];
        itemsNode.anchorPoint = CGPointMake(0.5, 0.5);
        itemsNode.size = CGSizeMake(mainBoard.size.width * (2/(3 * mainBoard.xScale) ), 100/mainBoard.yScale);
        [storeItemHolderNode addChild:itemsNode];
        
        itemsNode.position = CGPointZero;
        itemsNode.position = CGPointMake(itemsNode.position.x, itemsNode.position.y + itemsNode.size.height/(3 * mainBoard.yScale));
        itemsNode.name = @"itemsNode";
        
        // Add Item Label
        SKLabelNode *itemDescLabel = [SKLabelNode labelNodeWithFontNamed:fontToUse];
        itemDescLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize];
        itemDescLabel.fontColor = [UIColor colorWithRed:75/255 green:54.0/255 blue:33.0/255 alpha:1.0];
        itemDescLabel.text = [[storeItems objectAtIndex:i] valueForKey:@"itemDescription"];
     //   NSLog(@"........... %@",[[storeItems objectAtIndex:i] valueForKey:@"itemDescription"]);
        itemDescLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        itemDescLabel.zPosition = itemsNode.zPosition + 1;
        [itemsNode addChild:itemDescLabel];
        itemDescLabel.position = CGPointMake(itemDescLabel.position.x, itemDescLabel.position.y + itemsNode.size.height/6);

        
        // Add Item Label
        SKLabelNode *itemPriceLabel = [SKLabelNode labelNodeWithFontNamed:fontToUse];
        itemPriceLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] smallFontSize];
        itemPriceLabel.fontColor = [UIColor colorWithRed:75/255 green:54.0/255 blue:33.0/255 alpha:1.0];
        itemPriceLabel.text = [[storeItems objectAtIndex:i] valueForKey:@"itemPrice"];
        itemPriceLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        itemPriceLabel.zPosition = itemsNode.zPosition + 1;
        [itemsNode addChild:itemPriceLabel];
        itemPriceLabel.position = CGPointMake(itemPriceLabel.position.x, itemPriceLabel.position.y - itemsNode.size.height/8);


        // Add Buy Board;
        SKSpriteNode *buyBoard = [SKSpriteNode spriteNodeWithImageNamed:@"boards_small_green"];
        buyBoard.anchorPoint = CGPointMake(0.5, 0.5);
        buyBoard.size = CGSizeMake(mainBoard.size.width * (1/(2 * mainBoard.xScale) ), 50/mainBoard.yScale);
        [storeItemHolderNode addChild:buyBoard];
        
        buyBoard.position = CGPointZero;
        buyBoard.position = CGPointMake(buyBoard.position.x, buyBoard.position.y - (1.25 *buyBoard.size.height));
        buyBoard.name = @"buyBoard";
        
        // Add buyBoard Label;
        buylabelNode = [SKLabelNode labelNodeWithFontNamed:fontToUse];
        buylabelNode.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize]/mainBoard.xScale;
        buylabelNode.fontColor = [UIColor colorWithRed:75/255 green:54.0/255 blue:33.0/255 alpha:1.0];
//        buylabelNode.text = @"BUY";
        buylabelNode.text = NSLocalizedString(@"Buy", nil);
        
        
        buylabelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        buylabelNode.zPosition = buyBoard.zPosition + 1;
        [buyBoard addChild:buylabelNode];
        
        //Add left Rope
        SKSpriteNode *leftRope = [SKSpriteNode spriteNodeWithImageNamed:@"element_rope_left"];
        leftRope.anchorPoint = CGPointMake(0.5, 0.5);
        leftRope.size = CGSizeMake(10, 60);
        [itemsNode addChild:leftRope];
        leftRope.zPosition = 300;
        
        leftRope.position = CGPointZero;
        leftRope.position = CGPointMake(-itemsNode.size.width/4, -(itemsNode.size.height/4 + leftRope.size.height/2));
        leftRope.name = @"leftRope";
        
        //Add right Rope
        SKSpriteNode *rightRope = [SKSpriteNode spriteNodeWithImageNamed:@"element_rope_right"];
        rightRope.anchorPoint = CGPointMake(0.5, 0.5);
        rightRope.size = CGSizeMake(10, 60);
        [itemsNode addChild:rightRope];
        rightRope.zPosition = 300;
        
        rightRope.position = CGPointZero;
        rightRope.position = CGPointMake(itemsNode.size.width/4, -(itemsNode.size.height/4 + rightRope.size.height/2));
        rightRope.name = @"rightRope";

        storeItemHolderNode.position = CGPointMake((mainBoard.size.width/2 + i * mainBoard.size.width),0);
        [allStoreItemsNode addChild:storeItemHolderNode];
    }
   // allStoreItemsNode.zPosition = mainBoard.zPosition + 1;
    NSLog(@"Store Item Holder Node Children %@",allStoreItemsNode.children);
    return allStoreItemsNode;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    // Pick one of the touches.
        UITouch *theTouch = [touches anyObject];
        CGPoint location = [theTouch locationInNode:self];
    
    if ([[self nodeAtPoint:location].name isEqualToString:@"closeButton"]) [self closeStoreAfterWatingFor:0.0];
    if ([[self nodeAtPoint:location].name isEqualToString:@"leftArrow"] && currentlyShowingItem > 0) [self goLeft];
    if ([[self nodeAtPoint:location].name isEqualToString:@"rightArrow"] && currentlyShowingItem < [storeItems count] - 1)[self goRight];
    if ([[self nodeAtPoint:location].name isEqualToString:@"buyBoard"]) [self buySomething];
}

-(void)closeStoreAfterWatingFor:(float)seconds{
    
    SKAction *waitForDuration = [SKAction waitForDuration:seconds];
    SKAction *goBackToMainScreen = [SKAction performSelector:@selector(goBackToMainScreen) onTarget:self];
    
    [self runAction:[SKAction sequence:@[waitForDuration,goBackToMainScreen]]];
    
    
}

-(void)goBackToMainScreen{
    SKTransition *transitionToMainScreen = [SKTransition fadeWithDuration:1.0];
//#warning Prashanth Need to find a better way tof ix this. The sizes are hard coded here... change it.
    GameScene *theGameScene = [GameScene sceneWithSize:CGSizeMake(1024, 768)];
    theGameScene.scaleMode = SKSceneScaleModeAspectFill;

    [self.view presentScene:theGameScene transition:transitionToMainScreen];

}



-(void)goLeft{
    
    currentlyShowingItem--;
    CGFloat position_of_item_in_MainBoard = [(SKSpriteNode *)[[allStoreItemsNode children] objectAtIndex:currentlyShowingItem] position].x;

    SKAction *moveNodeLeft = [SKAction moveToX:-position_of_item_in_MainBoard duration:1.0];
    [allStoreItemsNode runAction:moveNodeLeft];
    
    [leftArrow setHidden:NO];
    if (currentlyShowingItem == 0) {
        // Hide the scroll left Arrow.
        [leftArrow setHidden:YES];

        [rightArrow setHidden:NO];
    }
}

-(void)goRight{
    NSLog(@"Now I will go Right");
    currentlyShowingItem++;

    CGFloat position_of_item_in_MainBoard = [(SKSpriteNode *)[[allStoreItemsNode children] objectAtIndex:currentlyShowingItem] position].x;
    
    SKAction *moveNodeRight = [SKAction moveToX:-position_of_item_in_MainBoard duration:1.0];
    [allStoreItemsNode runAction:moveNodeRight];

    if (currentlyShowingItem > 0) {
        // Show the scroll left Arrow.
        [leftArrow setHidden:NO];
    }

    [rightArrow setHidden:NO];
    if (currentlyShowingItem == (storeItems.count - 1)) {
        [rightArrow setHidden:YES];

    }
}

-(void)buySomething{
    NSLog(@"Now I will buySomething");
    
    SKProduct *theProduct = [[storeItems objectAtIndex:currentlyShowingItem] objectForKey:@"product"];
    [[PrashWordSmithPurchaseManager sharedInstance] buyProduct:theProduct];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(purchaseProcessCompleted:)
                                                 name:IAPHelperProductPurchasedNotification
                                               object:nil];
    
}

-(void)purchaseProcessCompleted:(NSNotification *)notification{

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([[notification.userInfo objectForKey:@"productName"] isEqualToString:@"copter_buy_500_coins"]) {

    // Purchase was successful. Update the Gold Coin Count
    NSInteger goldCoinCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"coinCount"];
    goldCoinCount += 500;
    [[NSUserDefaults standardUserDefaults] setInteger:goldCoinCount forKey:@"coinCount"];
    //[self continueGame];

    }
        if ([[notification.userInfo objectForKey:@"productName"] isEqualToString:@"copter_buy_2000_coins"]) {
            // Purchase was successful. Update the Gold Coin Count
            NSInteger goldCoinCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"coinCount"];
            goldCoinCount += 2000;
            [[NSUserDefaults standardUserDefaults] setInteger:goldCoinCount forKey:@"coinCount"];

        }
    if ([[notification.userInfo objectForKey:@"productName"] isEqualToString:@"Copter_Maina_Remove_Ads"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CopterRemoveAllAds"];
    }
}


-(void)showBlankScreen{
    fontToUse = @"HVDComicSerifPro";
    
    mainBoardBack = @"window_panel_store";
    fullBackGround = [[TexturePreLoader sharedTexturePreLoader] staticBackgroundTexture];
    
    SKSpriteNode *backGround = [SKSpriteNode node];
    NSLog(@"self.size is %@",NSStringFromCGRect(self.frame));
    backGround.anchorPoint = CGPointZero;
    backGround.size = CGSizeMake(self.size.width, self.size.height);
    //
    SKSpriteNode *fullBgNode = [SKSpriteNode spriteNodeWithTexture:fullBackGround];
    fullBgNode.size = self.size;
    fullBgNode.anchorPoint = CGPointZero;
    
    [backGround addChild:fullBgNode];
    
    [self addChild:backGround];
}

-(void)displayMessage:(NSString *)theMessage{
    // Remove any old loading Labels
    [loadingLabel removeFromParent];

    contactingAppStore = [SKLabelNode labelNodeWithFontNamed:fontToUse];
//    contactingAppStore.text = @"Contacting App Store";
    contactingAppStore.text = NSLocalizedString(@"contacting_AppStore", nil);
    
    contactingAppStore.fontSize = [[TexturePreLoader sharedTexturePreLoader] mediumFontSize];
    [self addChild:contactingAppStore];
    contactingAppStore.zPosition = 100;
    contactingAppStore.fontColor = [UIColor colorWithRed:75/255 green:54.0/255 blue:33.0/255 alpha:1.0];
    contactingAppStore.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.view.frame));
    
    
    loadingLabel = [SKLabelNode labelNodeWithFontNamed:fontToUse];
    loadingLabel.text = theMessage;
    [loadingLabel removeAllActions];
    SKAction* scoreAction = [SKAction scaleBy:1.25 duration:0.5];
    SKAction* revertAction = [SKAction scaleTo:1 duration:0.5];
    SKAction* completeAction = [SKAction repeatActionForever:[SKAction sequence:@[scoreAction, revertAction]]];
    [loadingLabel runAction:completeAction];
    loadingLabel.fontSize = [[TexturePreLoader sharedTexturePreLoader] smallFontSize];
    
    [self addChild:loadingLabel];
    loadingLabel.zPosition = 100;
    loadingLabel.fontColor = [UIColor colorWithRed:(191.0/255.0) green:(23.0/255.0) blue:(68.0/255.0) alpha:1.0];
    loadingLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.view.frame) - (2 * loadingLabel.frame.size.height));
}


-(void)update:(NSTimeInterval)currentTime{
    

    
    if (haveConcatedAppStore) {
        haveConcatedAppStore = NO;
        purchaseInProgress = YES;
        timeWhenWeContactedAppstore = currentTime;
    }
    
    if (purchaseInProgress) {
        if (currentTime - timeWhenWeContactedAppstore > 10.0) {
            NSLog(@"We have Waited fomre than 10 Seconds, lets ditch.");
            purchaseInProgress = NO;
            
            NSLog(@"Ok We failed to get alist of products");
//            [self displayMessage:@"Oops! Please try again"];
            [self displayMessage:NSLocalizedString(@"Oops_Try_Again", nil)];

            [self closeStoreAfterWatingFor:3.0];
        }
    }
    
}

@end
