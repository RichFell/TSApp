//
//  LocationSelectionViewController.m
//  TSApp
//
//  Created by Rich Fellure on 4/7/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "LocationSelectionViewController.h"
#import "CDLocation.h"
#import "MapModel.h"
#import "NetworkErrorAlert.h"
#import "Direction.h"
#import "DirectionSet.h"

@interface LocationSelectionViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *transportationButtons;
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;

@property CDLocation *startingLocation;
@property CDLocation *endingLocation;

@end

@implementation LocationSelectionViewController

static NSString *typeOfTransportation = @"driving";


#pragma mark - Public Instance Methods
-(void)giveALocation:(CDLocation *)location {
    if (self.selectFirstPosition) {
        self.startingLocation = location;
        [self.fromTextField resignFirstResponder];
        self.fromTextField.text = self.startingLocation.localAddress;
    }
    else {
        [self.toTextField resignFirstResponder];
        self.endingLocation = location;
        self.toTextField.text = self.endingLocation.localAddress;
    }
}

#pragma mark - Actions
- (IBAction)switchModeOnTransOnTapped:(UIButton *)sender {
    for (UIButton *button in self.transportationButtons) {
        [button setHighlighted: false];
    }
    switch (sender.tag) {
        case 0:
            //Selected to use Transit
            typeOfTransportation = @"transit";
            break;
        case 1:
            //Selected to Drive
            typeOfTransportation = @"driving";
            break;
        case 2:
            //Selected to Walk
            typeOfTransportation = @"walking";
            break;
        case 3:
            //Selected to Bike
            typeOfTransportation = @"bicycling";
            break;
        default:
            break;
    }
    [sender setHighlighted:true];
    for (UIButton * button in self.transportationButtons) {
        button.backgroundColor = button.highlighted == true ? [UIColor orangeColor] : [UIColor clearColor];
    }
}

- (IBAction)getDirectionsOnTap:(UIButton *)sender {
    [self askForDirections];
}


- (IBAction)finishedGettingDirectionsOnTap:(UIButton *)sender {
    [self.delegate locationSelectionVC:self didTapDone:true];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}
#pragma Helper Methods 
///does the call for directions between the startingCoordinate and the endingCoordinate
-(void)askForDirections {
    [Direction getDirectionsWithCoordinate:self.startingLocation.coordinate andEndingPosition:self.endingLocation.coordinate withTypeOfTransportation:typeOfTransportation andBlock:^(NSArray *directionArray, NSError *error) {
        if (directionArray != nil) {
            [self alertToSaveDirectionSetWithDirections:directionArray];
            [self postNotificationForDirections:directionArray];
        }
        else {
            [NetworkErrorAlert showAlertForViewController:self];
        }
    }];
}

-(void)postNotificationForDirections:(NSArray *)directions {
    NSDictionary *info = @{kDirectionArrayKey: directions};
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedDirectionNotification object:nil userInfo:info];
}

#pragma mark - searchBarDelegate Methods
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.fromTextField]) {
        self.selectFirstPosition = true;
    }
    else {
        self.selectFirstPosition = false;
    }
    [self.delegate locationSelectionVC:self isSettingStartingLocation:self.selectFirstPosition];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    
    return true;
}

#pragma mark - Save Alerts
-(void)askToSaveLocationAlert:(CDLocation *)location {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Would you like to save this to your location list?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self saveLocationAlertForLocation:location];
    }];
    [alertController addAction:yesAction];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:noAction];
    [self presentViewController:alertController animated:true completion:nil];
}

-(void)saveLocationAlertForLocation:(CDLocation *)location {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Give the Location a name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Add name here";
    }];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields[0];
        location.name = textField.text;
        [location saveLocation];
    }];
    [alertController addAction:saveAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction: cancelAction];
    [self presentViewController:alertController animated:true completion:nil];
}

-(void)alertToSaveDirectionSetWithDirections:(NSArray *)directions {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Would you like to save these directions?" message:@"You can save these directions for later use, and be able to view them at anytime." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:noAction];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [DirectionSet createNewDirectionSetWithDirections:directions andStartingLocation:self.startingLocation andEndingLocation:self.endingLocation];
        [self.parentViewController.presentingViewController dismissViewControllerAnimated:true completion:nil];
    }];
    [alert addAction:yesAction];
    [self.parentViewController presentViewController:alert animated:true completion:nil];
}

@end
