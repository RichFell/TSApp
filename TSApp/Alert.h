//
//  NetworkErrorAlert.h
//  TSApp
//
//  Created by Rich Fellure on 10/6/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Alert : NSObject

+(void)showNetworkAlertWithError: (NSError *)error withViewController: (UIViewController *)viewController;
+(void)showAlertForViewController: (UIViewController *)vc;
+(void)showAlertForViewController:(UIViewController *)vc withTitle:(NSString *)title andMessage:(NSString *)message;

@end
