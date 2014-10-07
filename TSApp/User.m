//
//  User.m
//  TSApp
//
//  Created by Rich Fellure on 8/21/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "User.h"

@implementation User

+(void)load
{
    [self registerSubclass];
}

+(User *)currentUser
{
    return (User *)[PFUser currentUser];
}
+(void)signUpNewUserWithUsername:(NSString *)username withPassword:(NSString *)password withEmail:(NSString *)email andCompletion:(void (^)(PFUser *, NSError *))completionHandler
{
    PFUser *user = [PFUser object];
    user.username = username;
    user.password = password;
    user.email = email;

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionHandler(user, error);
    }];
}

@end
