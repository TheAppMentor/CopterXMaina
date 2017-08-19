//
//  GameViewController.m
//  copterMania
//
//  Created by Prashanth Moorthy on 3/6/15.
//  Copyright (c) 2015 The App Mentor. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "GamePlayScene.h"
#import "TexturePreLoader.h"
#import "GameCenterHelper.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#define SHOW_DEBUG_MESSAGES 1

@interface GameViewController (){

}

@property (strong,nonatomic) TexturePreLoader *theTexturePreloader;
@property (nonatomic, strong) UIView *contentView;


@end

@implementation SKScene (Unarchive)


+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation GameViewController{
    BOOL showSettings;
    UILabel *gravityLabel;
    UILabel *speedLabel;
    UISlider *gravitySlider;
    UISlider *speedSlider;
    GameScene *scene;
    
    BOOL isCopterTexturePreLoadingComplete;
    BOOL isEnvironmentTexturePreLoadingComplete;
}

-(TexturePreLoader *)theTexturePreloader{
    if (!_theTexturePreloader) {
        _theTexturePreloader = [TexturePreLoader sharedTexturePreLoader];
    }
    return _theTexturePreloader;
}

-(ADBannerView *)bannerView{
    if (!_bannerView) {
        // On iOS 6 ADBannerView introduces a new initializer, use it when available.
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        } else {
            _bannerView = [[ADBannerView alloc] init];
        }
        _bannerView.delegate = self;
    }
    return _bannerView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    // Register For notification, that determines when ads should be shown.
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBannerView) name:@"showAds" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationViewController) name:PresentAuthenticationViewController object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayControlsvalueChanged) name:@"dispalyControlsChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopShowingAds) name:@"stopShowingAds" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startShowingAds) name:@"startShowingAds" object:nil];

    
    [[GameCenterHelper sharedGameKitHelper] authenticateLocalPlayer];
    
    self.contentView = self.view;
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    skView.showsDrawCount = NO;
    skView.showsPhysics = NO;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    
    // Create and configure the scene.
    scene = [GameScene unarchiveFromFile:@"GameScene"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    isCopterTexturePreLoadingComplete = NO;
    isEnvironmentTexturePreLoadingComplete = NO;
    
    // Present the main Game Screen.
  //  [self presentMainScreen];
    
    [self.theTexturePreloader preLoadAllTextures:self];



//    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
//    loginButton.center = self.view.center;
//    [self.view addSubview:loginButton];

}

-(void)viewWillAppear:(BOOL)animated{

}

-(void)viewDidAppear:(BOOL)animated{
    // Start Showing ads. If we show it in the game.. its kind of late, causes the stutter.
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CopterRemoveAllAds"]) {
        [self showBannerView];
    }
}


-(void)stopShowingAds{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CopterRemoveAllAds"]) {
        // Prashanth, Here is hwere I am ignoring the stop showing ads. thing.
        //NSLog(@"Now I will Stop Showing Ads");
        //[_bannerView setHidden:YES];

    }
}

-(void)startShowingAds{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"CopterRemoveAllAds"]) {
        NSLog(@"Now I will START Showing Ads");

        [self showBannerView];
    }
}


-(void)displayControlsvalueChanged{
    NSLog(@"Display Controls Value Changed ==>  %@",[[NSUserDefaults standardUserDefaults] boolForKey:@"showControls"]? @"Show": @"Hide");

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showControls"]) {
        [self displayControls];

        [self.view addSubview:gravitySlider];
        [self.view addSubview:gravityLabel];
        
        [self.view addSubview:speedSlider];
        [self.view addSubview:speedLabel];
        [self.view setNeedsDisplay];
        
   }else{
        
        [gravityLabel removeFromSuperview];
        [gravitySlider removeFromSuperview];
        [speedLabel removeFromSuperview];
        [speedSlider removeFromSuperview];
       [self.view setNeedsDisplay];

   }
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"isAllEnvironmentTexturesLoaded"]) {
        isEnvironmentTexturePreLoadingComplete = YES;
    }
    if ([keyPath isEqualToString:@"isAllCopterTexturesLoaded"]) {
        isCopterTexturePreLoadingComplete = YES;
    }
    if (isCopterTexturePreLoadingComplete && isEnvironmentTexturePreLoadingComplete) {
        [self presentMainScreen];
    }
}

- (void)presentMainScreen{
    
    SKView * skView = (SKView *)self.view;
    
    // Create and configure the scene.
    scene = [GameScene unarchiveFromFile:@"GameScene"];
    scene.scaleMode = SKSceneScaleModeFill;

    // Present the scene.
    [skView presentScene:scene];
    
    [[NSUserDefaults standardUserDefaults] setValue:@"-7.0" forKey:@"gravity"];
    [[NSUserDefaults standardUserDefaults] setValue:@"500" forKey:@"gameSpeed"];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)updateSlider:(UISlider *)sender{
    gravityLabel.text = [NSString stringWithFormat:@"%.3f",sender.value];
    [[NSUserDefaults standardUserDefaults] setValue:gravityLabel.text forKey:@"gravity"];
}


-(void)updateGameSpeedSlider:(UISlider *)sender{
    speedLabel.text = [NSString stringWithFormat:@"%.f",sender.value];
    [[NSUserDefaults standardUserDefaults] setValue:speedLabel.text forKey:@"gameSpeed"];
}


