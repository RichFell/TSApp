//
//  UserDefaults.m
//  TSApp
//
//  Created by Rich Fellure on 11/28/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "UserDefaults.h"
#import "AppDelegate.h"

@implementation UserDefaults

static NSString *const kDefaultRegion = @"defaultRegion";

///Sets the default Region.objectId in NSUserDefaults
+(void)setDefaultRegion:(CDRegion *)theRegion
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:theRegion.objectId forKey:kDefaultRegion];
    [NSUserDefaults.standardUserDefaults synchronize];
}

///Gets the default Region by seeing if there is a default Region, and if there is then doing a query for it based on the stored objectId
+(void)getDefaultRegionWithBlock:(void (^)(CDRegion *, NSError *))completionHandler
{
    if ([NSUserDefaults.standardUserDefaults objectForKey:kDefaultRegion] != nil)
    {

        NSString *defaultId = [NSUserDefaults.standardUserDefaults objectForKey:kDefaultRegion];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", defaultId];
        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:NSStringFromClass([CDRegion class])];
        request.predicate = predicate;
        AppDelegate *appDel = [[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *moc = appDel.managedObjectContext;
        NSArray *regions = [moc executeFetchRequest:request error:nil];
        completionHandler(regions[0], nil);
    }
    else
    {
        completionHandler(nil, nil);
    }
}
@end
