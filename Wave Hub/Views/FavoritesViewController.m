//
//  RootViewController.m
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 13/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import "FavoritesViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <DLImageLoader/DLImageLoader.h>

#import "MusicTableViewCell.h"
#import "NSLayoutConstraint+Multiplier.h"
#import <MTKObserving.h>

#import <FontAwesomeKit/FAKFontAwesome.h>

#import "MusicDetailViewController.h"

@interface FavoritesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation FavoritesViewController

- (id)initWithFavorites:(NSArray <WHTrackModel *> *)songs{
    if (self = [super initWithNibName:@"FavoritesViewController" bundle:nil]) {
        favourite = songs;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [_tableView registerNib:[UINib nibWithNibName:@"MusicTableViewCell" bundle:nil] forCellReuseIdentifier:@"MusicTableViewCell"];
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.title = @"Favourites";
    //    [self setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

    MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        [[WHWebrequestManager sharedManager] fetchAllFavouriteWithInfo:nil
                                                               success:^(NSArray *responseObject) {
                                                                   
                                                                   [[WHDatabaseManager sharedManager] saveTrackFromFavouriteArray:responseObject];
                                                                   self->favourite = responseObject;
                                                                   
                                                                   [self.tableView reloadData];
                                                                   [[WHSoundManager sharedManager] reloadTracksData];
                                                                   
                                                                   [self.tableView.mj_header endRefreshing];
                                                               }
                                                               failure:^(NSError *error) {
                                                                   [self.tableView.mj_header endRefreshing];
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
            
            [[WHSoundManager sharedManager] reloadTracksData];
        }
    }];
    
    UILabel *aLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    aLabel.text = @"Favourite";
    aLabel.font = [UIFont fontWithName:@"Montserrat-Regular" size:17];
    aLabel.textColor = [UIColor blackColor];
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = aLabel;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 36, 36);
    FAKFontAwesome *buttonIcon =  [FAKFontAwesome chevronLeftIconWithSize:17.0f];
    [buttonIcon addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor]];
    
    [backButton setAttributedTitle:buttonIcon.attributedString forState:UIControlStateNormal];
    
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdatePlayingTrack:)
                                                 name:WHSoundTrackDidChangeNotifiction
                                               object:nil];
}

- (void)backButtonPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:NO];
}


- (NSArray <WHTrackModel *> *)currentPlayingTracks{
    return favourite;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[WHSoundManager sharedManager] setDataSource:self];
    [self.tableView reloadData];
    
    self.navigationController.navigationBar.barTintColor =[UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)didUpdatePlayingTrack:(NSNotification *)info{
    
    if ([info.object isKindOfClass:[WHTrackModel class]]) {
        WHTrackModel *aTrack = (WHTrackModel *)info.object;
        currentPlayingTrack = aTrack;
    }else if ([info.object isKindOfClass:[NSNull class]]) {
        currentPlayingTrack = nil;
    }
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
    if ([[WHSoundManager sharedManager] isPlaying]) {
        if ([[WHSoundManager sharedManager] playingTrack] == info) {
            [[WHSoundManager sharedManager] playerPause];
        }else{
            [[WHSoundManager sharedManager] playTrack:info forceStart:YES];
        }
    }else{
        [[WHSoundManager sharedManager] playTrack:info forceStart:YES];
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
    NSInteger currentPlayingIndex = [favourite indexOfObject:currentPlayingTrack];
    
    // Configure the cell...
    WHTrackModel *info = favourite[indexPath.row];
    [cell setInfo:info isCurrentlyPlaying:(currentPlayingIndex == indexPath.row)];
    
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
    MusicDetailViewController *detailVC = [[MusicDetailViewController alloc] initWithTrackInfo:info withDataSources:favourite];
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
