//
//  AppDelegate.m
//  TSApp
//
//  Created by Richard Fellure on 7/19/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "User.h"
#import "Region.h"
#import "Location.h"
#import "FBSessionManager.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [GMSServices provideAPIKey:@"AIzaSyCLR3ztaPMZugnESkzeeAWWTkxbHTpgCPA"];

    [Parse setApplicationId:@"tODHHsxlD4kr43TJG7T0TB74doArNn9w370bG4s9"
                  clientKey:@"RWXNAF7TiGqnVaQJERLfLivu4LgRD6RJTJfzCvt1"];
    [Parse enableLocalDatastore];

    [Region registerSubclass];
    [Location registerSubclass];
    [User registerSubclass];

    self.window.tintColor = [UIColor customOrange];
    return YES;

}
							
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActive];
}

@end
