//
//  User.h
//  TSApp
//
//  Created by Rich Fellure on 8/21/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>

@interface User : PFUser<PFSubclassing>

+(void)load;
+(User *)currentUser;
+(void)createUserWithUserName: (NSString *)username withPassword:(NSString *)password andEmail: (NSString *)email completion:(void(^)(BOOL result, NSError *error))completionHandler;
@end
