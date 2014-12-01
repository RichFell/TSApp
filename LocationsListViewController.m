//
//  LocationsListViewController.m
//  TSApp
//
//  Created by Rich Fellure on 8/10/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "LocationsListViewController.h"
#import "LocationTableViewCell.h"
#import "MapModel.h"
#import "DirectionsViewController.h"
#import "NetworkErrorAlert.h"


@interface LocationsListViewController ()<UITableViewDataSource, UITableViewDelegate,MapModelDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIButton *setDestinationsButton;
@property (weak, nonatomic) IBOutlet UIButton *callDirectionsButton;

@property UIView *locationsView;
@property UITextField *locationOneTextField;
@property UITextField *locationTwoTextField;
@property UIButton *produceDirectionsButton;

@property MapModel *mapModel;
@property int destinationSelector;
@property Location *startingLocation;
@property Location *endingLocation;
@property NSArray *directionsArray;

@end

@implementation LocationsListViewController

static NSString *const kDirectionsSegue = @"DirectionsSegue";
static NSString *const kLocationCellId = @"LocationTableViewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.setDestinationsButton.tag = 0;
    self.destinationSelector = 0;

    self.mapModel = [[MapModel alloc]init];
    self.mapModel.delegate = self;

    self.callDirectionsButton.enabled = false;

    self.view.backgroundColor = [UIColor customTableViewBackgroundGrey];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.setDestinationsButton.backgroundColor = [UIColor customOrange];
    self.callDirectionsButton.backgroundColor = [UIColor customOrange];
    [self.setDestinationsButton setTintColor:[UIColor darkGrayColor]];
}

#pragma mark - UITableViewDataSource Delegate Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLocationCellId];

    Location *location = [self.locations objectAtIndex:indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    cell.button.tag = 0;

    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", location.index];

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locations.count;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Location *location = [self.locations objectAtIndex:indexPath.row];
        [location deleteLocationWithBlock:self.locations completed:^(BOOL result, NSError *error) {

            if (error == nil)
            {
                [self.locations removeObject:location];
                [self.tableView reloadData];
            }
            else
            {
                //TODO: Here is an error presentation for us to evaluate
                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
            }
        }];
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{

    Location *location = [self.locations objectAtIndex:sourceIndexPath.row];
    [self.locations removeObject: location];
    [self.locations insertObject:location atIndex:destinationIndexPath.row];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (self.setDestinationsButton.tag == 1)
    {
        if (self.destinationSelector == 0)
        {
            self.destinationSelector = 1;
            self.startingLocation = [self.locations objectAtIndex:indexPath.row];

            cell.backgroundColor = [UIColor blueColor];
        }
        else
        {
            self.destinationSelector = 0;
            self.endingLocation = [self.locations objectAtIndex:indexPath.row];

            cell.backgroundColor = [UIColor greenColor];

            self.callDirectionsButton.enabled = true;
        }
    }
}

#pragma mark - ParseModelDataSource methods

-(void)didMoveLocationsIndex
{
    [self.tableView reloadData];
}

#pragma mark = MapModelDelegate

-(void)didGetDirections:(NSArray *)directionArray
{
    self.directionsArray = [NSArray arrayWithArray:directionArray];

    [self performSegueWithIdentifier:kDirectionsSegue sender:self];
}

#pragma mark - IBActions


- (IBAction)onPressedEnterEditingMode:(UIBarButtonItem *)sender
{
    if (sender.tag == 0)
    {
        self.tableView.editing = YES;
        sender.tag = 1;
    }
    else
    {
        self.tableView.editing = NO;
        sender.tag = 0;
    }
}
- (IBAction)onPressedChangeVisitedImage:(UIButton *)sender
{

    //TODO: This should be handled by the cell using a protocol. This way is very hackish, and should be avoided at any time

    
//    UIButton *button = (UIButton *)sender;
//
//    LocationTableViewCell *cell = (LocationTableViewCell *)[[sender superview]superview];
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    Location *selectedLocation = [self.locations objectAtIndex:indexPath.row];
//
//    if (button.tag == 0)
//    {
//        [button setImage: [UIImage imageNamed:@"placemarker_Image"] forState:UIControlStateNormal];
//        [selectedLocation changeVisitedStatusWithBlock:^(BOOL result, NSError *error) {
//            if (error != nil)
//            {
//                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
//            }
//        }];
//        button.tag = 1;
//    }
//    else
//    {
//        [button setImage:[UIImage imageNamed:@"UserLocation_Image"] forState:UIControlStateNormal];
//        [selectedLocation changeVisitedStatusWithBlock:^(BOOL result, NSError *error) {
//            if (error != nil)
//            {
//                [NetworkErrorAlert showNetworkAlertWithError:error withViewController:self];
//            }
//        }];
//        button.tag = 0;
//    }
}

- (IBAction)onPressedSetDestinations:(UIButton *)sender
{
    if (sender.tag == 0)
    {
        sender.tag = 1;
        [sender setBackgroundColor:[UIColor orangeColor]];
    }
    else
    {
        sender.tag = 0;
        [sender setBackgroundColor:[UIColor clearColor]];
    }
}

- (IBAction)receiveDirections:(UIButton *)sender
{
    if (self.startingLocation != nil && self.endingLocation != nil)
    {
        CLLocationCoordinate2D startingCoordinate = CLLocationCoordinate2DMake(self.startingLocation.coordinate.latitude, self.startingLocation.coordinate.longitude);
        CLLocationCoordinate2D endingCoordinate = CLLocationCoordinate2DMake(self.endingLocation.coordinate.latitude, self.endingLocation.coordinate.longitude);

        [self.mapModel getDirections: startingCoordinate endingPosition:endingCoordinate];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DirectionsViewController *directionVC = segue.destinationViewController;
    directionVC.directions = [NSArray arrayWithArray:self.directionsArray];
}


@end
