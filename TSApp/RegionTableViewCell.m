//
//  RegionTableViewCell.m
//  TSApp
//
//  Created by Rich Fellure on 9/1/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "RegionTableViewCell.h"

@implementation RegionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.numberLabel.backgroundColor = [UIColor customOrange];
    self.numberLabel.layer.cornerRadius = 15.0;
    self.numberLabel.clipsToBounds = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)prepareForReuse
{

}
@end
