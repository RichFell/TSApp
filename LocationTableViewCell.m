//
//  LocationTableViewCell.m
//  TSApp
//
//  Created by Rich Fellure on 8/12/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "LocationTableViewCell.h"

@implementation LocationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.countLabel.backgroundColor = [UIColor customOrange];
    self.countLabel.layer.cornerRadius = 20.0;
    self.countLabel.clipsToBounds = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

-(void)prepareForReuse
{
    self.indexPath = nil;
}
- (IBAction)changeVisitedStatusOnTapped:(UIButton *)sender
{
    [self.delegate didTapVisitedButtonAtIndexPath:self.indexPath];
}

@end
