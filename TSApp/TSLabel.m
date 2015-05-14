//
//  TSLabel.m
//  TSApp
//
//  Created by Rich Fellure on 5/13/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "TSLabel.h"

@implementation TSLabel

-(void)prepareForInterfaceBuilder {
    [self setup];
}

-(void)awakeFromNib {
    [self setup];
}

-(void)setup {
    self.textColor = [UIColor customOrange];
    self.backgroundColor = [UIColor clearColor];
    self.alpha = 0.8;
}

@end
