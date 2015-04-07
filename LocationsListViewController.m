//
//  LocationsListViewController.m
//  TSApp
//
//  Created by Rich Fellure on 8/10/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "LocationsListViewController.h"
#import "LocationTableViewCell.h"
#import "NetworkErrorAlert.h"
#import "UserDefaults.h"
#import "HeaderTableViewCell.h"
#import "Direction.h"
#import <CoreLocation/CoreLocation.h>
#import "MapModel.h"
#import "CDLocation.h"
#import "DirectionsViewController.h"
#import "DirectionsListViewController.h"
#import "DirectionSet.h"

@interface LocationsListViewController ()<UITableViewDataSource, UITableViewDelegate, LocationTVCellDelegate, CLLocationManagerDelegate, UISearchBarDelegate>

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goButtonWidthConstraint;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *transportationButtons;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarOne;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarTwo;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *slidingImageView;

#pragma mark - Variables
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property CDLocation *startingLocation;
@property CDLocation *endingLocation;
@property BOOL wantDirections;
@property BOOL displayDirections;
@property BOOL firstTapOnCurrentPosition;
@property BOOL selectFirstPostion;
@property NSString *typeOfTransportation;
@property NSArray *titleArray;
@property CGFloat startingContainerBottomConstant;
@property CGFloat startingImageViewConstant;
@property DirectionsViewController *directionsVC;

@end

@implementation LocationsListViewController

#pragma mark - Constants

static NSString *const kLocationCellId = @"LocationTableViewCell";
static NSString *const kHeaderCellID = @"headerCell";
static NSString *const kDirectionsCellID = @"DirectionCell";
static NSString *const kCheckMarkImageName = @"CheckMarkImage";
static NSString *const kDirectionSegue = @"DirectionSegue";


#pragma mark - View LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.displayDirections = false;
    self.firstTapOnCurrentPosition = true;
    self.typeOfTransportation = @"driving";
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    self.wantDirections = false;
    self.searchBarOne.text = @"Current Location";
    self.titleArray = @[kNeedToVisitString, kVisitedString];
    self.view.backgroundColor = [UIColor customTableViewBackgroundGrey];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self reduceDirectionsViewInViewDidLoad];
    self.segmentedControl.selectedSegmentIndex = 1;
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
    self.imageViewTopConstraint.constant = self.view.frame.size.height - self.slidingImageView.frame.size.height;
    self.containerViewBottomConstraint.constant = -self.view.frame.size.height + self.slidingImageView.frame.size.height;
    self.startingContainerBottomConstant = self.containerViewBottomConstraint.constant;
    self.startingImageViewConstant = self.imageViewTopConstraint.constant;
    self.slidingImageView.image = [UIImage imageNamed:kUpArrowImage];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[DirectionsViewController class]]) {
        self.directionsVC = segue.destinationViewController;
    }
    else if ([segue.destinationViewController isKindOfClass:[DirectionsListViewController class]]) {
        DirectionsListViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        vc.selectedLocation = self.currentRegion.sortedArrayOfLocations[indexPath.section][indexPath.row];
    }
}
#pragma mark - helper methods

///does the call for directions between the startingCoordinate and the endingCoordinate
-(void)askForDirections {
    NSString *directionType = self.typeOfTransportation != nil ? self.typeOfTransportation : @"driving";
    [Direction getDirectionsWithCoordinate:self.startingLocation.coordinate andEndingPosition:self.endingLocation.coordinate withTypeOfTransportation:directionType andBlock:^(NSArray *directionArray, NSError *error) {
        if (directionArray != nil) {
            [self alertToSaveDirectionSetWithDirections:directionArray];
            [self.delegate didGetNewDirections:directionArray];
            [self.directionsVC displayDirections:directionArray];
        }
        else {
            [NetworkErrorAlert showAlertForViewController:self];
        }
    }];
}

#pragma mark - Helper Methods for sliding of the container view

-(void)animateContainerUp {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.containerViewBottomConstraint.constant = 0;
        self.imageViewTopConstraint.constant = kImageViewConstraintConstantOpen;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.slidingImageView.image = [UIImage imageNamed:kDownArrowImage];
    }];
}

-(void)animateContainerDown {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.containerViewBottomConstraint.constant = -self.view.frame.size.height + self.slidingImageView.frame.size.height;
        self.imageViewTopConstraint.constant = self.view.frame.size.height - self.slidingImageView.frame.size.height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.slidingImageView.image = [UIImage imageNamed:kUpArrowImage];
    }];
}

