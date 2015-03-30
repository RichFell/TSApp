//
//  CreateTripViewController.m
//  TSApp
//
//  Created by Rich Fellure on 11/30/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "CreateTripViewController.h"
#import "UserDefaults.h"
#import "NetworkErrorAlert.h"
#import "MapModel.h"
#import "MapNavigationViewController.h"
#import "CDRegion.h"

@interface CreateTripViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tripNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation CreateTripViewController

static CGFloat const kYKeyboardOpen = -100.0;
static CGFloat const kYKeyboardClosed = 0.0;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.saveButton.backgroundColor = [UIColor customOrange];
    self.cancelButton.backgroundColor = [UIColor customOrange];
}


- (IBAction)saveNewRegionOnTap:(UIButton *)sender
{
    [MapModel geocodeString:self.destinationTextField.text withBlock:^(CLLocationCoordinate2D coordinate, NSError *error) {
        if (error)
        {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else
        {
            PFGeoPoint *gPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            [self saveRegionWithGeoPoint:gPoint];
        }
    }];
}
- (IBAction)dismissViewOnTapped:(UIButton *)sender
{
    [self dismissViewControllerAnimated:true completion:nil];
}

///Sages a new region to Parse
-(void)saveRegionWithGeoPoint: (PFGeoPoint *)geoPoint
{
    [CDRegion createNewRegionWithName:self.tripNameTextField.text andGeoPoint:geoPoint completed:^(BOOL result, CDRegion *region) {
        [UserDefaults setDefaultRegion:region];
            [self dismissViewControllerAnimated:true completion:^{
            [[self presentingViewController].navigationController popViewControllerAnimated:true];
        }];
    }];
}

-(void)animateViewWhenKeyboardOpenedToY: (CGFloat)y
{
    [UIView animateWithDuration: 0.25 animations:^{
        self.view.frame = CGRectMake(0.0, y, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

#pragma mark - TextFieldDelegate Methods

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateViewWhenKeyboardOpenedToY:kYKeyboardOpen];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateViewWhenKeyboardOpenedToY:kYKeyboardClosed];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:true];
    return true;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:true];
}

@end
