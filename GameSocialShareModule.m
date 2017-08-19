//
//  GameSocialShareModule.m
//  CopterXMaina
//
//  Created by Prashanth Moorthy on 4/2/15.
//  Copyright (c) 2015 The App Mentor. All rights reserved.
//

#import "GameSocialShareModule.h"

@implementation GameSocialShareModule



-(void)presentShareOnFBDialog{
    [self shareLinkWithShareDialog:self];
}


//------------------Sharing a link using the share dialog------------------
- (IBAction)shareLinkWithShareDialog:(id)sender
{
    
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    // Link to the appStore here.
    params.link = [NSURL URLWithString:@"https://itunes.apple.com/us/app/wordcook/id892329007?ls=1&mt=8"];
    params.linkDescription = @"";
    params.name=@"Copter Maina";
    params.caption=@"Try our this interesting new iOS word game. Its Free!";
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        
        
        [FBDialogs presentShareDialogWithLink:params.link name:params.name caption:params.caption description:params.linkDescription picture:nil clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            if(error) {
                // An error occurred, we need to handle the error
                // See: https://developers.facebook.com/docs/ios/errors
                NSLog(@"Error publishing story: %@", error.description);
#warning Prashanth.. check here if the post was successful or not.
              [self userSuccessfullySharedOnFaceBook];
            } else {
                // Success
                NSLog(@"result %@", results);
#warning Prashanth.. check here if the post was successful or not.
               [self userSuccessfullySharedOnFaceBook];
                
            }
            
        }];
        
        //        // Present share dialog
        //        [FBDialogs presentShareDialogWithLink:params.link
        //                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
        //                                          if(error) {
        //                                              // An error occurred, we need to handle the error
        //                                              // See: https://developers.facebook.com/docs/ios/errors
        //                                              NSLog(@"Error publishing story: %@", error.description);
        //#warning Prashanth Remove this later. and handle the error.
        //                                              [self userSuccessfullySharedOnFaceBook];
        //                                          } else {
        //                                              // Success
        //                                              NSLog(@"result %@", results);
        //                                              [self userSuccessfullySharedOnFaceBook];
        //
        //                                          }
        //                                      }];
        
        // If the Facebook app is NOT installed and we can't present the share dialog
    } else {
        // FALLBACK: publish just a link using the Feed dialog
        
        // Put together the dialog parameters
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"Word Cook", @"name",
                                       @"Try our this interesting new iOS word game. Its Free !", @"caption",
                                       @"", @"description",
                                       @"https://itunes.apple.com/us/app/wordcook/id892329007?ls=1&mt=8", @"link",
                                       @"http://i.imgur.com/6nTRAqj.png?1", @"picture",
                                       nil];
        
        // Show the feed dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // An error occurred, we need to handle the error
                                                          // See: https://developers.facebook.com/docs/ios/errors
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // User canceled.
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              // Handle the publish feed callback
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  // User canceled.
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  // User clicked the Share button
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

- (void)userSuccessfullySharedOnFaceBook{
    
    NSLog(@"OK the Sharing on FB was successful");
    //[self.gamePlayVC userCompletedSharingOnFaceBook];
    
}



// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    NSLog(@"!!!!!!!! Prashanth I came into the Handler !!!!!!");
    
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                      // Here goes the code to handle the links
                                      // Use the links to show a relevant view of your app to the user
                                  }];
    
    return urlWasHandled;
}




@end
