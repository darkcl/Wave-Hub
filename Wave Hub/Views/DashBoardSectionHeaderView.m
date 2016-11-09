//
//  DashBoardSectionHeaderView.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 9/11/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import "DashBoardSectionHeaderView.h"

@implementation DashBoardSectionHeaderView

- (IBAction)viewMoreButtonPressed:(id)sender {
    if (self.didPresseViewMore) {
        self.didPresseViewMore();
    }
}

+ (instancetype)headerWithFrame:(CGRect)frame{
    
    DashBoardSectionHeaderView *sectionHeaderView = [[DashBoardSectionHeaderView alloc] initWithFrame:frame];
    
    if (sectionHeaderView) {
        
        sectionHeaderView.viewContent = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:sectionHeaderView options:nil] firstObject];
        [sectionHeaderView.viewContent setFrame:frame];
        
        sectionHeaderView.translatesAutoresizingMaskIntoConstraints = YES;
        
        [sectionHeaderView addSubview:sectionHeaderView.viewContent];
        
        [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:sectionHeaderView.viewContent
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:sectionHeaderView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0
                                                                       constant:0]];
        
        [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:sectionHeaderView.viewContent
                                                                      attribute:NSLayoutAttributeLeft
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:sectionHeaderView
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:0]];
        
        [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:sectionHeaderView.viewContent
                                                                      attribute:NSLayoutAttributeTrailing
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:sectionHeaderView
                                                                      attribute:NSLayoutAttributeTrailing
                                                                     multiplier:1.0
                                                                       constant:0]];
        
        [sectionHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:sectionHeaderView.viewContent
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:sectionHeaderView
                                                                      attribute:NSLayoutAttributeLeading
                                                                     multiplier:1.0
                                                                       constant:0]];
        [sectionHeaderView layoutIfNeeded];
        
        return sectionHeaderView;
    }
    
    return nil;
}

@end
