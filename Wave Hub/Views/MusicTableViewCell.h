//
//  MusicTableViewCell.h
//  Wave Hub
//
//  Created by Yeung Yiu Hung on 14/7/2016.
//  Copyright © 2016年 Memory Leaks. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MusicTableViewCellDelegate <NSObject>

- (void)didTogglePlayPause:(Collection *)info;

@end

@interface MusicTableViewCell : UITableViewCell{
    NSString *tempUrl;
    Collection *trackInfo;
}

@property (weak, nonatomic) IBOutlet UIButton *togglePlayPauseButton;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

- (void)startLoadingCover:(NSString *)url;
- (void)cancelLoadingCover;

- (void)setInfo:(Collection *)info;

- (IBAction)togglePlayPauseButtonPressed:(id)sender;

@property (assign) id<MusicTableViewCellDelegate>cellDelegate;

@end
