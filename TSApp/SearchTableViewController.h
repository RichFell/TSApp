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

@class SearchTableViewController, Business, CDLocation;
@protocol SearchTableViewDelegate <NSObject>

-(void)searchTableVC:(SearchTableViewController *)viewController didSelectASearchOption:(SelectionType)type forEitherBusiness:(Business *)business orLocation:(CDLocation *)location;

@end

@interface SearchTableViewController : UITableViewController

@property id<SearchTableViewDelegate> delegate;

@property NSArray *businesses;
@property NSArray *locations;

//Convenience init that is used to call this according to the size of the element that calls it.
-(instancetype)initFromCallerFrame:(CGRect)frame;

//Used to tell the VC that it should filter the shown array by the text
-(void)inputText:(NSString *)text;
//Tells the view to show the default array versus the filtered
-(void)resetArray;

@end
