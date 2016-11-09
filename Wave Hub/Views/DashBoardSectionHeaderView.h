//
//  DashBoardSectionHeaderView.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 9/11/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashBoardSectionHeaderView : UIView
@property (strong, nonatomic) IBOutlet UIView *viewContent;
@property (strong, nonatomic) IBOutlet UILabel *sectionTitleLabel;

+ (instancetype)headerWithFrame:(CGRect)frame;

@property (nonatomic, strong) void(^didPresseViewMore)(void);

@end
