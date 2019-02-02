//
//  ViewController.m
//  SearchContactsDemo
//
//  Created by Gaomingyang on 2019/2/2.
//  Copyright © 2019 Gaomingyang. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "NSString+chineseTransform.h"
#import "PASEContactsCell.h"
#import "PASESearchPopView.h"
#import "PASESearchView.h"
#import "SearchCoreManager.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)
#define COLOR_HEX(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0 green:((float)((hexValue & 0xFF00) >> 8)) / 255.0 blue:((float)(hexValue & 0xFF)) / 255.0 alpha:1.0f]
static CGFloat viewOffset = 64;
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,weak) PASESearchView * searchBar;
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) UIView * navigation_View;
@property (nonatomic,strong) PASESearchPopView * searchPopView;
@property (nonatomic,strong) NSMutableDictionary * dataDict;//搜索数据源
@property (nonatomic,strong) NSArray * dataSource;
@property (nonatomic,strong) NSMutableArray * searchNameResultArry;
@end

@implementation ViewController
//改变statusBar的颜色
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle  = UIStatusBarStyleDefault;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle  = UIStatusBarStyleLightContent;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self setNavigationViewTo_dis];
    [self setSearchViewTo_dis];
    [self setTableViewTo_dis];
    [self setSearchPopViewTo_dis];
    [self.tableView reloadData];
}
- (void)setNavigationViewTo_dis{
    
    self.navigation_View = ({
        UIView * view = UIView.new;
        view.backgroundColor = COLOR_HEX(0x467dff);
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(self.view);
            make.height.mas_equalTo(IS_IPHONE_X ? 88 : 64);
        }];
        
        
        UILabel * titleLbl = UILabel.new;
        titleLbl.font = [UIFont systemFontOfSize:18];
        titleLbl.textColor = [UIColor whiteColor];
        titleLbl.text = @"常用联系人";
        [view addSubview:titleLbl];
        [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
        }];
        
        
        view;
    });
}
- (void)setSearchPopViewTo_dis{
    self.searchPopView = ({
        PASESearchPopView * popView = [[PASESearchPopView alloc]initWithAttributeBlock:^(PASESearchPopView *popView) {
            popView.animationTime = 0.25;
        }];
        [self.view addSubview:popView];
        [popView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_bottom);
            make.left.mas_equalTo(self.view.mas_left);
            make.width.mas_equalTo(self.view.mas_width);
            make.height.mas_equalTo(self.view.bounds.size.height - (IS_IPHONE_X ? 88 : 64));
        }];
        popView;
    });
}

- (void)setSearchViewTo_dis{
    PASESearchView * bar = [[PASESearchView alloc]init];
    [self.view addSubview:bar];
    self.searchBar = bar;
    __weak typeof(self)weakSelf = self;
    bar.editingBlock = ^{
        
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, -viewOffset);
            weakSelf.searchBar.transform = CGAffineTransformMakeTranslation(0, -viewOffset + 20);
            weakSelf.searchBar.backgroundColor = UIColor.whiteColor;
            weakSelf.searchBar.showCancelBtn = YES;
            weakSelf.navigation_View.backgroundColor = UIColor.whiteColor;
        }];
        [weakSelf.searchPopView showThePopViewWithPASEArray:@[]];
    };
    bar.endEditingBlock = ^{
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.navigationController.navigationBar.transform = CGAffineTransformIdentity;
            weakSelf.searchBar.transform = CGAffineTransformIdentity;
            weakSelf.searchBar.backgroundColor = UIColor.clearColor;
            weakSelf.searchBar.showCancelBtn = NO;
            weakSelf.navigation_View.backgroundColor = COLOR_HEX(0x467dff);
        }];
        weakSelf.searchPopView.dataSource = @[];
        [weakSelf.searchPopView dismissThePopView];
        weakSelf.searchPopView.dataSource = @[];
    };
    bar.searchResultBlock = ^(NSString * searchRusult){
        
    };
    bar.place_holderText = @"搜索";
    [bar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self.navigation_View.mas_bottom);
    }];
    
    bar.editTextChanged = ^(NSString *text) {
        
        [[SearchCoreManager share] Search:text searchArray:nil nameMatch:weakSelf.searchNameResultArry phoneMatch:nil];
        NSNumber * localID;
        NSMutableString *matchString = [NSMutableString string];//为了在库中找到匹配的号码或者是拼音 有那个显示那个
        NSMutableArray * tmpArry = NSMutableArray.new;
        NSMutableArray *matchPos = [NSMutableArray array];
        for (int i = 0; i < weakSelf.searchNameResultArry.count; i ++) {
            localID = [weakSelf.searchNameResultArry objectAtIndex:i];
            
            if ([text length]) {
                [[SearchCoreManager share] GetPinYin:localID pinYin:matchString matchPos:matchPos];
                PASEContactsModel * model = [weakSelf.dataDict objectForKey:localID];
                [tmpArry addObject:model];
                NSMutableAttributedString * attributedString = [NSString lightStringWithSearchResultName:model.name matchPASEArray:matchPos inputString:text lightedColor:COLOR_HEX(0x467dff)];
                model.attributedString = attributedString;
            }
        }
        weakSelf.searchPopView.dataSource = tmpArry.mutableCopy;
    };
    
}
- (void)setTableViewTo_dis{
    UITableView * tableView = [[UITableView alloc]init];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.rowHeight = 55;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(self.searchBar.mas_bottom);
        make.left.and.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    tableView.backgroundColor = COLOR_HEX(0xf1f1f1);
    tableView.tableFooterView = UIView.new;
}

