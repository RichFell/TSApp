//
//  LocationTableViewCell.h
//  TSApp
//
//  Created by Rich Fellure on 8/12/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationTVCellDelegate <NSObject>

@required
-(void)didTapVisitedButtonAtIndexPath:(NSIndexPath *)indexPath;

@end
@interface LocationTableViewCell : UITableViewCell
@property id<LocationTVCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIButton *visitedButton;

@end
