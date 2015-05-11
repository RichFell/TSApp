//
//  YPBusiness.m
//  TSApp
//
//  Created by Rich Fellure on 4/16/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "Business.h"
#import "TDOAuth.h"
#import "UniversalBusiness.h"
#import <MapKit/MapKit.h>

@implementation Business


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

-(instancetype)initWithMapItem:(MKMapItem *)mapItem {
    self = [super init];
    if (self) {
        self.name = mapItem.name;
        NSString *addressString = [NSString stringWithFormat:@"%@ %@, %@", mapItem.placemark.thoroughfare, mapItem.placemark.locality, mapItem.placemark.administrativeArea];
        self.address = addressString;
        self.coordinate = mapItem.placemark.coordinate;
    }
    return self;
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

            //If I have already pulled in Businesses from yelp, I want to check to make sure I am not duplicating what I already have.
            if (businesses.count > 0) {
                array = [Business compareArrayOfDictionaries:array toArrayOfBusinesses:businesses];
            }
            for (NSDictionary *dictionary in array) {
                Business *busi = [[Business alloc]initWithDictionary:dictionary];
                [mArray addObject:busi];
            }
            UniversalBusiness *sharedBusiness = [UniversalBusiness sharedInstance];
            [sharedBusiness.currentBusinesses addObjectsFromArray:mArray];
            completionHandler(mArray);
        }
        else {
            completionHandler(nil);
        }
    }];
}

+(void)fetchBusinessesFromYelpMatchingName:(NSString *)name
                                notInArray:(NSArray *) businessesArray
                                 completed:(void(^)(NSArray *businesses))completionHandler {
    NSURLRequest *request = [TDOAuth URLRequestForPath:kYelpRequestPath GETParameters:@{kYelpTermKey: name, kYelpLimitKey: kYelpQueryLimit, kYelpSortKey: kYelpSortType}
                                                  host:kYelpHost
                                           consumerKey:kYelpConsumerKey
                                        consumerSecret:kYelpConsumerSecret
                                           accessToken:kYelpToken
                                           tokenSecret:kYelpTokenSecret];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", dict);
        }
    }];
}

+(NSArray *)compareArrayOfDictionaries:(NSArray *)dictionaries toArrayOfBusinesses:(NSArray *)businesses {
    NSSet *businessesSet = [NSSet setWithArray:businesses];
    NSMutableArray *predArray = [NSMutableArray new];
    for (Business *business in businessesSet) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id != %@", business.businessId];
        [predArray addObject:predicate];
    }
    NSPredicate *compoundPred = [NSCompoundPredicate andPredicateWithSubpredicates:predArray];

    return [dictionaries filteredArrayUsingPredicate:compoundPred];
}

+(void)executeSearchForBusinessMatchingText:(NSString *)text completed:(void(^)(NSArray *businesses, NSError *error))completionHandler{
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = text;
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response) {
            NSMutableArray *array = [NSMutableArray new];
            for (MKMapItem *mapItem in response.mapItems) {
                Business *biz = [[Business alloc]initWithMapItem:mapItem];
                [array addObject:biz];
            }
            completionHandler(array, error);
        }
        else {
            completionHandler(nil, error);
        }
    }];
}



@end
