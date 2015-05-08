//
//  YPBusiness.h
//  TSApp
//
//  Created by Rich Fellure on 4/16/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreLocation/CoreLocation.h>
#import "UniversalBusiness.h"

@interface YPBusiness : NSObject

@property NSString *name;
@property NSString *address;
@property CLLocationCoordinate2D coordinate;
@property NSString *businessId;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

+(void)fetchBusinessesFromYelpForBounds:(CLLocationCoordinate2D)neCoordinate andSEBounds:(CLLocationCoordinate2D)seCoordinate andCompareAgainstBusinesses:(NSArray *)businesses completed:(void (^)(NSArray *))completionHandler;

+(void)fetchBusinessesFromYelpMatchingName:(NSString *)name
                                notInArray:(NSArray *) businessesArray
                                 completed:(void(^)(NSArray *businesses))completionHandler;

@end
