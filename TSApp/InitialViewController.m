//
//  InitialViewController.m
//  TSApp
//
//  Created by Rich Fellure on 8/21/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "InitialViewController.h"
#import <Parse/Parse.h>
#import "User.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];

    if (![PFUser currentUser])
    {
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"forwardSegue" sender:self];
    }
}



@end
