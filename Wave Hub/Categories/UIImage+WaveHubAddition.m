//
//  UIImage+WaveHubAddition.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 17/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "UIImage+WaveHubAddition.h"

#import <FontAwesomeKit/FontAwesomeKit.h>


@implementation UIImage (WaveHubAddition)

+ (UIImage *)musicPlaceHolder{
    FAKFontAwesome *musiceIcon = [FAKFontAwesome musicIconWithSize:175];
    [musiceIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    musiceIcon.drawingBackgroundColor = [UIColor lightGrayColor];
    UIImage *iconImage = [musiceIcon imageWithSize:CGSizeMake(500, 500)];
    return iconImage;
}

@end
