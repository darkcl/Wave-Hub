//
//  NSLayoutConstraint+Multiplier.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 15/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "NSLayoutConstraint+Multiplier.h"

@implementation NSLayoutConstraint (Multiplier)

-(instancetype)updateMultiplier:(CGFloat)multiplier {
    NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:self.firstItem attribute:self.firstAttribute relatedBy:self.relation toItem:self.secondItem attribute:self.secondAttribute multiplier:multiplier constant:self.constant];
    [newConstraint setPriority:self.priority];
    newConstraint.shouldBeArchived = self.shouldBeArchived;
    newConstraint.identifier = self.identifier;
    newConstraint.active = true;
    
    [NSLayoutConstraint deactivateConstraints:[NSArray arrayWithObjects:self, nil]];
    [NSLayoutConstraint activateConstraints:[NSArray arrayWithObjects:newConstraint, nil]];
    //NSLayoutConstraint.activateConstraints([newConstraint])
    return newConstraint;
}


@end