- (void)initData{
    NSMutableArray * tmpPASEArray = NSMutableArray.new;
    for (int i = 0; i < 3; i ++) {
        PASEContactsModel * model = [[PASEContactsModel alloc]initWithName:[NSString stringWithFormat:@"%@%d",@"苏帅",i] mobileNum:@"10089" image:@"ss_image"];
        [tmpPASEArray addObject:model];
    }
    PASEContactsModel * model = [[PASEContactsModel alloc]initWithName:@"StevenJobs" mobileNum:@"10086" image:@"ss_jobs"];
    [tmpPASEArray addObject:model];
    PASEContactsModel * model2 = [[PASEContactsModel alloc]initWithName:@"北京" mobileNum:@"10086" image:nil];
    [tmpPASEArray addObject:model2];
    PASEContactsModel * model3 = [[PASEContactsModel alloc]initWithName:@"大狸子" mobileNum:@"10086" image:@"ss_dalizi"];
    [tmpPASEArray addObject:model3];
    PASEContactsModel * model4 = [[PASEContactsModel alloc]initWithName:@"绯红女巫" mobileNum:@"10086" image:@"ss_witch"];
    [tmpPASEArray addObject:model4];
    PASEContactsModel * model5 = [[PASEContactsModel alloc]initWithName:@"黑寡妇" mobileNum:@"10086" image:@"ss_blackwidow"];
    [tmpPASEArray addObject:model5];
    PASEContactsModel * model6 = [[PASEContactsModel alloc]initWithName:@"重庆" mobileNum:@"13510626301" image:@"ss_blackwidow"];
    [tmpPASEArray addObject:model6];
    PASEContactsModel * model7 = [[PASEContactsModel alloc]initWithName:@"重要" mobileNum:@"18898830685" image:@"ss_blackwidow"];
    [tmpPASEArray addObject:model7];
    for (int i = 10; i < 19; i ++) {
        PASEContactsModel * model = [[PASEContactsModel alloc]initWithName:[NSString stringWithFormat:@"%@%d",@"测试",i] mobileNum:@"10089" image:nil];
        [tmpPASEArray addObject:model];
    }
    
    _dataSource = tmpPASEArray.mutableCopy;
    
    for (int i = 0; i<self.dataSource.count; i++) {
        PASEContactsModel * model = self.dataSource[i];
        [[SearchCoreManager share]AddContact:@(i) name:model.name phone:nil];
        [self.dataDict setObject:model forKey:@(i)];
    }
}

#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource == nil ? 10 : self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PASEContactsCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (!cell) {
        cell = [[PASEContactsCell alloc]initWithPASEFrecontCellStyle:PASEContactsCellStyleDefault reuseIdentifier:@"cellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.model = (PASEContactsModel *)self.dataSource[indexPath.row];
    return cell;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView * view = UIView.new;
    view.backgroundColor = UIColor.whiteColor;
    UILabel * lbl = UILabel.new;
    lbl.font = [UIFont systemFontOfSize:15];
    lbl.textColor = [UIColor colorWithRed:(53/255.0) green:(53/255.0) blue:(53/255.0) alpha:1.0];
    lbl.text = @"常用联系人";
    [view addSubview:lbl];
    [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(view.mas_centerY);
        make.left.mas_equalTo(15);
    }];
    return view;
}

- (NSMutableDictionary *)dataDict{
    
    if (!_dataDict) {
        _dataDict = NSMutableDictionary.new;
    }
    return _dataDict;
}

- (NSMutableArray *)searchNameResultArry{
    
    if (!_searchNameResultArry) {
        _searchNameResultArry = [NSMutableArray array];
    }
    return _searchNameResultArry;
}


@end
