//
//  WHContainerViewController.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 16/11/15.
//  Copyright © 2015 Memory Leaks. All rights reserved.
//

#import "WHContainerViewController.h"
#import "UIView+FLKAutoLayout.h"

CGFloat const kPlayerViewHeight = 50.0f;

@interface WHContainerViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomContraint;

@end

@implementation WHContainerViewController

- (id)initWithContentViewController:(UIViewController *)contentViewController{
    if (self = [super initWithNibName:@"WHContainerViewController" bundle:nil]) {
        contentVC = contentViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    [contentVC willMoveToParentViewController:self];
    [self addChildViewController:contentVC];
    [_containerView addSubview:contentVC.view];
    contentVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [contentVC.view alignTopEdgeWithView:_containerView predicate:nil];
    [contentVC.view alignBottomEdgeWithView:_containerView predicate:nil];
    [contentVC.view alignTrailingEdgeWithView:_containerView predicate:nil];
    [contentVC.view alignLeadingEdgeWithView:_containerView predicate:nil];
    [contentVC didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showPlayerView{
    _bottomContraint.constant = kPlayerViewHeight;
    
    _playerView.hidden = NO;
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                         
                     }];
}

- (void)hidePlayerView{
    _bottomContraint.constant = 0.0;
    
    _playerView.hidden = YES;
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded];
                         
                     }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
