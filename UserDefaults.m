//
//  UserDefaults.m
//  TSApp
//
//  Created by Rich Fellure on 11/28/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "UserDefaults.h"

@implementation UserDefaults

///Sets the default Region.objectId in NSUserDefaults
+(void)setDefaultRegion:(Region *)theRegion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:theRegion.objectId forKey:@"defaultRegion"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

///Gets the default Region by seeing if there is a default Region, and if there is then doing a query for it based on the stored objectId
+(void)getDefaultRegionWithBlock:(void (^)(Region *, NSError *))completionHandler
{
    if ([NSUserDefaults.standardUserDefaults objectForKey:@"defaultRegion"] != nil)
    {
        NSString *defaultId = [NSUserDefaults.standardUserDefaults objectForKey:@"defaultRegion"];
        [Region queryForRegionWithObjectId:defaultId completion:^(Region *defaultRegion, NSError *error) {
            completionHandler(defaultRegion, error);
        }];
    }
    else
    {
        completionHandler(nil, nil);
    }
}
@end
