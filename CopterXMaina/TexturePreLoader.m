//
//  TexturePreLoader.m
//  CopterXMaina
//
//  Created by Prashanth Moorthy on 3/21/15.
//  Copyright (c) 2015 The App Mentor. All rights reserved.
//


#define SHOW_DEBUG_MESSAGES 1

#define NUMBER_OF_COPTER_IDLE_FRAMES 10
#define NUMBER_OF_COPTER_ATTACK_FRAMES 3
#define NUMBER_OF_COPTER_BLAST_FRAMES 6
#define NUMBER_OF_COPTER_COLLISSION_FRAMES 2
#define NUMBER_OF_COPTER_FAINT_FRAMES 1
#define NUMBER_OF_COPTER_GAMEOVER_FRAMES 8
#define NUMBER_OF_ENVIROMENT_BOMB_FRAMES 3
#define NUMBER_OF_ENVIROMENT_COIN_FRAMES 8

#define NUMBER_OF_SMOKE_FRAMES 6


#import "TexturePreLoader.h"

static TexturePreLoader* _texturePreLoader = nil;

@interface TexturePreLoader (){
    NSString *textureDimension;
    CGRect screenDimension;
    NSString* loadCharactersWithResolution;
    CGFloat screenHeight;
    CGFloat screenWidth;
    
    CGFloat currnetTime;
}

@property (strong,nonatomic) SKTextureAtlas *characterAtlas;
@property (strong,nonatomic) SKTextureAtlas *environmentAtlas;
@property (strong,nonatomic) SKTextureAtlas *obstaclesAtlas;

@property BOOL isAllCopterTexturesLoaded;
@property BOOL isAllEnvironmentTexturesLoaded;

@property BOOL isCopterIdleTexturesLoaded;
@property BOOL isCopterGameOverTexturesLoaded;
@property BOOL isCopterCollissionTexturesLoaded;

@property BOOL isEnvironmentCoinsLoaded;
@property BOOL isEnvironmentBombsLoaded;
@property BOOL isEnvironmentSmokeLoaded;

@property BOOL isObstaclesLoaded;
@property BOOL isScrollingBackgroundLoaded;

@property (strong,nonatomic) NSArray *scrollingBackGroundTexture;

@end

@implementation TexturePreLoader

+(TexturePreLoader *)sharedTexturePreLoader{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _texturePreLoader = [[TexturePreLoader alloc] init];
    });
    return _texturePreLoader;
}

-(SKAction *)playCoinCollectedSoundAction{
    if (!_playCoinCollectedSoundAction) {
        _playCoinCollectedSoundAction = [SKAction playSoundFileNamed:@"coin3.wav" waitForCompletion:NO];
    }
    return _playCoinCollectedSoundAction;
}

-(SKAction *)playNewHighScoreSoundAction{
    if (!_playNewHighScoreSoundAction) {
        _playNewHighScoreSoundAction = [SKAction playSoundFileNamed:@"NewHighScore.wav" waitForCompletion:YES];        
    }
    return _playNewHighScoreSoundAction;
}


-(AVAudioPlayer *)backgroundMusicPlayer{
    if (!_backgroundMusicPlayer) {
        NSError *error;
        NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"milehighclubloop80k" withExtension:@"mp3"];
        _backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
        _backgroundMusicPlayer.numberOfLoops = -1;
        _backgroundMusicPlayer.volume = 1.0;
        [_backgroundMusicPlayer prepareToPlay];
    }
    return _backgroundMusicPlayer;
}


-(AVAudioPlayer *)coinCollectedSoundPlayer{
// Prashanth I am deliberately removed the !_ condition to make a new sound player for each sound...
        NSError *error;
        NSURL * coinCollectedSoundURL = [[NSBundle mainBundle] URLForResource:@"coin3" withExtension:@"wav"];
        _coinCollectedSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:coinCollectedSoundURL error:&error];
       // _coinCollectedSoundPlayer.numberOfLoops = -1;
        _coinCollectedSoundPlayer.volume = 1.0;
    [_coinCollectedSoundPlayer prepareToPlay];
    return _coinCollectedSoundPlayer;
}

