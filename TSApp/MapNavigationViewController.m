//
//  MapNavigationViewController.m
//  TSApp
//
//  Created by Rich Fellure on 12/8/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "MapNavigationViewController.h"
#import <Parse/Parse.h>
#import "EntryViewController.h"

@interface MapNavigationViewController ()

@end

@implementation MapNavigationViewController

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
    if (![PFUser currentUser]) {
        EntryViewController *entryVC = [EntryViewController newStoryboardInstance];
        [self presentViewController:entryVC animated:true completion:nil];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:kFirstLoginKey];
    }
}

+(MapNavigationViewController *)storyboardInstanceOfMapNavVC
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName: @"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"MapNavigationViewController"];
}

@end
