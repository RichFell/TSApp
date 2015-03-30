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
#import "DirectionTableViewCell.h"
#import "MapModel.h"
#import "CDLocation.h"

@interface LocationsListViewController ()<UITableViewDataSource, UITableViewDelegate, LocationTVCellDelegate, CLLocationManagerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet UIButton *directionsButton;
@property (weak, nonatomic) IBOutlet UIButton *transitButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *transportationButtons;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarOne;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarTwo;

@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property int destinationSelector;
@property Location *startingLocation;
@property Location *endingLocation;
@property NSArray *directionsArray;
@property BOOL wantDirections;
@property BOOL endingDestination;
@property BOOL displayDirections;
@property BOOL firstTapOnCurrentPosition;
@property NSString *typeOfTransportation;
@property NSArray *titleArray;
@property NSMutableArray *locationsArray;
@property CDRegion *currentRegion;

@end

@implementation LocationsListViewController

static NSString *const kDirectionsSegue = @"DirectionsSegue";
static NSString *const kLocationCellId = @"LocationTableViewCell";
static NSString *const kNeedToVisitString = @"Need To Visit";
static NSString *const kVisitedString = @"Visited";
static NSString *const kHeaderCellID = @"headerCell";
static NSString *const kDefaultRegion = @"defaultRegion";
static NSString *const kNewLocationNotification = @"NewLocationNotification";
static NSString *const kPlaceHolderImageName = @"PlaceHolderImage";
static NSString *const kCheckMarkImageName = @"CheckMarkImage";
static NSString *const kDirectionsCellID = @"DirectionCell";
static NSString *const kChangeLocationNotif = @"ChangeLocationNotification";
static NSString *const kDisplayPolyLineNotif = @"DisplayPolyLine";


- (void)viewDidLoad {
    [super viewDidLoad];

    self.endingDestination = false;
    self.displayDirections = false;
    self.firstTapOnCurrentPosition = true;
    self.typeOfTransportation = @"driving";
    self.destinationSelector = 0;
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    self.wantDirections = false;
    self.searchBarOne.text = @"Current Location";
    self.titleArray = @[kNeedToVisitString, kVisitedString];
    self.view.backgroundColor = [UIColor customTableViewBackgroundGrey];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self reduceDirectionsViewInViewDidLoad];
}

-(void)giveCurrentRegion:(CDRegion *)region {
    self.currentRegion = region;
    [self.tableView reloadData];
}
#pragma mark - helper methods


///Removes the deleted destination(Location) from the correct array after a successful delete
-(void)onSuccessfulDeleteAtIndexPath:(NSIndexPath *)indexPath ofLocation:(Location *)location {
    [self.locationsArray[indexPath.row] removeObject:location];
    [self.delegate didDeleteLocation:location];
}

///Returns the correct cell we want to display whether we want to show directions, or to show the destinations
-(UITableViewCell *)returnCorrectCellforIndexpath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView
{
    if (self.displayDirections) {
        DirectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDirectionsCellID];
        Direction *direction = self.directionsArray[indexPath.row];
        cell.directionLabel.text = direction.step;
        cell.posLabel.text = [NSString stringWithFormat:@"%li", (long)indexPath.row + 1];
        cell.disLabel.text = direction.distance;
        cell.durLabel.text = direction.duration;
        return cell;
    }
    else {
        LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLocationCellId];
        CDLocation *location = self.currentRegion.sortedArrayOfLocations[indexPath.section][indexPath.row];

        cell.infoLabel.text = location.name;
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.addressLabel.text = location.localAddress ? location.localAddress : @"No Address";
        cell.visitedButton.imageView.image =  location.hasVisited == false ? [UIImage imageNamed:kCheckMarkImageName] : [UIImage imageNamed:kPlaceHolderImageName];
        int position = (int)indexPath.row;
        cell.countLabel.text = [NSString stringWithFormat:@"%d", position + 1];
        return cell;
    }
}

