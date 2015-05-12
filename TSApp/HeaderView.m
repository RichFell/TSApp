//
//  HeaderView.m
//  TSApp
//
//  Created by Rich Fellure on 4/21/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "HeaderView.h"

@implementation HeaderView


-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor lightGrayColor];
    CGRect insetRect = CGRectMake(0, 0, CGRectGetWidth(frame), kTableViewHeaderHeight);
    self.headerLabel = [[UILabel alloc]initWithFrame:insetRect];
    self.headerLabel.textAlignment = NSTextAlignmentCenter;
    self.headerLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:15.0];
    [self addSubview:self.headerLabel];
    return self;
}


@end
