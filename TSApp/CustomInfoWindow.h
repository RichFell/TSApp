//
//  CustomInfoWindowVC.h
//  TSApp
//
//  Created by Rich Fellure on 5/12/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomInfoWindow : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end
