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

    direction.step = [dictionary[@"html_instructions"] stringByStrippingHtml];
    direction.startingLatitude = [dictionary[@"start_location"][@"lat"] floatValue];
    direction.startingLongitude = [dictionary[@"start_location"][@"lng"]floatValue];
    direction.endingLatitude = [dictionary[@"end_location"][@"lat"]floatValue];
    direction.endingLongitude = [dictionary[@"end_location"][@"lng"]floatValue];
    direction.distance = dictionary[@"distance"][@"text"];
    direction.duration = dictionary[@"duration"][@"text"];
    return direction;
}

+(void)getDirectionsWithCoordinate:(CLLocationCoordinate2D)startingPosition andEndingPosition:(CLLocationCoordinate2D)endPosition withTypeOfTransportation:(NSString *)transportation andBlock:(void (^)(NSArray *, NSError *))completionHandler
{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&key=AIzaSyCLR3ztaPMZugnESkzeeAWWTkxbHTpgCPA&departure_time=now&mode=%@", startingPosition.latitude, startingPosition.longitude, endPosition.latitude, endPosition.longitude, transportation];
    NSLog(@"%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *jsonError = nil;

        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        NSArray *theDirections = [NSArray arrayWithArray:dictionary[@"routes"]];
        if (theDirections.count != 0) {
            NSDictionary *legsDict = theDirections[0];
            NSArray *dArray = legsDict[@"legs"];
            NSDictionary *anotherDict = dArray[0];
            NSArray *stepsArray = anotherDict[@"steps"];

            NSMutableArray *dirArray = [NSMutableArray new];

            for (NSDictionary *dirDict in stepsArray) {
                Direction *dir = [Direction initWithDictionary:dirDict];
                [dirArray addObject:dir];
            }
            completionHandler(dirArray, connectionError);

        }
        else {
            completionHandler(nil, nil);
        }

    }];
}
@end
