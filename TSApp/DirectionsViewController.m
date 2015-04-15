//
//  DirectionsViewController.m
//  TSApp
//
//  Created by Rich Fellure on 4/5/15.
//  Copyright (c) 2015 TravelSages. All rights reserved.
//

#import "DirectionsViewController.h"
#import "Direction.h"
#import "DirectionSet.h"

@interface DirectionsViewController ()
#pragma mark - Outlets
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DirectionsViewController

#pragma mark - View LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.text = @"Sorry no directions to display, select some locations to get directions for.";
    [self setUpNotificationListeners];
}

#pragma mark - Helper Methods
-(void)setUpNotificationListeners {
    [[NSNotificationCenter defaultCenter] addObserverForName:kSelectedDirectionNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        NSDictionary *info = note.userInfo;
        NSArray *directions = info[kDirectionArrayKey];
        [self displayDirections:directions];
    }];
}

#pragma mark - Instance Method for Displaying directions
-(void)displayDirections:(NSArray *)directions {
    NSMutableString *dirString = [NSMutableString string];
    int x = 1;
    for (Direction *direction in directions) {
        [dirString appendFormat:@"%d: %@\n", x, direction.steps];
        x++;
    }
    self.textView.text = dirString;
}

@end
