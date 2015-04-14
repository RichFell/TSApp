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

+ (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];

    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;

    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;

            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }

        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }

    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
