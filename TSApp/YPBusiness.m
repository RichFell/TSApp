//
//  YPBusiness.m
//  TSApp
//
//  Created by Rich Fellure on 4/16/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "YPBusiness.h"
#import "TDOAuth.h"

@implementation YPBusiness


-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    self.name = dictionary[@"name"];
    self.address = dictionary[@"location"][@"display_address"];
    NSNumber *lat = dictionary[@"location"][@"latitude"];
    NSNumber *longi = dictionary[@"location"][@"longitude"];
    self.coordinate = CLLocationCoordinate2DMake(lat.floatValue, longi.floatValue);
    return self;
}

+(void)fetchBusinessesFromYelpForBounds:(CLLocationCoordinate2D)neCoordinate andSEBounds:(CLLocationCoordinate2D)seCoordinate completed:(void (^)(NSArray *))completionHandler {
    NSURLRequest *request = [TDOAuth URLRequestForPath:kYelpRequestPath GETParameters:@{kYelpQueryKey: kYelpQueryType, kYelpBoundsKey: [NSString stringWithFormat:@"%f,%f|%f,%f", seCoordinate.latitude, seCoordinate.longitude, neCoordinate.latitude, neCoordinate.longitude], kYelpLimitKey : kYelpQueryLimit, kYelpSortKey : kYelpSortType}
                                         host:kYelpHost
                                  consumerKey:kYelpConsumerKey
                               consumerSecret:kYelpConsumerSecret
                                  accessToken:kYelpToken
                                  tokenSecret:kYelpTokenSecret];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSArray *array = dict[@"businesses"];
            NSMutableArray *mArray = [NSMutableArray new];
            for (NSDictionary *dictionary in array) {
                YPBusiness *busi = [[YPBusiness alloc]initWithDictionary:dictionary];
                [mArray addObject:busi];
            }
            completionHandler(mArray);
        }
    }];
}


@end
