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

#import <FontAwesomeKit/FAKFontAwesome.h>

#import "MusicDetailViewController.h"

@interface RootViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    currentPlayingIndex = -1;
    currentPlayingProgress = -1;
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
                                                               success:^(NSArray *responseObject) {
                                                                   
                                                                   [[WHDatabaseManager sharedManager] saveTrackFromFavouriteArray:responseObject];
                                                                   
                                                                   [[WHDatabaseManager sharedManager] readTrackFromFavourite:^(id result) {
                                                                       self->favourite = result;
                                                                       [self.tableView reloadData];
                                                                   }];
                                                                   
                                                                   [self.tableView reloadData];
                                                                   [self.tableView.mj_header endRefreshing];
                                                               }
                                                               failure:^(NSError *error) {
                                                                   
                                                               }];
    }];
    // Set title
    [header setTitle:@"Pull down to refresh" forState:MJRefreshStateIdle];
    [header setTitle:@"Release to refresh" forState:MJRefreshStatePulling];
    [header setTitle:@"Loading" forState:MJRefreshStateRefreshing];
    
    // Set font
    header.stateLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:15];
    
    // Set textColor
    header.stateLabel.textColor = [UIColor lightGrayColor];
    header.lastUpdatedTimeLabel.hidden = YES;
    
    self.tableView.mj_header = header;
    
    [[WHDatabaseManager sharedManager] readTrackFromFavourite:^(id result) {
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
    
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    currentPlayingIndex = [[WHSoundManager sharedManager] playingIdx];
    [[WHSoundManager sharedManager] setDelegate:self];
    [self.tableView reloadData];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat navigationHeight = self.navigationController.navigationBar.frame.size.height;
    
    [self ysl_addTransitionDelegate:self];
    [self ysl_pushTransitionAnimationWithToViewControllerImagePointY:statusHeight + navigationHeight + 26 
                                                   animationDuration:0.3];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self ysl_removeTransitionDelegate];
    [[WHSoundManager sharedManager] setDelegate:nil];
}

#pragma mark - Table view data source

- (void)didTogglePlayPause:(WHTrackModel *)info{
    NSInteger playIndex = [favourite indexOfObject:info];
    
    if ([[WHSoundManager sharedManager] isPlaying]) {
        if (playIndex == currentPlayingIndex) {
            [[WHSoundManager sharedManager] playerPause];
        }else{
            [[WHSoundManager sharedManager] playMyFavourite:favourite withIndex:playIndex forceStart:YES];
        }
    }else{
        [[WHSoundManager sharedManager] playMyFavourite:favourite withIndex:playIndex forceStart:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return favourite.count;
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
    WHTrackModel *info = favourite[indexPath.row];
    [cell setInfo:info];
    
    cell.titleLabel.text = info.trackTitle;
    cell.authorLabel.text = info.author ? info.author : @"";
    cell.durationLabel.text = [self timeFormatted:(int)info.duration];
    
    cell.progressView.hidden = YES;
    if (indexPath.row == currentPlayingIndex) {
        cell.progressView.hidden = NO;
        cell.progressView.progress = currentPlayingProgress;
        
        FAKFontAwesome *buttonIcon = ([[WHSoundManager sharedManager] isPlaying])? [FAKFontAwesome pauseIconWithSize:17] : [FAKFontAwesome playIconWithSize:17];
        [buttonIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        [cell.togglePlayPauseButton setAttributedTitle:buttonIcon.attributedString forState:UIControlStateNormal];
    }else{
        cell.progressView.hidden = YES;
        FAKFontAwesome *buttonIcon =  [FAKFontAwesome playIconWithSize:17];
        [buttonIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        [cell.togglePlayPauseButton setAttributedTitle:buttonIcon.attributedString forState:UIControlStateNormal];
    }
    
    cell.cellDelegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    MusicTableViewCell *musicCell = (MusicTableViewCell *)cell;
    WHTrackModel *info = favourite[indexPath.row];
    [musicCell startLoadingCover:info.albumCoverUrl];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    MusicTableViewCell *musicCell = (MusicTableViewCell *)cell;
    [musicCell cancelLoadingCover];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Show Detail View");
    WHTrackModel *info = favourite[indexPath.row];
    MusicDetailViewController *detailVC = [[MusicDetailViewController alloc] initWithTrackInfo:info];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.0;
}

#pragma mark -- YSLTransitionAnimatorDataSource
- (UIImageView *)pushTransitionImageView
{
    MusicTableViewCell *cell = (MusicTableViewCell *)[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
    return cell.coverImageView;
}

- (UIImageView *)popTransitionImageView
{
    return nil;
}

@end
