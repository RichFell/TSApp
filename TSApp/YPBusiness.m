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
    self.address = [self addressStringFromArray: dictionary[@"location"][@"display_address"]];
    NSNumber *lat = dictionary[@"location"][@"coordinate"][@"latitude"];
    NSNumber *longi = dictionary[@"location"][@"coordinate"][@"longitude"];
    self.coordinate = CLLocationCoordinate2DMake(lat.floatValue, longi.floatValue);
    self.businessId = dictionary[@"id"];
    return self;
}

//Have to use this because the @"display_address" is actually an array of strings.
-(NSString *)addressStringFromArray:(NSArray *)array {
    NSMutableString *mString = [NSMutableString new];
    for (NSString *string in array) {
        [mString appendString:string];
    }
    return mString;
}

+(void)fetchBusinessesFromYelpForBounds:(CLLocationCoordinate2D)neCoordinate andSEBounds:(CLLocationCoordinate2D)seCoordinate andCompareAgainstBusinesses:(NSArray *)businesses completed:(void (^)(NSArray *))completionHandler {
    NSURLRequest *request = [TDOAuth URLRequestForPath:kYelpRequestPath GETParameters:@{kYelpBoundsKey: [NSString stringWithFormat:@"%f,%f|%f,%f", seCoordinate.latitude, seCoordinate.longitude, neCoordinate.latitude, neCoordinate.longitude], kYelpLimitKey : kYelpQueryLimit, kYelpSortKey : kYelpSortType}
                                         host:kYelpHost
                                  consumerKey:kYelpConsumerKey
                               consumerSecret:kYelpConsumerSecret
                                  accessToken:kYelpToken
                                  tokenSecret:kYelpTokenSecret];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSArray *array = dict[@"businesses"] ? dict[@"businesses"] : @[];
            NSMutableArray *mArray = [NSMutableArray new];

            if (businesses.count > 0) {
                array = [YPBusiness compareArrayOfDictionaries:array toArrayOfBusinesses:businesses];
            }
            for (NSDictionary *dictionary in array) {
                YPBusiness *busi = [[YPBusiness alloc]initWithDictionary:dictionary];
                [mArray addObject:busi];
            }
            completionHandler(mArray);
        }
        else {
            completionHandler(nil);
        }
    }];
}

+(NSArray *)compareArrayOfDictionaries:(NSArray *)dictionaries toArrayOfBusinesses:(NSArray *)businesses {
    NSSet *businessesSet = [NSSet setWithArray:businesses];
    NSMutableArray *predArray = [NSMutableArray new];
    for (YPBusiness *business in businessesSet) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id != %@", business.businessId];
        [predArray addObject:predicate];
    }
    NSPredicate *compoundPred = [NSCompoundPredicate andPredicateWithSubpredicates:predArray];

    return [dictionaries filteredArrayUsingPredicate:compoundPred];
}


@end