-(AVAudioPlayer *)copterCrashSoundPlayer{
    if (!_copterCrashSoundPlayer) {
        NSError *error;
        NSURL * copterCrashSoundURL = [[NSBundle mainBundle] URLForResource:@"crash" withExtension:@"mp3"];
        _copterCrashSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:copterCrashSoundURL error:&error];
       // _copterCrashSoundPlayer.numberOfLoops = -1;
        _copterCrashSoundPlayer.volume = 1.0;
        [_copterCrashSoundPlayer prepareToPlay];
    }
    return _copterCrashSoundPlayer;
}


-(SKTextureAtlas *)characterAtlas{
    // Setup Texture for the Images @ LOAD_CHARACTER_RESOLUTION (This can be 1X or 2X or 4X) :
    if (!_characterAtlas) {
        NSLog(@"Now I will load Copter textures with resolution %@",[NSString stringWithFormat:@"Copter_Images_%@",loadCharactersWithResolution]);
        _characterAtlas = [SKTextureAtlas atlasNamed:[NSString stringWithFormat:@"Copter_Images_%@",loadCharactersWithResolution]];
    }
    return _characterAtlas;
}


-(SKTextureAtlas *)environmentAtlas{
    // Setup Texture for the Images @ LOAD_CHARACTER_RESOLUTION (This can be 1X or 2X or 4X) :
    if (!_environmentAtlas) {
        _environmentAtlas = [SKTextureAtlas atlasNamed:[NSString stringWithFormat:@"Environment_%@",loadCharactersWithResolution]];
    }
    return _environmentAtlas;
}


-(NSMutableArray *)arrayOfEnvironmentSomkeTextures{
    if (!_arrayOfEnvironmentSomkeTextures) {
        _arrayOfEnvironmentSomkeTextures = [[NSMutableArray alloc] initWithCapacity:NUMBER_OF_SMOKE_FRAMES];
        for (int i=1; i<=NUMBER_OF_SMOKE_FRAMES; i++) {
            [_arrayOfEnvironmentSomkeTextures addObject:[self.environmentAtlas textureNamed:[NSString stringWithFormat:@"Blast-frame-%d.png",i]]];
        }
    }
    return _arrayOfEnvironmentSomkeTextures;
}


-(NSMutableArray *)arrayOfCopterIdleTextures{
    if (!_arrayOfCopterIdleTextures) {
        
        _arrayOfCopterIdleTextures = [[NSMutableArray alloc] init];
        
        for (int i=1; i<=NUMBER_OF_COPTER_IDLE_FRAMES; i++) {
            [_arrayOfCopterIdleTextures addObject:[self.characterAtlas textureNamed:[NSString stringWithFormat:@"Idle-frame-%d.png",i]]];
        }
    }
    return _arrayOfCopterIdleTextures;
}

-(SKTextureAtlas *)obstaclesAtlas{
    if (!_obstaclesAtlas) {
        _obstaclesAtlas = [SKTextureAtlas atlasNamed:@"obstacles"];
    }
    return _obstaclesAtlas;
}

-(NSMutableArray *)arrayOfObstaclesTextures{
    
    if (!_arrayOfObstaclesTextures) {
        _arrayOfObstaclesTextures = [[NSMutableArray alloc] init];
        
        for (NSString *aTextureName in [self.obstaclesAtlas textureNames]) {
            [_arrayOfObstaclesTextures addObject:[self.obstaclesAtlas textureNamed:aTextureName]];
        }
    }
    
    NSLog(@"The Array of Obstacle Textures is %@",_arrayOfObstaclesTextures);
    
    return _arrayOfObstaclesTextures;
}


-(NSMutableArray *)arrayOfCopterCollisionTextures{
    if (!_arrayOfCopterCollisionTextures) {
        
        _arrayOfCopterCollisionTextures = [[NSMutableArray alloc] init];
        
        // Add all Copter Collision textures
        for (int i=1; i<=NUMBER_OF_COPTER_COLLISSION_FRAMES; i++) {
            [_arrayOfCopterCollisionTextures addObject:[self.characterAtlas textureNamed:[NSString stringWithFormat:@"Collission-frame-%d.png",i]]];
        }
    }
    return _arrayOfCopterCollisionTextures;
}

