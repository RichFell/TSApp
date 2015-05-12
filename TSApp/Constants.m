//
//  Constants.m
//  TSApp
//
//  Created by Rich Fellure on 4/7/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "Constants.h"

NSString *const kStoryboardID = @"Main";
NSString *const kSomeString = @"some String";
NSString *const kSelectedDirectionNotification = @"selectedDirectionNotification";
NSString *const kDirectionArrayKey = @"selectedDirections";
NSString *const kUpArrowImage = @"TSOrangeUpArrow";
NSString *const kDownArrowImage = @"TSOrangeDownArrow";
NSString *const kNeedToVisitString = @"Need To Visit";
NSString *const kVisitedString = @"Visited";
NSString *const kPlaceHolderImage = @"PlaceHolderImage";
CGFloat const kAnimationDuration = 0.5;
CGFloat const kImageViewConstraintConstantOpen = 0.0;
CGFloat const kTSSpacing = 8.0;

//Default height for tableViewCells
CGFloat const kTableViewHeaderHeight = 20.0;

CGFloat const kMapViewPadding = 30.0;
CGFloat const kMapViewZoom = 12.0;
CGFloat const kMapViewZoomLocation = 17.0;
CGFloat const kMapViewPolylineWidth = 5.0;

//UserDefaults keys
NSString *const kHasBeenRun = @"HasBeenRun";

//Notification Names
NSString *const kCreatedFirstTrip = @"CreatedFirstTrip";

//API Keys

NSString *const kGoogleAPIKey = @"AIzaSyCLR3ztaPMZugnESkzeeAWWTkxbHTpgCPA";
NSString *const kParseAppId = @"tODHHsxlD4kr43TJG7T0TB74doArNn9w370bG4s9";
NSString *const kParseClientKey = @"RWXNAF7TiGqnVaQJERLfLivu4LgRD6RJTJfzCvt1";

NSString *const kYelpConsumerKey = @"srBbZz5ZOzUQ193e5_NSWQ";
NSString *const kYelpConsumerSecret = @"1xnmtgQnpfeokQC-U1ScIzD9CNc";
NSString *const kYelpToken = @"e5wyV6TxSDrFa7V8vQOA-ndqe3FIF_Py";
NSString *const kYelpTokenSecret = @"6f2dyu0xmUE4waLLsOkusYnoMJ0";

//Yelp URL constructors
NSString *const kYelpHost = @"api.yelp.com";
NSString *const kYelpRequestPath = @"/v2/search";
NSString *const kYelpQueryType = @"Business";
NSString *const kYelpQueryKey = @"query";
NSString *const kYelpBoundsKey = @"bounds";
NSString *const kYelpLimitKey = @"limit";
NSString *const kYelpSortKey = @"sort";
NSString *const kYelpQueryLimit = @"20";
NSString *const kYelpSortType = @"0";
NSString *const kYelpTermKey = @"term";