//-(void)restartGame{
//    NSLog(@"Ok restart button was pressed");
//    
//    // Present the scene.
//    SKView * skView = (SKView *)self.view;
//
//    SKTransition *transitionToMainScreen = [SKTransition fadeWithDuration:1.0];
//#warning Prashanth Need to find a better way to fix this. The sizes are hard coded here... change it.
//    GamePlayScene *theGameScene = [GamePlayScene sceneWithSize:skView.frame.size];
//    NSLog(@"--> One More Ulli Ulli .. %@",NSStringFromCGSize(skView.frame.size));
//    scene.scaleMode = SKSceneScaleModeFill;
//    
//
//    [skView presentScene:theGameScene transition:transitionToMainScreen];
//    
//}

-(void)displayControls{

    // Change Gravity Slider
    gravitySlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 375, 300, 30)];
    gravitySlider.backgroundColor = [UIColor clearColor];
    [gravitySlider addTarget:self action:@selector(updateSlider:) forControlEvents:UIControlEventValueChanged];
    gravitySlider.minimumValue = -11.0f;
    gravitySlider.maximumValue = 0.0f;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"gravity"]) {
        [gravitySlider setValue:[[[NSUserDefaults standardUserDefaults] valueForKey:@"gravity"] floatValue]];
        
    }
    
    gravityLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 340, 80, 40)];
    gravityLabel.backgroundColor = [UIColor grayColor];
    gravityLabel.textAlignment = NSTextAlignmentCenter;
    [self updateSlider:gravitySlider];
    
    // Change Speed Slider
    speedSlider = [[UISlider alloc] initWithFrame:CGRectMake(380, 375, 300, 30)];
    speedSlider.backgroundColor = [UIColor clearColor];
    [speedSlider addTarget:self action:@selector(updateGameSpeedSlider:) forControlEvents:UIControlEventValueChanged];
    speedSlider.minimumValue = 0;
    speedSlider.maximumValue = 800;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"gameSpeed"]) {
        [speedSlider setValue:[[[NSUserDefaults standardUserDefaults] valueForKey:@"gameSpeed"] floatValue]];
    }
    
    speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(380, 340, 80, 40)];
    speedLabel.backgroundColor = [UIColor grayColor];
    speedLabel.textAlignment = SKLabelVerticalAlignmentModeCenter;
    [self updateGameSpeedSlider:speedSlider];
    

}

#pragma Ad Banners Methods.
// -------------------------------------------------------------//
//               iAD Banner Delegate Methods
// -------------------------------------------------------------//

//-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
//    // Once iAd is received, remove adMob or Startapp from the superview.
//    [self.bannerView setHidden:NO];
//    
//}


//- (void)bannerViewActionDidFinish:(ADBannerView *)banner{
//    NSLog(@"Delegate Method, Coming back from AdBannerview is not working. Checking.");
//}
//
//- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
//    return YES;
//}


-(void)showBannerView{
    // Setup the Ad Banner
    NSLog(@"NOTIFICATION >>>>>>>>>>>>>>>> Now I will start showing ads");
    
    // Add the iAD Banner here
    [self.view addSubview:self.bannerView];
    
    [_bannerView setHidden:YES];
    
    _bannerView.center = self.view.center;
    [_bannerView setFrame:CGRectMake(_bannerView.center.x - (_bannerView.frame.size.width/2.0), self.view.frame.size.height - (_bannerView.frame.size.height), _bannerView.frame.size.width,_bannerView.frame.size.height)];
    _bannerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
  

}

- (void)showAuthenticationViewController {
    GameCenterHelper *gameKitHelper = [GameCenterHelper sharedGameKitHelper];
    [self presentViewController: gameKitHelper.authenticationViewController
                                         animated:YES completion:nil];
}

- (void)layoutAnimated:(BOOL)animated
{
    // As of iOS 6.0, the banner will automatically resize itself based on its width.
    // To support iOS 5.0 however, we continue to set the currentContentSizeIdentifier appropriately.
    
  //  _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    
//    [_bannerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
//    _bannerView.center = self.view.center;
//    [_bannerView setFrame:CGRectMake(0, self.view.frame.size.height- _bannerView.frame.size.height, self.view.frame.size.width,_bannerView.frame.size.height)];
}


- (void)viewDidLayoutSubviews
{
   [self layoutAnimated:[UIView areAnimationsEnabled]];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"I Got an Ad");
    [_bannerView setHidden:NO];
//    [self layoutAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"Ad Failed.");
    [_bannerView setHidden:YES];
//   [self layoutAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    NSLog(@"Ad.. Will lweave app");
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


@end



//-(void)showBannerView{
//    // Setup the Ad Banner
//    
//    NSLog(@"NOTIFICATION >>>>>>>>>>>>>>>> Now I will start showing ads");
//    
//    // Add the iAD Banner here
//    [self.view addSubview:self.bannerView];
//    [_bannerView setHidden:YES];
//    
//    _bannerView.center = self.view.center;
//    [_bannerView setFrame:CGRectMake(0, self.view.frame.size.height- _bannerView.frame.size.height, self.view.frame.size.width,_bannerView.frame.size.height)];
//    
//    
//    // pin sides to superview
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_bannerView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bannerView)]];
//    
//    // set height to a constant
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_bannerView(==66)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_bannerView)]];
//    
//    // pin contentView to bannerView with 0 length constraint
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_contentView]-0-[_bannerView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_contentView,_bannerView)]];
//    //    [self layoutAnimated:NO];
//    
//}