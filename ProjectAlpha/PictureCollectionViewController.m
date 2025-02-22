//
//  PictureCollectionViewController.m
//  ProjectAlpha
//
//  Created by lanou3g on 15/10/25.
//  Copyright © 2015年 com.sunshuaiqi. All rights reserved.
//

#import "PictureCollectionViewController.h"

#import "PictureCollectionViewCell.h"
#import "PictureModel.h"
#import "PictureBrowsingViewController.h"
#import "ProjectAlpha-Swift.h"

#define kPictureUrl @"http://zhiyue.cutt.com/api/clip/images?clipId=101740267&tagId=46901"

@interface PictureCollectionViewController ()

@property (nonatomic,strong) NSMutableArray * modelArray;
@property (nonatomic,assign) NSInteger next; // 用来存储下拉加载的页面的next值

@end

@implementation PictureCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

// 懒加载
- (NSMutableArray *)modelArray
{
    if (!_modelArray) {
        
        _modelArray = [NSMutableArray array];
    }

    return _modelArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    if ([userDefaults colorForKey:@"light"]) {
        
        self.collectionView.backgroundColor = [userDefaults colorForKey:@"light"];
        
    }else {
        
        self.collectionView.backgroundColor = [UIColor whiteColor];
        
    }
    // 采用自定义的布局方式
    WaterFlowLayout * layout = [WaterFlowLayout new];
    // 绑定代理
    layout.delegate = self;
    
    self.collectionView.collectionViewLayout = layout;
    
    // 注册cell
    [self.collectionView registerClass:[PictureCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];

    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 55, 0);
    // 颜色更改通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeColorUpdate:) name:@"themeColorUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nightMode:) name:@"night" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dayMode:) name:@"day" object:nil];
    [self parseData];
    //给偏移量添加观察者
    [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [self UpLoadingAndDownRefresh];
    
}


-(void)dealloc
{
    // 颜色更改通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"themeColorUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:@"night" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"day" object:nil];
    // 移除观察者
    [self.collectionView removeObserver:self forKeyPath:@"contentOffset"];
}
// 夜间模式
- (void)nightMode:(NSNotification *)notification
{
    
    self.collectionView.backgroundColor = NightBackgroundColor;
    
    [self.collectionView reloadData];
}

// 日间模式
- (void)dayMode:(NSNotification *)notification
{
    
    if ([userDefaults colorForKey:@"light"]) {
        
        self.collectionView.backgroundColor = [userDefaults colorForKey:@"light"];
        
    }else {
        
        self.collectionView.backgroundColor = [UIColor whiteColor];
        
    }
    
    [self.collectionView reloadData];
}

// 颜色改变
- (void)themeColorUpdate:(NSNotification *)notification
{
    
    self.collectionView.backgroundColor = notification.userInfo[@"light"];
    
    
    [self.collectionView reloadData];
    
}


// 解析数据
- (void)parseData
{

    NSURL * url = [NSURL URLWithString:kPictureUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    __weak PictureCollectionViewController * weakSelf = self;
    NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            NSArray * articlesArray = dict[@"articles"];
            self.next = (long)dict[@"next"];
            
            for (NSDictionary * dic in articlesArray) {
                
                PictureModel * model = [PictureModel new];
                [model setValuesForKeysWithDictionary:dic];
                [weakSelf.modelArray addObject:model];
                
                
            }
            
        }
        
    
        // 主线程刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [self.collectionView reloadData];
            
        });
        
    }];
    
    [task resume];
}

#pragma mark --- ---------  上拉加载，下拉刷新  ----------------
- (void)UpLoadingAndDownRefresh
{
    
    // 下拉刷新
    __weak PictureCollectionViewController * weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.collectionView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        if (weakSelf.modelArray.count == 0) {
            [weakSelf parseData];
        }
        
        // 刷新表格
        [weakSelf.collectionView reloadData];
        
        // 拿到当前的下拉刷新控件，结束刷新状态
        [weakSelf.collectionView.header endRefreshing];
        
        
    }];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    weakSelf.collectionView.header.automaticallyChangeAlpha = YES;
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark <UICollectionViewDataSource>

// 分区个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}

// 每个分区item的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _modelArray.count;
}

// 显示cell上的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PictureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    PictureModel * model = _modelArray[indexPath.row];
    cell.model = model;
    
    return cell;
}





#pragma mark -- 实现布局中的代理方法
- (CGFloat)waterFlow:(WaterFlowLayout *)waterFlow heightForWidth:(CGFloat)width atIndexPath:(NSIndexPath *)indexPath
{

    PictureModel * model = _modelArray[indexPath.row];
    
    NSArray * array = [model.imgDim componentsSeparatedByString:@"x"];

    
    return [array.lastObject floatValue] / [array.firstObject floatValue] * width;
}

#pragma mark -- 点击某个cell进入详情页
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    PictureBrowsingViewController * pictureBrowseVC = [[PictureBrowsingViewController alloc] init];
    pictureBrowseVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    UINavigationController * NC = [[UINavigationController alloc] initWithRootViewController:pictureBrowseVC];

    PictureModel * model = _modelArray[indexPath.row];
    pictureBrowseVC.intro = model.title;
    pictureBrowseVC.imgIdsArray = model.imageIds;
    [self presentViewController:NC animated:YES completion:nil];
    
}


#pragma mark -- 上滑时tabbar消失，下拉是tabbar出现

//实现观察者方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    
    CGPoint newContOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
    
    CGPoint oldContOffset= [change[NSKeyValueChangeOldKey] CGPointValue];
    
    CGFloat dy = newContOffset.y - oldContOffset.y;
    // 上滑手势
    if (dy > 0) {
        // tabbar 在屏幕内显示
        if (self.tabBarController.tabBar.frame.origin.y < ScreenHeight ) {
            
            self.tabBarController.tabBar.frame = CGRectMake(0, CGRectGetMinY(self.tabBarController.tabBar.frame)+dy, ScreenWidth, 49);
            
        }else{ // tabbar 不在屏幕中（将其放在屏幕的最下方）
            
            self.tabBarController.tabBar.frame = CGRectMake(0, ScreenHeight, ScreenWidth, 49);
        }
        
        
        // 下拉手势
    }else if(dy <= 0){
        // 不在原有位置
        if (self.tabBarController.tabBar.frame.origin.y > ScreenHeight-49) {
            
            self.tabBarController.tabBar.frame = CGRectMake(0, CGRectGetMinY(self.tabBarController.tabBar.frame)+dy, ScreenWidth, 49);
            
        }else{
            // 在原有位置
            self.tabBarController.tabBar.frame = CGRectMake(0, ScreenHeight - 49, ScreenWidth, 49);
            
        }
        
    }
    
    // 防止回弹时，tabbar消失
    if (oldContOffset.y < 200) {
        
        self.tabBarController.tabBar.frame = CGRectMake(0,ScreenHeight- 49, ScreenWidth, 49);
    }
    
    
}





#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
