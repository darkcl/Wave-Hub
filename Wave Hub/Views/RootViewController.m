//
//  RootViewController.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 13/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "RootViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <DLImageLoader/DLImageLoader.h>

#import "MusicTableViewCell.h"
#import "NSLayoutConstraint+Multiplier.h"
#import <MTKObserving.h>

@interface RootViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [_tableView registerNib:[UINib nibWithNibName:@"MusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"MusicTableViewCell"];
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.title = @"Favourites";
    //    [self setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    _delegate = [WHSoundManager sharedManager];
    MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        [[WHWebrequestManager sharedManager] fetchAllFavouriteWithInfo:nil
                                                               success:^(MyFavourite *responseObject) {
                                                                   self->favourite = responseObject;
                                                                   
                                                                   [[WHDatabaseManager sharedManager] saveMyFavourite:responseObject];
                                                                   
                                                                   [self.tableView reloadData];
                                                                   [self.tableView.mj_header endRefreshing];
                                                               }
                                                               failure:^(NSError *error) {
                                                                   
                                                               }];
    }];
    // Set title
    [header setTitle:@"Pull down to refresh" forState:MJRefreshStateIdle];
    [header setTitle:@"Release to refresh" forState:MJRefreshStatePulling];
    [header setTitle:@"Loading ..." forState:MJRefreshStateRefreshing];
    
    // Set font
    header.stateLabel.font = [UIFont systemFontOfSize:15];
    
    // Set textColor
    header.stateLabel.textColor = [UIColor redColor];
    header.lastUpdatedTimeLabel.hidden = YES;
    
    self.tableView.mj_header = header;
    
    [[WHDatabaseManager sharedManager] readMyFavourite:^(id result) {
        if (result == nil) {
            [self.tableView.mj_header beginRefreshing];
        }else{
            self->favourite = result;
            [self.tableView reloadData];
        }
    }];
    
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    aLabel.text = @"Favourite";
    aLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17];
    aLabel.textColor = [UIColor blackColor];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = aLabel;
    
    
    [[WHSoundManager sharedManager] setDelegate:self];
}

- (void)soundDidStop{
    currentPlayingProgress = -1.0;
    currentPlayingIndex = -1;
    [_tableView reloadData];
}

- (void)didUpdatePlayingProgress:(float)progress{
    currentPlayingProgress = progress;
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:currentPlayingIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didUpdatePlayingIndex:(NSInteger)index{
    currentPlayingIndex = index;
    [_tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return favourite.collection.count;
}

- (NSString *)timeFormatted:(int)totalMillSeconds{
    
    int totalSeconds = totalMillSeconds/ 1000;
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicTableViewCell *cell = (MusicTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MusicTableViewCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[MusicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MusicTableViewCell"];
    }
    // Configure the cell...
    Collection *info = favourite.collection[indexPath.row];
    cell.titleLabel.text = info.title;
    cell.authorLabel.text = info.user.username ? info.user.username : @"";
    cell.durationLabel.text = [self timeFormatted:(int)info.duration];
    if (indexPath.row == currentPlayingIndex) {
        cell.progressView.hidden = NO;
        cell.progressView.progress = currentPlayingProgress;
    }else{
        cell.progressView.hidden = YES;
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    MusicTableViewCell *musicCell = (MusicTableViewCell *)cell;
    Collection *info = favourite.collection[indexPath.row];
    [musicCell startLoadingCover:info.artworkUrl];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    MusicTableViewCell *musicCell = (MusicTableViewCell *)cell;
    [musicCell cancelLoadingCover];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[WHSoundManager sharedManager] playMyFavourite:favourite withIndex:indexPath.row forceStart:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
}

@end
