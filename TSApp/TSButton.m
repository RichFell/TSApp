//
//  TSButton.m
//  TSApp
//
//  Created by Rich Fellure on 4/8/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "TSButton.h"

@implementation TSButton

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.layer.borderWidth = 1.0;
    self.layer.cornerRadius = 5.0;
    self.layer.borderColor = self.coloredIn ? [UIColor whiteColor].CGColor : [UIColor customOrange].CGColor;
    [self setTintColor:self.coloredIn ? [UIColor whiteColor] : [UIColor customOrange]];
    self.backgroundColor = self.coloredIn ? [UIColor customOrange] : [UIColor whiteColor];
    self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Neue" size:20.0];
    self.clipsToBounds = true;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end