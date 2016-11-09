//
//  DashBoardViewController.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 9/11/2016.
//  Copyright © 2016 Memory Leaks. All rights reserved.
//

#import "DashBoardViewController.h"
#import "DashBoardSectionHeaderView.h"

#import "FavoritesViewController.h"

@interface DashBoardViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DashBoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    aLabel.text = @"Dashboard";
    aLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17];
    aLabel.textColor = [UIColor blackColor];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = aLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 68.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DashBoardSectionHeaderView *sectionHeaderView = [DashBoardSectionHeaderView headerWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 68.0f)];
    
    [sectionHeaderView setDidPresseViewMore:^{
        FavoritesViewController *favVC = [[FavoritesViewController alloc] initWithNibName:@"FavoritesViewController" bundle:nil];
        [self.navigationController pushViewController:favVC animated:YES];
    }];
    
    return sectionHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellIdentifier = @"CellIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = @"";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
