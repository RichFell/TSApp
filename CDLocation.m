//
//  CDLocation.m
//  TSApp
//
//  Created by Rich Fellure on 3/21/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "CDLocation.h"
#import "CDRegion.h"


@implementation CDLocation

@dynamic name;
@dynamic index;
@dynamic id;
@dynamic visited;
@dynamic latitude;
@dynamic longitude;
@dynamic engAddress;
@dynamic localAddress;
@dynamic region;

-(BOOL)hasVisited {
    return [self.visited boolValue];
}

-(void)setHasVisited:(BOOL)hasVisited {
    self.visited = [NSNumber numberWithBool:hasVisited];
}

@end
