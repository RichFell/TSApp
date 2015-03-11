//
//  FBSessionManager.m
//  TSApp
//
//  Created by Rich Fellure on 3/10/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "FBSessionManager.h"
#import "User.h"

@implementation FBSessionManager

+(void)checkForActiveSession {
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {

        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // Call this method EACH time the session state changes,
                                          //  NOT just when the session open
//                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }
}

+(void)createNewSessionWithBlock:(void (^)(BOOL, NSError *))completionHandler {
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    else {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"] allowLoginUI:true completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (status == FBSessionStateOpen) {
                [FBSessionManager loginUserForSession:session completion:^(bool result, NSError *error) {
                    completionHandler(result, error);
                }];
            }
            else {
                completionHandler(false, error);
            }
        }];
    }
}

+(void)loginUserForSession:(FBSession *)session completion:(void(^)(bool result, NSError *error))completionHandler {
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
        if (!error) {
            NSString *email = [user objectForKey:@"email"];
            User *user = [[User alloc] initWithUsername:email withPassword:email andEmail:email completion:^(BOOL result, NSError *error) {
                NSLog(@"%@", user);
                completionHandler(result, error);
            }];
        }
    }];
}

// Handles session state changes in the app
+(BOOL)sessionStateChanged:(FBSessionState) state error:(NSError *)error {
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){

        return true;
    }
    else {
        return false;
    }
}

@end