#pragma mark - UITableViewDataSource Delegate Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLocationCellId];
    CDLocation *location = self.currentRegion.sortedArrayOfLocations[indexPath.section][indexPath.row];
    if (location == self.startingLocation) {
        cell.backgroundColor = [UIColor greenColor];
    }
    else if (location == self.endingLocation) {
        cell.backgroundColor = [UIColor blueColor];
    }
    else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.infoLabel.text = location.name;
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.addressLabel.text = location.localAddress ? location.localAddress : @"No Address";
    cell.visitedButton.imageView.image =  location.hasVisited == false ? [UIImage imageNamed:kCheckMarkImageName] : [UIImage imageNamed:kPlaceHolderImage];
    int position = (int)indexPath.row;
    cell.countLabel.text = [NSString stringWithFormat:@"%d", position + 1];
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHeaderCellID];
    cell.headerTitleLabel.text = self.titleArray[section];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.titleArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.currentRegion.sortedArrayOfLocations[section];
    return array.count;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CDLocation *location = self.currentRegion.sortedArrayOfLocations[indexPath.section][indexPath.row];
        [self.currentRegion removeLocationFromLocations:location completed:^(BOOL result) {
            [self.tableView reloadData];
        }];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.displayDirections) {
        return false;
    }
    else {
        return true;
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return false;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CDLocation *selectedLocation = self.currentRegion.sortedArrayOfLocations[indexPath.section][indexPath.row];

    if (self.wantDirections) {
        if (!self.selectFirstPostion) {
            self.endingLocation = selectedLocation;
            self.searchBarTwo.text = self.endingLocation.localAddress;
            cell.backgroundColor = [UIColor blueColor];
        }
        else {
            self.startingLocation = selectedLocation;
            self.searchBarOne.text = self.startingLocation.localAddress;
            cell.backgroundColor = [UIColor greenColor];
        }
    }
    else {
        [self performSegueWithIdentifier:kDirectionSegue sender:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

#pragma mark - LocationTableViewCellDelegate method
-(void)didTapVisitedButtonAtIndexPath:(NSIndexPath *)indexPath
{
    CDLocation *location = self.currentRegion.sortedArrayOfLocations[indexPath.section][indexPath.row];
    location.hasVisited = !location.hasVisited;
    [self.tableView reloadData];
    [self.delegate locationListVC:self didChangeLocation:location];
}

#pragma mark - LocationManagerDelegate methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            self.currentLocation = location;
            [self.locationManager stopUpdatingLocation];
        }
    }
}

#pragma mark - IBActions
- (IBAction)getDirectionsOnTapped:(UIButton *)sender {
    [self askForDirections];
}

- (IBAction)flipBackToMapOnTap:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
    }

}

- (IBAction)switchModeOnTransOnTapped:(UIButton *)sender {
    for (UIButton *button in self.transportationButtons) {
        [button setHighlighted: false];
    }
    switch (sender.tag) {
        case 0:
            //Selected to use Transit
            self.typeOfTransportation = @"transit";
            break;
        case 1:
            //Selected to Drive
            self.typeOfTransportation = @"driving";
            break;
        case 2:
            //Selected to Walk
            self.typeOfTransportation = @"walking";
            break;
        case 3:
            //Selected to Bike
            self.typeOfTransportation = @"bicycling";
            break;
        default:
            break;
    }
    [sender setHighlighted:true];
    for (UIButton * button in self.transportationButtons) {
        button.backgroundColor = button.highlighted == true ? [UIColor orangeColor] : [UIColor clearColor];
    }
}

- (IBAction)arrowTapped:(UITapGestureRecognizer *)sender {
    if ([sender locationInView:self.view].y > self.view.frame.size.height / 2) {
        [self animateContainerUp];
    }
    else {
        [self animateContainerDown];
    }
}

#pragma mark - Methods for movement of directionsView
-(void)reduceDirectionsViewInViewDidLoad {
    self.goButtonWidthConstraint.constant = 0.0;
    self.topViewHeightConstraint.constant = self.searchBarOne.frame.size.height + 20;
    self.searchBarTwo.hidden = true;
    for (UIButton *button in self.transportationButtons) {
        button.hidden = true;
    }
}

//Expands directions View to display the full view and button animated
-(void)expandDirectionsView {
    if (self.wantDirections == false) {
        [UIView animateWithDuration:0.3 animations:^{
            self.goButtonWidthConstraint.constant = 40.0;
            UIButton *button = self.transportationButtons[0];
            CGFloat buttonHeight = button.frame.size.height;
            self.topViewHeightConstraint.constant = self.searchBarOne.frame.size.height + self.searchBarTwo.frame.size.height + buttonHeight + 20.0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.searchBarTwo.hidden = false;
            [self.view endEditing:true];
            for (UIButton *button in self.transportationButtons) {
                button.hidden = false;
            }
        }];
        self.wantDirections = true;
    }
    else {
        self.wantDirections = false;
        [UIView animateWithDuration:0.3 animations:^{
            [self reduceDirectionsViewInViewDidLoad];
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - searchBarDelegate Methods
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if ([searchBar isEqual:self.searchBarOne]) {
        if (self.firstTapOnCurrentPosition == true) {
            CDLocation *location = [[CDLocation alloc]initWithDefault:self.currentLocation.coordinate];
            self.startingLocation = location;
            self.firstTapOnCurrentPosition = !self.firstTapOnCurrentPosition;
            [self expandDirectionsView];
        }
        else {
            self.selectFirstPostion = true;
        }
    }
    else {
        self.selectFirstPostion = false;
    }
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [MapModel geocodeString:searchBar.text withBlock:^(CLLocationCoordinate2D coordinate, NSError *error) {
        if (error) {
            [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
        }
        else {

            NSArray *array = self.currentRegion.sortedArrayOfLocations[0];
            NSNumber *index = [NSNumber numberWithLong:array.count];
            CDLocation *location = [[CDLocation alloc]initWithCoordinate:coordinate andName:@"" atIndex:index forRegion:self.currentRegion atAddress:searchBar.text];
            [self askToSaveLocationAlert:location];
            if ([searchBar isEqual:self.searchBarOne]) {
                self.startingLocation = location;
            }
            else {
                self.endingLocation = location;
            }
            [self askForDirections];
        }
    }];
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
    }];
    [alert addAction:yesAction];
    [self presentViewController:alert animated:true completion:nil];
}

@end
