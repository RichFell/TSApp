//
//  NSString+StringCategory.m
//  TSApp
//
//  Created by Rich Fellure on 9/1/14.
//  Copyright (c) 2014 TravelSages. All rights reserved.
//

#import "NSString+StringCategory.h"

@implementation NSString (StringCategory)

-(NSString *)stringByStrippingHtml
{
    NSString *inputString = self;

    if (inputString)
    {
        if([inputString length] > 0)
        {
            NSRange range;

            while ((range = [inputString rangeOfString:@"<[^>]+>" options: NSRegularExpressionSearch]).location != NSNotFound)
            {
                inputString = [inputString stringByReplacingCharactersInRange:range withString:@""];
            }
            
        }
    }
    return inputString;
}

@end
