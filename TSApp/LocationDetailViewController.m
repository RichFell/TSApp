//
//  LocationDetailViewController.m
//  TSApp
//
//  Created by Rich Fellure on 5/1/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "LocationDetailViewController.h"
#import "CDLocation.h"

@class TSButton;

@interface LocationDetailViewController ()

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

#pragma mark - Actions
- (IBAction)directionButtonTap:(UIButton *)sender {
    [self displayDirectionsSearch:true withAnimation:true];
}

- (IBAction)displaySavedDirectionsOnTap:(UIButton *)sender {


}

#pragma mark - Animation Helpers
-(void)displayDirectionsSearch:(BOOL)isDisplayed withAnimation:(BOOL)isAnimated{
    if (isAnimated) {
        [UIView animateWithDuration:0.5 animations:^{
            [self setConstraintsForDirectionsContainerOpen:isDisplayed ? true : false];
            [self.view layoutIfNeeded];
        }];
    }
    else {
        [self setConstraintsForDirectionsContainerOpen:isDisplayed ? true : false];
    }

    self.saveDirectionsButton.hidden = isDisplayed ? true : false;
}

-(void)setConstraintsForDirectionsContainerOpen:(BOOL)isDisplayed {
    self.getDirectionsButTopConstraint.constant = !isDisplayed ? kStartingGetDirectionsButtonTopConstraintCons : CGRectGetHeight(self.findDirectionsContainerView.frame);
    self.directionContainerTopConstraint.constant = isDisplayed ? kOpenDirectionContainerTopConstraintConst: CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(self.addressLabel.frame);
    self.directionContainerBottomConstraint.constant = kOpenDirectionContainerBottomContraintConst;
}




@end
