//
//  User.m
//  TSApp
//
//  Created by Rich Fellure on 8/21/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "User.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation User

+(void)load
{
    [self registerSubclass];
}

+(User *)currentUser
{
    return (User *)[PFUser currentUser];
}
-(instancetype)initWithUsername:(NSString *)username withPassword: (NSString *)password andEmail: (NSString *)email completion:(void(^)(BOOL , NSError *))completionHandler {
    self = [super init];
    self.username = username;
    self.password = password;
    self.email = email;
    [self signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionHandler(succeeded, error);
    }];
    return self;
}

@end
