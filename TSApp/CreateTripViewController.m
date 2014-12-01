//
//  CreateTripViewController.m
//  TSApp
//
//  Created by Rich Fellure on 11/30/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "CreateTripViewController.h"
#import "Region.h"
#import "UserDefaults.h"
#import "NetworkErrorAlert.h"

@interface CreateTripViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tripNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation CreateTripViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.saveButton.backgroundColor = [UIColor customOrange];
}

- (IBAction)saveNewRegionOnTap:(UIButton *)sender
{
    [Region createRegion:self.tripNameTextField.text compeletion:^(Region *newRegion, NSError *error) {
        if (error)
        {
            //TODO: Another error to look at
            [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
        }
        else
        {
            [UserDefaults setDefaultRegion:newRegion];
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }];
}

@end
