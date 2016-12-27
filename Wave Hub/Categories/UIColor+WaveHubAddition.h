//
//  UIColor+WaveHubAddition.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 24/12/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface UIColor (WaveHubAddition)

+ (UIColor *)wh_playingLabelColor;
+ (UIColor *)wh_favoriteColor;

+ (UIColor *)wh_userTitleColor;
+ (UIColor *)wh_songTitleColor;

@end
