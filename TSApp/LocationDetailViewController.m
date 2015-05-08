//
//  LocationDetailViewController.m
//  TSApp
//
//  Created by Rich Fellure on 5/1/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "LocationDetailViewController.h"
#import "CDLocation.h"
#import "GetDirectionsViewController.h"
#import "DirectionsListViewController.h"

@class TSButton;

@interface LocationDetailViewController ()<DirectionsListVCDelegate>

#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *directionContainerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getDirectionsButTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *directionContainerBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *findDirectionsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *getDirectionsButton;
@property (weak, nonatomic) IBOutlet UIButton *saveDirectionsButton;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;


@end

@implementation LocationDetailViewController
#pragma mark - Local Variables
{
    CGFloat kOpenDirectionContainerTopConstraintConst;
    CGFloat kOpenDirectionContainerBottomContraintConst;
    CGFloat kStartingGetDirectionsButtonTopConstraintCons;
}

#pragma mark - View LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];

    kOpenDirectionContainerTopConstraintConst = self.directionContainerTopConstraint.constant;
    kOpenDirectionContainerBottomContraintConst = self.directionContainerBottomConstraint.constant;
    kStartingGetDirectionsButtonTopConstraintCons = self.getDirectionsButTopConstraint.constant;
    self.title = self.selectedLocation.name;
    self.addressLabel.text = self.selectedLocation.localAddress;
    [self displayDirectionsSearch:false withAnimation:false];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[GetDirectionsViewController class]]) {
        GetDirectionsViewController *getVC = segue.destinationViewController;
        getVC.currentLocation = self.selectedLocation;
    }
}

#pragma mark - Actions
- (IBAction)directionButtonTap:(UIButton *)sender {
    if (sender.tag == 0) {
        [self displayDirectionsSearch:true withAnimation:true];
        sender.tag = 1;
    } else {
        sender.tag = 0;
        [self displayDirectionsSearch:false withAnimation:true];
    }
}

- (IBAction)displaySavedDirectionsOnTap:(UIButton *)sender {
    [self showSavedDirections];
}

-(void)showSavedDirections {
    DirectionsListViewController *directionsVC = [DirectionsListViewController storyboardInstance];
    directionsVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame),
                                         CGRectGetWidth(self.view.frame),
                                         CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame));
    [self.view addSubview:directionsVC.view];
    [self addChildViewController:directionsVC];
    directionsVC.delegate = self;

    [UIView animateWithDuration:0.5 animations:^{
        directionsVC.view.frame = CGRectMake(0,
                                             CGRectGetMaxY(self.navigationController.navigationBar.frame),
                                             CGRectGetWidth(self.view.frame),
                                             CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame));
    }];
}

#pragma mark - Animation Helpers
-(void)displayDirectionsSearch:(BOOL)isDisplayed withAnimation:(BOOL)isAnimated{
    if (isAnimated) {
        [UIView animateWithDuration:0.5 animations:^{
            [self setConstraintsForDirectionsContainerOpen:isDisplayed ? true : false];
            [self.view layoutIfNeeded];

        } completion:^(BOOL finished) {
            if (finished) {
                [self.getDirectionsButton setTitle:isDisplayed ? @"Close" : @"Get Directions" forState:UIControlStateNormal];
            }
        }];
    }
    else {
        [self setConstraintsForDirectionsContainerOpen:isDisplayed ? true : false];
    }

    self.saveDirectionsButton.hidden = isDisplayed ? true : false;
}

-(void)animateClosedDirectionList:(DirectionsListViewController *)directionVC {
    [UIView animateWithDuration:0.5 animations:^{
        directionVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(directionVC.view.frame));
    } completion:^(BOOL finished) {
        if (finished) {
            [directionVC.view removeFromSuperview];
            [directionVC removeFromParentViewController];
        }
    }];
}

-(void)setConstraintsForDirectionsContainerOpen:(BOOL)isDisplayed {
    self.getDirectionsButTopConstraint.constant = !isDisplayed ? kStartingGetDirectionsButtonTopConstraintCons : CGRectGetHeight(self.findDirectionsContainerView.frame);
    self.directionContainerTopConstraint.constant = isDisplayed ? kOpenDirectionContainerTopConstraintConst: CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(self.addressLabel.frame);
    self.directionContainerBottomConstraint.constant = kOpenDirectionContainerBottomContraintConst;
}

#pragma DirectionListVCDelegate

-(void)directionListVC:(DirectionsListViewController *)viewController finishedSelection:(DirectionSet *)set {
    [self animateClosedDirectionList:viewController];
}


@end
