//
//  NetworkErrorAlert.m
//  TSApp
//
//  Created by Rich Fellure on 10/6/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "NetworkErrorAlert.h"

@implementation NetworkErrorAlert

+(void)showNetworkAlertWithError:(NSError *)error withViewController:(UIViewController *)viewController
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry there was an error with the Network" message:error.localizedDescription delegate:viewController cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [viewController.view addSubview:alertView];
    [alertView show];
}

@end
