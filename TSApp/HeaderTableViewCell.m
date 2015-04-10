//
//  HeaderTableViewCell.m
//  TSApp
//
//  Created by Rich Fellure on 12/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "HeaderTableViewCell.h"

@implementation HeaderTableViewCell

-(void)awakeFromNib {
    self.backgroundColor = [UIColor customLightGrey];
    self.headerTitleLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0];
    self.headerTitleLabel.tintColor = [UIColor whiteColor];
}

@end