//
//  GameViewController.h
//  copterMania
//

//  Copyright (c) 2015 The App Mentor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>
@import GoogleMobileAds;

@interface GameViewController : UIViewController <ADBannerViewDelegate>

@property (strong, nonatomic) ADBannerView *bannerView;
@property (nonatomic, strong) GADBannerView *adMobbannerView;


@end
