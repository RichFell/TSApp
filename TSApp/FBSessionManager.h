//
//  FBSessionManager.h
//  TSApp
//
//  Created by Rich Fellure on 3/10/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FBSessionManager : NSObject

+(void)checkForActiveSession;
+(void)createNewSessionWithBlock:(void (^)(BOOL result, NSError *error))completionHandler;
@end