-(NSMutableArray *)arrayOfCopterGameOverTextures{
    if (!_arrayOfCopterGameOverTextures) {
        
        _arrayOfCopterGameOverTextures = [[NSMutableArray alloc] init];
        
        // Add all Copter Game Over textures
        for (int i=1; i<=NUMBER_OF_COPTER_GAMEOVER_FRAMES; i++) {
            [_arrayOfCopterGameOverTextures addObject:[self.characterAtlas textureNamed:[NSString stringWithFormat:@"GameOver-frame-%d.png",i]]];
        }
    }
    return _arrayOfCopterGameOverTextures;
}


-(NSMutableArray *)arrayOfEnvironmentCoinTextures{
    if (!_arrayOfEnvironmentCoinTextures) {
        _arrayOfEnvironmentCoinTextures = [[NSMutableArray alloc] init];
        for (int i=1; i<=NUMBER_OF_ENVIROMENT_COIN_FRAMES; i++) {
            [_arrayOfEnvironmentCoinTextures addObject:[self.environmentAtlas textureNamed:[NSString stringWithFormat:@"c%d.png",i]]];
        }
        
    }
    return _arrayOfEnvironmentCoinTextures;
}

-(NSMutableArray *)arrayOfEnvironmentBombTextures{
    if (!_arrayOfEnvironmentBombTextures) {
        _arrayOfEnvironmentBombTextures = [[NSMutableArray alloc] init];
        for (int i=1; i<=NUMBER_OF_ENVIROMENT_BOMB_FRAMES; i++) {
            [_arrayOfEnvironmentBombTextures addObject:[self.environmentAtlas textureNamed:[NSString stringWithFormat:@"a%d.png",i]]];
        }
    }
    return _arrayOfEnvironmentBombTextures;
}


-(void)preLoadAllTextures:(GameViewController *)sender{
    
/*
    List of Images to Load
 
    // Main Menu Screen : Game BackGround Layers
 
    // Main Menu Screen : Buttons.
 
    // For Store and Settings. Lets not preload. We will fetch based on user need.
 
    // Game Play Scene : Game Backgrounds(Watch out this could be the same as the one's used in Main Menu)
 
    // Game Play Scene : Copter
    
    // Game Play Scene : Obstacles
 
    // Game Play Scene : Bombs
 
    // Game Play Scene : Coins
 
    // Game Play Scene : Score Nodes
 
    // Game Play Scene : Sound Files
    
    // Figure Out What type of Device we are running on.
    
        // Based on Device setup 1X 2X or 3X images.
                         Device                  Res     Dimensions(Portrait)
                 -------------------------      -----    --------------------
                // iPhone 6 Plus                : @3X      1080 x 1920 px
                // iPhone 6                     : @2X       750 x 1334 px
                // iPhone 5/5S/5C               : @2X       640 x 1136 px
                // iPhone 4/4S                  : @2X       640 x 960 px
                // Before iPhone 4S             : @1X       320 x 480 px
                // iPhone & iPod Touch          : @1X
 
                // iPad Retina                  : @2x       1536 x 2048 px
                // iPad Mini                    : @1X        768 x 1024 px
                // iPad Mini Retina             : @2X       1536 x 2048 px
                // iPad 1st and 2nd Generation  : @1X        768 x 1024 px
 
        // Determine the Screen Size and Pick Appropriate Images.
        // PreLoad all the Images.
        // PreLoad all the Sounds.
*/
    
    [self addObserver:sender
           forKeyPath:@"isAllCopterTexturesLoaded"
              options:NSKeyValueObservingOptionNew
              context:NULL];

    [self addObserver:sender
           forKeyPath:@"isAllEnvironmentTexturesLoaded"
              options:NSKeyValueObservingOptionNew
              context:NULL];
    
     screenDimension = [[UIScreen mainScreen] bounds];
     screenHeight = screenDimension.size.height;
     screenWidth  = screenDimension.size.width;
    
    [self findDeviceType];
    self.textureDimensionLoaded = textureDimension;
    
    NSLog(@"Self.textureDImension is %@",self.textureDimensionLoaded);
    NSLog(@"load Resolution %@",loadCharactersWithResolution);
    
#warning Prashanth Need to preload this too. Trying this other technieque.. where I am just putting all these textures in an array and then asking the array to preload.
    // Load Static Background Image/Textures
    self.staticBackgroundTexture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"static_Background_%@",self.textureDimensionLoaded]];
    
    self.backgroundLayerTexture1 = [SKTexture textureWithImageNamed:[@"scrolling_Background_1_" stringByAppendingString:self.textureDimensionLoaded]];
    self.backgroundLayerTexture2 = [SKTexture textureWithImageNamed:[@"scrolling_Background_2_" stringByAppendingString:self.textureDimensionLoaded]];
    self.backgroundLayerTexture3 = [SKTexture textureWithImageNamed:[@"scrolling_Background_3_" stringByAppendingString:self.textureDimensionLoaded]];
    self.backgroundLayerTexture4 = [SKTexture textureWithImageNamed:[@"scrolling_Background_4_" stringByAppendingString:self.textureDimensionLoaded]];
    self.backgroundLayerTexture5 = [SKTexture textureWithImageNamed:[@"scrolling_Background_5_" stringByAppendingString:self.textureDimensionLoaded]];
    self.backgroundLayerTexture6 = [SKTexture textureWithImageNamed:[@"scrolling_Background_6_" stringByAppendingString:self.textureDimensionLoaded]];

    // For the Ground Node, since its currently stationary, I am setting the ground node to be same size for all screens.
    //    self.backgroundLayerTexture7 = [SKTexture textureWithImageNamed:[@"obstacles_Background1_" stringByAppendingString:self.textureDimensionLoaded]];
    
    self.backgroundLayerTexture7 = [SKTexture textureWithImageNamed:@"Static_Ground_Node"];

    self.backgroundLayerObstaclesTexture = [SKTexture textureWithImageNamed:[@"obstacles_Background_" stringByAppendingString:self.textureDimensionLoaded]];

    
    self.mainMenuBoardTexture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"mainMenu_Board_%@",self.textureDimensionLoaded]];
    self.mainMenuPlayButton = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"mainMenu_Play_Button_%@",self.textureDimensionLoaded]];
    self.settingsRoundButton = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Settings_Round_Button_%@",self.textureDimensionLoaded]];
    self.storeRoundButton = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Store_Round_Button_%@",self.textureDimensionLoaded]];
    self.rateUsRoundButton = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"rateUS_Round_Button_%@",self.textureDimensionLoaded]];
    self.likeUsFaceBookRoundButton = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"likeUS_Round_Button_%@",self.textureDimensionLoaded]];
    self.helpRoundButton = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"btn_big_menu_game_green"]];
    
    
    
    self.scrollingBackGroundTexture = @[self.backgroundLayerTexture1,
                                                  self.backgroundLayerTexture2,
                                                  self.backgroundLayerTexture3,
                                                  self.backgroundLayerTexture4,
                                                  self.backgroundLayerTexture5,
                                                  self.backgroundLayerTexture6,
                                                  self.backgroundLayerTexture7,
                                                  self.backgroundLayerObstaclesTexture];

    // Tried loading the high res obstacles. but that is causing a stutter. Need to expierment by creating atlasses and trying.
