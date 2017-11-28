//
//  ViewController.m
//  LVAudioAndVideo
//
//  Created by LV on 2017/11/28.
//  Copyright © 2017年 LV. All rights reserved.
//

#import "ViewController.h"
#import "Test.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource> {
    NSArray<NSString *> * _sectionArray;
    NSArray<NSArray<NSString *> *> * _rowsArray;
}
@property (nonatomic, strong) UITableView * tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupConfigureData];
    [self.view addSubview:self.tableView];
    [self.tableView reloadData];
    
    Test * test = [Test new];
    [test readyStart];
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView * header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    header.textLabel.text = _sectionArray[section];
    return header;
}

#pragma mark - <UITableViewDataSource>

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = _rowsArray[indexPath.section][indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _rowsArray[section].count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sectionArray.count;
}

#pragma mark - Private

- (void)setupConfigureData {
    _sectionArray = @[@"采集",@"编码",@"解码",@"传输",@"渲染与播放"];
    _rowsArray = @[@[@"音频采集",@"视频采集"],@[@"音频编码",@"视频编码"],@[@"音频解码",@"视频解码"],@[@"rtmp推拉流"],@[@"音频播放",@"视频播放"]];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 40;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
