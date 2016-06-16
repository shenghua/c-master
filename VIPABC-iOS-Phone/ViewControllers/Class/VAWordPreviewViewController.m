//
//  VAWordPreviewViewController.m
//  VIPABC-iOS-Phone
//
//  Created by ledka on 16/2/25.
//  Copyright © 2016年 vipabc. All rights reserved.
//

#import "VAWordPreviewViewController.h"
#import "TMNNetworkLogicManager.h"
#import "VATool.h"
#import <AVFoundation/AVFoundation.h>
#import "SimpleAudioPlayer.h"

@interface VAWordPreviewViewController () <AVAudioPlayerDelegate>

@property (nonatomic, strong) NSArray *previewWords;

@end

@implementation VAWordPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"单词";
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"VABack"] forState:UIControlStateNormal];
    backButton.contentMode = UIViewContentModeScaleAspectFit;
    backButton.frame = CGRectMake(0, 0, 25, 25);
    [backButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
    
    [SVProgressHUD show];
    [[TMNNetworkLogicManager sharedInstace] getVocabularyListWithBrandId:TMNBrandID_VIPABC materialSn:self.classinfo.materialSn successBlock:^(NSDictionary *responseDic) {
        [SVProgressHUD dismiss];
        self.previewWords = [responseDic objectForKey:@"data"];
        [tableView reloadData];
    } failedBlock:^(NSError *error, id responseObject) {
        [SVProgressHUD showErrorWithStatus:responseObject];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resourcees that can be recreated.
}

- (void)playWord:(UIButton *)sender
{
    NSDictionary *wordDesc = [self.previewWords objectAtIndex:sender.tag];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[wordDesc objectForKey:@"mp3"]]];
    
    [SimpleAudioPlayer playFileWithData:data];
}

- (void)popViewController
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    [currentDevice setValue:[NSNumber numberWithInt:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    NSLog(@"");
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.previewWords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentity = @"CellIdentity";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentity];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
    NSDictionary *wordDesc = [self.previewWords objectAtIndex:indexPath.row];
    UILabel *wordLabel = [VATool getLabelWithTextString:[wordDesc objectForKey:@"name"] fontSize:18 textColor:[UIColor blackColor] sapce:0 bold:YES];
    wordLabel.textAlignment = NSTextAlignmentLeft;
    [cell addSubview:wordLabel];
    
    [wordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell).offset(10);
        make.centerY.equalTo(cell);
    }];
    
    UIButton *playWordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playWordButton setImage:[UIImage imageNamed:@"SessionRoomPlay"] forState:UIControlStateNormal];
    playWordButton.tag = indexPath.row;
    [playWordButton addTarget:self action:@selector(playWord:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:playWordButton];
    
    [playWordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cell).offset(-10);
        make.centerY.equalTo(cell);
    }];
    
    NSArray *define = [wordDesc objectForKey:@"define"];
    
    if (define != nil && define.count > 0) {
        UILabel *description = [VATool getLabelWithTextString:[[define objectAtIndex:0] objectForKey:@"name"] fontSize:15 textColor:[UIColor grayColor] sapce:0 bold:NO];
        description.textAlignment = NSTextAlignmentCenter;
        //    description.backgroundColor = [UIColor redColor];
        [cell addSubview:description];
        
        [description mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wordLabel.right).offset(10);
            make.centerY.equalTo(wordLabel);
            make.height.equalTo(@(20));
            make.right.equalTo(cell.right).offset(-50);
        }];
    }
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [cell addSubview:lineView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell).offset(10);
        make.height.equalTo(@(1));
        make.width.equalTo(cell).offset(-20);
        make.bottom.equalTo(cell);
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma makr - Autorotate
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

@end