//    if ([loadCharactersWithResolution isEqualToString:@"1x"]) {
//        self.lowerObstacleTallTexture = [SKTexture textureWithImageNamed:@"ObstacleLowerTall"];
//        self.lowerObstacleMediumTexture = [SKTexture textureWithImageNamed:@"ObstacleLowerMedium"];
//        self.lowerObstacleShortTexture = [SKTexture textureWithImageNamed:@"ObstacleLowerShort"];
//        
//        self.upperObstacleTallTexture = [SKTexture textureWithImageNamed:@"ObstacleUpperTall"];
//        self.upperObstacleMediumTexture = [SKTexture textureWithImageNamed:@"ObstacleUpperMedium"];
//        self.upperObstacleShortTexture = [SKTexture textureWithImageNamed:@"ObstacleUpperShort"];
//    }else{
//        self.lowerObstacleTallTexture = [SKTexture textureWithImageNamed:@"ObstacleLowerTall_HighRes"];
//        self.lowerObstacleMediumTexture = [SKTexture textureWithImageNamed:@"ObstacleLowerMedium_HighRes"];
//        self.lowerObstacleShortTexture = [SKTexture textureWithImageNamed:@"ObstacleLowerShort_HighRes"];
//        
//        self.upperObstacleTallTexture = [SKTexture textureWithImageNamed:@"ObstacleUpperTall_HighRes"];
//        self.upperObstacleMediumTexture = [SKTexture textureWithImageNamed:@"ObstacleUpperMedium_HighRes"];
//        self.upperObstacleShortTexture = [SKTexture textureWithImageNamed:@"ObstacleUpperShort_HighRes"];
//    }
    
    // Load all Atlases Here.

