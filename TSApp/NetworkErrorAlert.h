//
//  NetworkErrorAlert.h
//  TSApp
//
//  Created by Rich Fellure on 10/6/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkErrorAlert : NSObject

+(void)showNetworkAlertWithError: (NSError *)error withViewController: (UIViewController *)viewController;

@end
