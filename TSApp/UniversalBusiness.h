//
//  UniversalBusiness.h
//  TSApp
//
//  Created by Rich Fellure on 5/8/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YPBusiness;

@interface UniversalBusiness : NSObject

@property NSMutableArray *currentBusinesses;

+(instancetype)sharedInstance;

@end
