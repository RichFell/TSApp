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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry there was an error with the network" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [viewController presentViewController:alertController animated:true completion:nil];
}

+(void)showErrorWithTitle:(NSString *)theTitle withMessage:(NSString *)theMessage forViewController:(UIViewController *)vc
{
    UIAlertController *alertController =[UIAlertController alertControllerWithTitle:theTitle message:theMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [vc presentViewController:alertController animated:true completion:nil];
}

@end
