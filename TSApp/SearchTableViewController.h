//
//  SearchTableViewController.h
//  TSApp
//
//  Created by Rich Fellure on 4/20/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewController : UITableViewController

@property NSArray *businesses;
@property NSArray *locations;

-(instancetype)initFromCallerFrame:(CGRect)frame;
-(void)inputText:(NSString *)text;

@end
