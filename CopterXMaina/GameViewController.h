//
//  GameViewController.h
//  copterMania
//

//  Copyright (c) 2015 The App Mentor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <iAd/iAd.h>


@interface GameViewController : UIViewController <ADBannerViewDelegate>

@property (strong, nonatomic) ADBannerView *bannerView;

@end
