//
//  Direction.m
//  TSApp
//
//  Created by Rich Fellure on 9/1/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "Direction.h"
#import "NSString+StringCategory.h"

@implementation Direction

+(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    Direction *direction = [[Direction alloc]init];

    direction.direction = [dictionary[@"html_instructions"] stringByStrippingHtml];
    direction.startingLatitude = [dictionary[@"start_location"][@"lat"] floatValue];
    direction.startingLongitude = [dictionary[@"start_location"][@"lng"]floatValue];
    direction.endingLatitude = [dictionary[@"end_location"][@"lat"]floatValue];
    direction.endingLongitude = [dictionary[@"end_location"][@"lng"]floatValue];
    direction.distance = dictionary[@"distance"][@"text"];
    return direction;
}
@end
