//
//  ViewController.m
//  XQShowPhotosToolDemo
//
//  Created by 小强 on 2018/6/21.
//  Copyright © 2018年 小强. All rights reserved.
//

#import "ViewController.h"
#import "ShowCell.h"
#import "XQShowPhotosView.h"
#import "XQShowPopupView.h"
//由于时间问题，后期补上注释
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,ShowCellDelegate>

@property(nonatomic,strong)UITableView * tableView;
@property(nonatomic,strong)NSMutableArray * dataA;
@property(nonatomic,assign)BOOL isPopupImgs;//解决当你两个手指分别点中不同cell上的图片时会弹出两个 XQShowPopupView ，当然还有其它的解决方法，设置成单例
//@property(nonatomic,assign)BOOL isHiddenStatusBar;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self dataInit];
    [self viewInit];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)dataInit
{
    if(!_dataA)
        _dataA = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 20; i ++) {
        ShowModel * md = [[ShowModel alloc] init];
        md.show_imgA = [[NSMutableArray alloc] init];
        int num = arc4random() % 9 + 1;
        for (int j = 0 ; j < num ; j ++) {
            [md.show_imgA addObject:[UIImage imageNamed:[NSString stringWithFormat:@"img%d",j + 1]]];
        }
        [_dataA addObject:md];
    }
}

- (void)viewInit
{
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView
{
    if(_tableView == nil)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WW, HH) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.tableHeaderView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[ShowCell class] forCellReuseIdentifier:@"ShowCell"];
        
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
        }
    }
    return _tableView;
}

//- (BOOL)prefersStatusBarHidden
//{
//    return self.isHiddenStatusBar;
//}

//- (void)hiddenStatusBar
//{
//    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
//        [self prefersStatusBarHidden];
//        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
//    }
//}

#pragma mark --------------- UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataA.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShowCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ShowCell" forIndexPath:indexPath];
    [cell setInfoModel:_dataA[indexPath.row]];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShowModel * md = _dataA[indexPath.row];

    return [md showImgsVSize].height + 40;
}

#pragma mark --------------- ShowCellDelegate
- (void)cell:(ShowCell *)cell imgs:(NSArray *)imgA index:(NSUInteger)index originRects:(NSArray<NSValue *> *)originRectA imgShowSizes:(NSArray<NSValue *> *)showSizeA
{
    if(!_isPopupImgs)
    {
        _isPopupImgs = YES;
        CGRect originRect = [originRectA[index] CGRectValue];
        CGSize showSize  = [showSizeA[index] CGSizeValue];
        CGRect showRect = CGRectMake((WW - showSize.width)/2, (HH - showSize.height)/2, showSize.width, showSize.height);
        XQShowPopupView * popupView = [[XQShowPopupView alloc] initWithFrame:CGRectMake(0, 0, WW, HH) imgUrl:imgA[index] originRect:originRect showRect:showRect];
        
        UIWindow * wd = [[UIApplication sharedApplication].delegate window];
        popupView.leaveBlock = ^{
            self.isPopupImgs = NO;
            XQShowPhotosView * photosView = [[XQShowPhotosView alloc] initWithFrame:CGRectMake(0, 0, WW, HH) pictureA:imgA currentPage:index originRects:originRectA imgShowSizes:showSizeA];
            photosView.leaveBlock = ^{
                wd.windowLevel = UIWindowLevelNormal;
            };
            wd.windowLevel = UIWindowLevelAlert;
            [wd addSubview:photosView];
        };
        [wd addSubview:popupView];
        [popupView startAnimation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
