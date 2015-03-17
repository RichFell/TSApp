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

+(void)createUserWithUserName:(NSString *)username withPassword:(NSString *)password andEmail:(NSString *)email completion:(void (^)(BOOL, NSError *))completionHandler {

    User *user = [[User alloc] initWithUsername:username withPassword:password andEmail:email];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionHandler(succeeded, error);
    }];

}
-(instancetype)initWithUsername:(NSString *)username withPassword: (NSString *)password andEmail: (NSString *)email {
    self = [super init];
    self.username = username;
    self.password = password;
    self.email = email;
    return self;
}

@end