//    [SKTextureAtlas preloadTextureAtlases:@[self.characterAtlas,self.environmentAtlas] withCompletionHandler:^{
//        NSLog(@"Loading of all texture Atlases are complete");
//        NSLog(@"The End Time is %f",CFAbsoluteTimeGetCurrent()- currnetTime);
//
//    }];
    
    [SKTexture preloadTextures:self.arrayOfCopterIdleTextures withCompletionHandler:^{
        NSLog(@"copter Idle - preloading Done.");
        self.isCopterIdleTexturesLoaded = YES;
        [self updateTextureLoadingStatus];
    }];

    [SKTexture preloadTextures:self.arrayOfCopterCollisionTextures withCompletionHandler:^{
        NSLog(@"copter Collision - preloading Done.");
        self.isCopterCollissionTexturesLoaded = YES;
        [self updateTextureLoadingStatus];
    }];

    [SKTexture preloadTextures:self.arrayOfCopterGameOverTextures withCompletionHandler:^{
        NSLog(@"copter GameOver - preloading Done.");
        self.isCopterGameOverTexturesLoaded = YES;
        [self updateTextureLoadingStatus];
    }];

    [SKTexture preloadTextures:self.arrayOfEnvironmentBombTextures withCompletionHandler:^{
        NSLog(@"Env Bomb Preloading Done");
        self.isEnvironmentBombsLoaded = YES;
        [self updateTextureLoadingStatus];
    }];
    
    [SKTexture preloadTextures:self.arrayOfEnvironmentCoinTextures withCompletionHandler:^{
        NSLog(@"Env Coin Preloading Done");
        self.isEnvironmentCoinsLoaded = YES;
        [self updateTextureLoadingStatus];
    }];
    
    [SKTexture preloadTextures:self.arrayOfEnvironmentSomkeTextures withCompletionHandler:^{
        self.isEnvironmentSmokeLoaded = YES;
        [self updateTextureLoadingStatus];
    }];
    
    
    [SKTextureAtlas preloadTextureAtlases:@[self.obstaclesAtlas] withCompletionHandler:^{
        
        self.lowerObstacleShortTexture = [self.obstaclesAtlas textureNamed:@"ObstacleLowerShort.png"];
        self.lowerObstacleMediumTexture = [self.obstaclesAtlas textureNamed:@"ObstacleLowerMedium.png"];
        self.lowerObstacleTallTexture = [self.obstaclesAtlas textureNamed:@"ObstacleLowerTall.png"];
        
        self.upperObstacleShortTexture = [self.obstaclesAtlas textureNamed:@"ObstacleUpperShort.png"];
        self.upperObstacleMediumTexture = [self.obstaclesAtlas textureNamed:@"ObstacleUpperMedium.png"];
        self.upperObstacleTallTexture = [self.obstaclesAtlas textureNamed:@"ObstacleUpperTall.png"];
        
        self.isObstaclesLoaded = YES;
        
        [self updateTextureLoadingStatus];
        
    }];

    
    [SKTexture preloadTextures:self.scrollingBackGroundTexture withCompletionHandler:^{
        
        //NSLog(@"self.ScrollingBackground Texture is %@",self.scrollingBackGroundTexture);
        
        self.isScrollingBackgroundLoaded = YES;
        [self updateTextureLoadingStatus];
        
    }];
    
    
    // Cache rewarded video pre-roll message and video ad at location HomeScreen.
    // See Chartboost.h for available location options.
    NSLog(@"I am no Preloading the AD>>>>>>>>>>> ");
    [Chartboost cacheRewardedVideo:CBLocationHomeScreen];
    
    
}

-(void)updateTextureLoadingStatus{
    if (self.isCopterIdleTexturesLoaded && self.isCopterCollissionTexturesLoaded && self.isCopterGameOverTexturesLoaded) {
        self.isAllCopterTexturesLoaded = YES;
    }
    
    if (self.isEnvironmentCoinsLoaded && self.isEnvironmentBombsLoaded && self.isEnvironmentSmokeLoaded && self.isObstaclesLoaded && self.isScrollingBackgroundLoaded) {
        self.isAllEnvironmentTexturesLoaded = YES;
    }
}