///does the call for directions between the startingCoordinate and the endingCoordinate
-(void)askForDirections {
    CLLocationCoordinate2D startingCoordinate = CLLocationCoordinate2DMake(self.startingLocation.coordinate.latitude, self.startingLocation.coordinate.longitude);
    CLLocationCoordinate2D endingCoordinate = CLLocationCoordinate2DMake(self.endingLocation.coordinate.latitude, self.endingLocation.coordinate.longitude);
    NSString *directionType = self.typeOfTransportation != nil ? self.typeOfTransportation : @"driving";
    [Direction getDirectionsWithCoordinate:startingCoordinate andEndingPosition:endingCoordinate withTypeOfTransportation:directionType andBlock:^(NSArray *directionArray, NSError *error) {
        if (error) {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else {
            self.directionsArray = [NSArray arrayWithArray:directionArray];
            [self.delegate didGetNewDirections:self.directionsArray];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource Delegate Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self returnCorrectCellforIndexpath:indexPath forTableView:tableView];
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHeaderCellID];
    cell.headerTitleLabel.text = self.titleArray[section];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.displayDirections ? 0.0 : 40.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.displayDirections ? 1 : self.titleArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.currentRegion.sortedArrayOfLocations[section];
    return self.displayDirections ? self.directionsArray.count : array.count;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: Need to update to delete from Arrays within the dictionary
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *locations = self.locationsArray[indexPath.section];
        Location *location = locations[indexPath.section][indexPath.row];
        [location deleteLocationWithBlock:locations completed:^(BOOL result, NSError *error) {

            if (error) {
                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
            }
            else {
                [self onSuccessfulDeleteAtIndexPath:indexPath ofLocation:location];
            }
        }];
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return true;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (self.wantDirections) {
        if (self.destinationSelector == 0) {
            self.endingLocation = self.locationsArray[indexPath.section][indexPath.row];
            self.searchBarTwo.text = self.endingLocation.address;
            cell.backgroundColor = [UIColor blueColor];
            self.directionsButton.enabled = true;
        }
        else {
            self.startingLocation = self.locationsArray[indexPath.row];
            self.searchBarOne.text = @"Current Location";
            cell.backgroundColor = [UIColor greenColor];
        }
    }
}

#pragma mark - LocationTableViewCellDelegate method
-(void)didTapVisitedButtonAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: update for the dictionary
    Location *location = self.locationsArray[indexPath.section][indexPath.row];
    [location changeVisitedStatusWithBlock:^(BOOL result, NSError *error) {
        if (error) {
            [NetworkErrorAlert showAlertForViewController:self];
        }
        else {
            [self moveLocation:location FromSection:indexPath.section];
            [self.delegate didMoveLocation:location];
        }
    }];
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

- (IBAction)switchTableViewDisplayOnTapped:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.displayDirections = false;
    }
    else {
        self.displayDirections = true;
    }
    [self.tableView reloadData];
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


#pragma mark - Methods for movement of directionsView
-(void)reduceDirectionsViewInViewDidLoad {
    self.goButtonWidthConstraint.constant = 0.0;
    self.topViewHeightConstraint.constant = self.searchBarOne.frame.size.height + 20;
    self.searchBarTwo.hidden = true;
}

//Expands directions View to display the full view and button animated
-(void)expandDirectionsView {
    if (self.wantDirections == false) {
        [UIView animateWithDuration:0.3 animations:^{
            self.goButtonWidthConstraint.constant = 40.0;
            self.topViewHeightConstraint.constant = self.searchBarOne.frame.size.height + self.searchBarTwo.frame.size.height + self.transitButton.frame.size.height + 60;
            [self.searchBarOne resignFirstResponder];
            self.searchBarOne.userInteractionEnabled = false;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.searchBarTwo.hidden = false;
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


//#pragma mark - method for moving position of locations
-(void)moveLocation:(Location *)location FromSection:(NSInteger)section {

    if (section == 0) {
        [self.locationsArray[0]removeObject:location];
        [self.locationsArray[1] addObject:location];
    }
    else {
        [self.locationsArray[1] removeObject:location];
        [self.locationsArray[0] addObject:location];
    }
    [self.tableView reloadData];
}

#pragma mark - searchBarDelegate Methods
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if ([searchBar isEqual:self.searchBarOne] && self.firstTapOnCurrentPosition == true) {
        Location *location = [Location new];
        location.coordinate = [PFGeoPoint geoPointWithLocation:self.currentLocation];
        self.startingLocation = location;
        [self expandDirectionsView];
    }
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"Did change Text");
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [MapModel geocodeString:searchBar.text withBlock:^(CLLocationCoordinate2D coordinate, NSError *error) {
        if (error) {
            [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
        }
        else {
            [self askToSaveLocationAlert:coordinate atAddress:searchBar.text];
            Location *location = [Location new];
            location.coordinate = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            location.address = searchBar.text;
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

-(void)askToSaveLocationAlert:(CLLocationCoordinate2D)coordinate atAddress:(NSString *)address {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Would you like to save this to your location list?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self saveLocationAlertForCoordinate:coordinate andAddress:address];
    }];
    [alertController addAction:yesAction];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:noAction];
    [self presentViewController:alertController animated:true completion:nil];
}

-(void)saveLocationAlertForCoordinate:(CLLocationCoordinate2D)coordinate andAddress:(NSString *)address {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Give the Location a name" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Add name here";
    }];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields[0];
        [CDLocation createNewLocationWithName:textField.text atCoordinate:coordinate atIndex:[NSNumber numberWithInteger:self.currentRegion.allLocations.count] forRegion:self.currentRegion atAddress:address completion:^(CDLocation *location, BOOL result) {

        }];
    }];
    [alertController addAction:saveAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction: cancelAction];
    [self presentViewController:alertController animated:true completion:nil];
}


@end
