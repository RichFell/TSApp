//
//  ParseModel.m
//  TSApp
//
//  Created by Rich Fellure on 8/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "ParseModel.h"

@implementation ParseModel

-(void)createRegion:(NSString *)name
{
    self.currentRegion = [PFObject objectWithClassName:@"Region"];
    self.currentRegion[@"Name"] = name;
    [self.currentRegion saveInBackground];
}

-(void)createLocation
{
    PFObject *location = [PFObject objectWithClassName:@"Location"];
//    self.currentRegion addObject:<#(id)#> forKey:<#(NSString *)#>
}


@end