-(void)findDeviceType{
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
        
        if ([[UIScreen mainScreen] bounds].size.width == 736.0f){
             // Iphone 6 Plus
            textureDimension = @"1920_X_1080";
            loadCharactersWithResolution = @"3x";
            
            // Medium Screen Fonts
            self.smallFontSize  = 18.0f;
            self.mediumFontSize = 24.0f;
            self.largeFontSize  = 44.0f;

            NSLog(@"I am loading the Copter size for iphone 6 plus");
            self.theCopterSize = CGSizeMake(50, 50);

            //self.GameSpeed = screenWidth/1.75;
            // Prashanth Just going to hard code the initial speed. Not able to find an elegant solution that satisfies all devices.
            self.GameSpeed = 420.0f;
            
        }
        else if ([[UIScreen mainScreen] bounds].size.width == 667.0f){
             // iPhone 6
            textureDimension = @"1334_X_750";
            loadCharactersWithResolution = @"2x";
            
            // Medium Screen Fonts
            self.smallFontSize  = 18.0f;
            self.mediumFontSize = 24.0f;
            self.largeFontSize  = 44.0f;
            
            self.theCopterSize = CGSizeMake(45, 45);
            self.GameSpeed = 378.0f;

        }
        else if ([[UIScreen mainScreen] bounds].size.width == 568.0f){
             // iPhone 5
            textureDimension = @"1136_X_640";
            loadCharactersWithResolution = @"2x";
            
            // Medium Screen Fonts
            self.smallFontSize  = 18.0f;
            self.mediumFontSize = 24.0f;
            self.largeFontSize  = 44.0f;
            self.theCopterSize = CGSizeMake(38, 38);
            self.GameSpeed = 375.0f;

            
        }
        else if ([[UIScreen mainScreen] bounds].size.width == 480.0f) {
            // Check if we are using Retina Display
            if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0)
                //device with Retina Display
                textureDimension = @"960_X_640";
                loadCharactersWithResolution = @"2x";
            
                // Small Screen Fonts
                self.smallFontSize  = 12.0f;
                self.mediumFontSize = 18.0f;
                self.largeFontSize  = 24.0f;
            self.theCopterSize = CGSizeMake(34, 34);
            self.GameSpeed = 340.0f;

        }
        else {
                //no Retina Display
                textureDimension = @"480_X_320";
                loadCharactersWithResolution = @"1x";
            
                // Small Screen Fonts
                self.smallFontSize  = 12.0f;
                self.mediumFontSize = 18.0f;
                self.largeFontSize  = 24.0f;
                self.theCopterSize = CGSizeMake(34, 34);
                self.GameSpeed = 340.0f;

        }
    } else if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        //is iPad
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0){
            //device with Retina Display
            textureDimension = @"2048_X_1536";
            loadCharactersWithResolution = @"3x";
            
            // Large Screen Fonts
            self.smallFontSize  = 24.0f;
            self.mediumFontSize = 32.0f;
            self.largeFontSize  = 44.0f;
            
            self.theCopterSize = CGSizeMake(75, 75);
            self.GameSpeed = 500.0f;
    }
        else{
            //no Retina Display
            textureDimension = @"1024_X_768";
            loadCharactersWithResolution = @"2X";
            
            // Large Screen Fonts
            self.smallFontSize  = 24.0f;
            self.mediumFontSize = 32.0f;
            self.largeFontSize  = 44.0f;

            self.theCopterSize = CGSizeMake(75, 75);
            self.GameSpeed = 500.0f;

        }
    }
    else if ([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomUnspecified){
        // Not sure which Device. Just load the ipad Non Retina Resolution.
        textureDimension = @"1024_X_768";
        loadCharactersWithResolution = @"2X";
    
        // Medium Screen Fonts
        self.smallFontSize  = 18.0f;
        self.mediumFontSize = 24.0f;
        self.largeFontSize  = 44.0f;

        self.theCopterSize = CGSizeMake(75.0, 75.0);
        self.GameSpeed = 500.0f;

    }
    
    self.theCoinNodeSize = CGSizeMake(self.theCopterSize.width/2.0, self.theCopterSize.height/2.0);
    self.theBombNodeSize = CGSizeMake(self.theCopterSize.width/2.0, (self.theCopterSize.height * 1.3)/2.0);
    self.obstacleWidth = self.theCopterSize.width * 1.25;

}

@end
