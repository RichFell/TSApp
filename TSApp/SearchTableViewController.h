//
//  SearchTableViewController.h
//  TSApp
//
//  Created by Rich Fellure on 4/20/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    Select_Location = 0,
    Select_Business

}SelectionType;

@class SearchTableViewController, YPBusiness, CDLocation;
@protocol SearchTableViewDelegate <NSObject>

-(void)searchTableVC:(SearchTableViewController *)viewController didSelectASearchOption:(SelectionType)type forEitherBusiness:(YPBusiness *)business orLocation:(CDLocation *)location;

@end

@interface SearchTableViewController : UITableViewController

@property id<SearchTableViewDelegate> delegate;

@property NSArray *businesses;
@property NSArray *locations;

-(instancetype)initFromCallerFrame:(CGRect)frame;
-(void)inputText:(NSString *)text;

@end
