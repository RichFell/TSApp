//
//  HeaderTableViewCell.m
//  TSApp
//
//  Created by Rich Fellure on 12/7/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "HeaderTableViewCell.h"

@implementation HeaderTableViewCell

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor customLightGrey];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
