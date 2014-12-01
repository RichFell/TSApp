//
//  RegionTableViewCell.h
//  TSApp
//
//  Created by Rich Fellure on 9/1/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIButton *completedButton;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end
