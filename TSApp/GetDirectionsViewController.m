//
//  LocationSelectionViewController.m
//  TSApp
//
//  Created by Rich Fellure on 4/7/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "GetDirectionsViewController.h"
#import "CDLocation.h"
#import "MapModel.h"
#import "NetworkErrorAlert.h"
#import "Direction.h"
#import "DirectionSet.h"
#import "TSButton.h"
#import "CDRegion.h"
#import "YPBusiness.h"


@interface GetDirectionsViewController ()<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *transportationButtons;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;
@property (strong, nonatomic) IBOutletCollection(TSButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property CDLocation *endingLocation;
@property YPBusiness *endingBusiness;
@property (nonatomic)NSArray *locations;

@end

@implementation GetDirectionsViewController

static NSString *typeOfTransportation = @"driving";

-(void)setLocations:(NSArray *)locations {
    _locations = locations;
    [self.tableView reloadData];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    UniversalRegion *sharedRegion = [UniversalRegion sharedInstance];
    UniversalBusiness *sharedBusiness = [UniversalBusiness sharedInstance];
    NSMutableArray *array = [NSMutableArray arrayWithArray:sharedRegion.currentRegion.allLocations];
    [array addObjectsFromArray:sharedBusiness.currentBusinesses];
    self.locations = array;
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}
#pragma Helper Methods 
///does the call for directions between the startingCoordinate and the endingCoordinate
-(void)askForDirections {
    [Direction getDirectionsWithCoordinate:self.currentLocation.coordinate
                         andEndingPosition:self.endingLocation ? self.endingLocation.coordinate : self.endingBusiness.coordinate
                  withTypeOfTransportation:typeOfTransportation
                                  andBlock:^(NSArray *directionArray, NSError *error) {
        if (directionArray != nil) {
            [self alertToSaveDirectionSetWithDirections:directionArray];
            [self postNotificationForDirections:directionArray];
        }
        else if (error) {
            [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
        }
        else {
            [NetworkErrorAlert showAlertForViewController:self];
            NSLog(@"direction Array nil");
        }
    }];
}

-(void)postNotificationForDirections:(NSArray *)directions {
    NSDictionary *info = @{kDirectionArrayKey: directions};
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedDirectionNotification object:nil userInfo:info];
}

#pragma mark - searchBarDelegate Methods

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return true;
}

-(void)alertToSaveDirectionSetWithDirections:(NSArray *)directions {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Would you like to save these directions?" message:@"You can save these directions for later use, and be able to view them at anytime." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:noAction];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [DirectionSet createNewDirectionSetWithDirections:directions andStartingLocation:self.currentLocation andEndingLocation:self.endingLocation];
        [self.parentViewController.presentingViewController dismissViewControllerAnimated:true completion:nil];
    }];
    [alert addAction:yesAction];
    [self.parentViewController presentViewController:alert animated:true completion:nil];
}

#pragma mark -TableViewDataSource/Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    NSString *titleString;
    NSString *subTitleString;
    if ([self.locations[indexPath.row] isKindOfClass:[CDLocation class]]) {
        CDLocation *location = self.locations[indexPath.row];
        titleString = location.name;
        subTitleString = location.localAddress;
    }
    else if ([self.locations[indexPath.row] isKindOfClass:[YPBusiness class]]) {
        YPBusiness *biz = self.locations[indexPath.row];
        titleString = biz.name;
        subTitleString = biz.address;
    }
    cell.textLabel.text = titleString;
    cell.detailTextLabel.text = subTitleString;
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locations.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *textFieldText;
    if ([self.locations[indexPath.row] isKindOfClass:[CDLocation class]]) {
        CDLocation *loc = self.locations[indexPath.row];
        self.endingLocation = loc;
        textFieldText = loc.name;
        self.endingBusiness = nil;
    }
    else if ([self.locations[indexPath.row] isKindOfClass:[YPBusiness class]]) {
        YPBusiness *biz = self.locations[indexPath.row];
        self.endingBusiness = biz;
        textFieldText = biz.name;
        self.endingLocation = nil;
    }
    self.toTextField.text = textFieldText;
}

#pragma mark - Save Alerts
//-(void)askToSaveLocationAlert:(CDLocation *)location {
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Would you like to save this to your location list?" message:nil preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [self saveLocationAlertForLocation:location];
//    }];
//    [alertController addAction:yesAction];
//    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
//    [alertController addAction:noAction];
//    [self presentViewController:alertController animated:true completion:nil];
//}

//-(void)saveLocationAlertForLocation:(CDLocation *)location {
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Give the Location a name" message:nil preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//        textField.placeholder = @"Add name here";
//    }];
//    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        UITextField *textField = alertController.textFields[0];
//        location.name = textField.text;
//        [location saveLocation];
//    }];
//    [alertController addAction:saveAction];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
//    [alertController addAction: cancelAction];
//    [self presentViewController:alertController animated:true completion:nil];
//}

@end
