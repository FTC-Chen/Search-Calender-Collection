//
//  ViewController.m
//  SearchWithHotHistory
//
//  Created by anyongxue on 2017/10/9.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "ViewController.h"
#import "SearchViewController.h"
#import "MGSwipeTableCell.h"

#define KStory [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]
#define KScreenWidth [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight [[UIScreen mainScreen] bounds].size.height
#define KVIEWBGColor [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]
#define KRGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define TableLineColor [UIColor colorWithRed:200.0 / 255.0 green:199.0 / 255.0 blue:204.0/ 255.0 alpha:1.0f];

@interface ViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)UISearchBar *searBar;
@property (nonatomic,strong)UITableView *searchTableView;
@property (nonatomic,strong)UITableView *filterTableView;
@property (nonatomic,strong)NSArray *hotDataArr;
@property (nonatomic,strong)NSArray *historyArray;
@property (nonatomic,strong)NSMutableArray *filterArray;
@property (nonatomic,strong)NSMutableArray *filterResultArray;
@property (nonatomic,strong)UIView *footView;
@property (nonatomic,strong)UIView *clearView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.hidesBackButton = YES;//隐藏返回按钮
    
    //热搜数据
    self.hotDataArr = [NSArray arrayWithObjects:@"羊排",@"巧克力",@"五仁月饼",@"吸油纸",@"梭子蟹",@"罐头",@"五粮液",@"周大福",@"扇贝",@"二锅头",@"相机",@"上网宝",nil];
    
    //创建导航栏
    [self creatNavi];
    //创建清空后的视图
    [self ceratClearView];
    
    [self.view addSubview:self.searchTableView];
    [self.view addSubview:self.filterTableView];
    
    [self readNSUserDefaults];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backToRootVC) name:@"backToRootVC" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backToSearchVCWord:) name:@"backToSearchVCWord" object:nil];
}

- (void)backToSearchVCWord:(NSNotification *)noti{

    NSLog(@"%@",noti.userInfo);
    self.searBar.text = [noti.userInfo objectForKey:@"word"];
    //此处返回时想再次显示下拉筛选,在此调用方法,显示self.filterTableView数据即可
    [self.searBar becomeFirstResponder];
}

- (void)dealloc{
     [[NSNotificationCenter defaultCenter]removeObserver:self name:@"backToRootVC" object:nil];
     [[NSNotificationCenter defaultCenter]removeObserver:self name:@"backToSearchVCWord" object:nil];
}

- (void)backToRootVC{
    //返回上级界面
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewDidLayoutSubviews{
    [self.searBar becomeFirstResponder];
}

//创建导航栏
- (void)creatNavi{
    self.searBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth-10, 44)];
    self.searBar.delegate = self;
    self.searBar.showsCancelButton = YES;
    self.searBar.placeholder = @"搜索";
    
    UIView *wrapView = [[UIView alloc] initWithFrame:self.searBar.frame];
    [wrapView addSubview:self.searBar];
    
    [[UISearchBar appearance] setSearchFieldBackgroundImage:[self searchFieldBackgroundImage] forState:UIControlStateNormal];
    [[UISearchBar appearance] setSearchFieldBackgroundImage:[self searchFieldBackgroundImage] forState:UIControlStateNormal];
    UITextField *txfSearchField = [self.searBar valueForKey:@"_searchField"];
    [txfSearchField setDefaultTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.5]}];
    
    self.searBar.searchTextPositionAdjustment = UIOffsetMake(7, 0);
    self.navigationItem.titleView = wrapView;
}

- (void)ceratClearView{
    
    CGFloat w = 0;//保存前一个button的宽以及前一个button距离屏幕边缘的距
    CGFloat h = 10;//用来控制button距离父视图的高
    
    //添加一个清空后的视图
    _clearView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenHeight-64)];
    _clearView.backgroundColor = [UIColor whiteColor];
    _clearView.hidden = YES;
    [self.view addSubview:_clearView];
    
    //热搜
    UILabel *hotSearchLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, KScreenWidth-44, 21)];
    hotSearchLabel.textAlignment = NSTextAlignmentLeft;
    hotSearchLabel.text = @"热搜";
    hotSearchLabel.font  = [UIFont boldSystemFontOfSize:16];
    [_clearView addSubview:hotSearchLabel];
    
    for (int i = 0; i<self.hotDataArr.count; i++) {
        //button
        UIButton *searchBt = [UIButton buttonWithType:UIButtonTypeCustom];
        //moreCouseBt.backgroundColor = [UIColor redColor];
        searchBt.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        searchBt.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        [searchBt setTitleColor:KRGBCOLOR(53, 53, 53) forState:UIControlStateNormal];
        [searchBt setBackgroundColor:KRGBCOLOR(230, 230, 230)];
        searchBt.layer.cornerRadius = 3;
        searchBt.tag = 300+i;
        [searchBt addTarget:self action:@selector(HotSearchForResultInClearView:) forControlEvents:UIControlEventTouchUpInside];
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12.5]};
        CGFloat length = [self.hotDataArr[i] boundingRectWithSize:CGSizeMake(320, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
        //为button赋值
        [searchBt setTitle:self.hotDataArr[i] forState:UIControlStateNormal];
        searchBt.frame = CGRectMake(15+w,CGRectGetMaxY(hotSearchLabel.frame)+h,length+15,21);
        [searchBt.titleLabel setTextAlignment:NSTextAlignmentCenter];
        searchBt.titleLabel.font = [UIFont systemFontOfSize:12.5];
        
        //当button的位置超出屏幕边缘时换行 只是button所在父视图的宽度
        if(15 + w + length + 20 > KScreenWidth){
            w = 0; //换行时将w置为0
            h = h + searchBt.frame.size.height + 10;//距离父视图也变化
            searchBt.frame = CGRectMake(15+w, CGRectGetMaxY(hotSearchLabel.frame)+h, length + 15, 21);//重设button的frame
        }

        w = searchBt.frame.size.width + searchBt.frame.origin.x;
  
        [_clearView addSubview:searchBt];
    }
}

- (UIImage*)searchFieldBackgroundImage {
    
    UIColor*color = [UIColor whiteColor];
    CGFloat cornerRadius = 5;
    CGRect rect =CGRectMake(0,0,28,28);
    
    UIBezierPath*roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    roundedRect.lineWidth=0;
    
    UIGraphicsBeginImageContextWithOptions(rect.size,NO,0.0f);
    [color setFill];
    [roundedRect fill];
    [roundedRect stroke];
    [roundedRect addClip];
    
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSLog(@"searchBar.text---%@",searchBar.text);
    //存储搜索历史
    [self SearchText:searchBar.text];
    
    [self.searBar resignFirstResponder];
    //跳转搜索结果界面
    SearchViewController *controller = [KStory instantiateViewControllerWithIdentifier:@"ResultVC"];
    controller.searchWordNew  = searchBar.text;
    self.searBar.text = nil;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"%@",searchText);
   
    if ([searchText isEqualToString:@""]) {
        self.filterTableView.hidden = YES;
        [self readNSUserDefaults];
        [self.filterArray removeAllObjects];
        [self.filterTableView reloadData];
    }else{
        self.searchTableView.hidden = YES;
        self.clearView.hidden = YES;
        self.filterTableView.hidden = NO;
        
        if (self.filterArray.count>0) {
            //测试筛选功能,不在更新筛选tableview数据,此处再次输入数字过滤
            NSString *searchString = [self.searBar text];
            NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchString];
            if (self.filterResultArray!= nil) {
                [self.filterResultArray removeAllObjects];
            }
            //过滤数据
            self.filterResultArray = [NSMutableArray arrayWithArray:[self.filterArray filteredArrayUsingPredicate:preicate]];
            NSLog(@"筛选后的数组-%@",self.filterResultArray);
            //刷新表格
            [self.filterTableView reloadData];
        }else{
            [self.filterArray removeAllObjects];
            [self creatFilterData];
        }
    }
}

//创建筛选建议数据
- (void)creatFilterData{
    
    for (int i=0; i<20; i++) {
        NSString *filterStr = [NSString stringWithFormat:@"%@%d",self.searBar.text,i];
        [self.filterArray addObject:filterStr];
    }
    [self.filterTableView reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    NSLog(@"点击取消");

    self.searBar.text = nil;
    [searchBar resignFirstResponder];
    //返回上级界面
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (UITableView *)searchTableView{
    
    if (!_searchTableView) {
        
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,  64, KScreenWidth, KScreenHeight - 64) style:UITableViewStyleGrouped];
        [_searchTableView setDelegate:self];
        [_searchTableView setDataSource:self];
        _searchTableView.hidden = YES;
        
        _searchTableView.backgroundColor = [UIColor whiteColor];
        
        _searchTableView.estimatedRowHeight = 0;
        _searchTableView.estimatedSectionHeaderHeight = 0;
        _searchTableView.estimatedSectionFooterHeight = 0;
        
        //分割线颜色
        [_searchTableView setSeparatorColor:KRGBCOLOR(230, 230, 230)];
        
        //添加一个头视图
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, KScreenWidth, 75)];
        bgView.backgroundColor = [UIColor whiteColor];
     
        //热搜
        UILabel *hotSearchLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, KScreenWidth-44, 21)];
        hotSearchLabel.textAlignment = NSTextAlignmentLeft;
        hotSearchLabel.text = @"热搜";
        hotSearchLabel.font  = [UIFont boldSystemFontOfSize:16];
        [bgView addSubview:hotSearchLabel];
        
        //创建横向滑动scrollView
        UIScrollView *hotScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(hotSearchLabel.frame)+10, KScreenWidth, 30)];
        hotScrollView.backgroundColor = [UIColor whiteColor];
        hotScrollView.showsHorizontalScrollIndicator = NO;
        [bgView addSubview:hotScrollView];
        
        CGFloat w = 0;//保存前一个button的宽以及前一个button距离屏幕边缘的距离
        CGFloat sumW = 0;//最后一个w.确定contenSize
        
        for (int i = 0; i<self.hotDataArr.count; i++) {
            //button
            UIButton *searchBt = [UIButton buttonWithType:UIButtonTypeCustom];
            //moreCouseBt.backgroundColor = [UIColor redColor];
            searchBt.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            searchBt.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
            [searchBt setTitleColor:KRGBCOLOR(53, 53, 53) forState:UIControlStateNormal];
            [searchBt setBackgroundColor:KRGBCOLOR(230, 230, 230)];
            searchBt.layer.cornerRadius = 3;
            searchBt.tag = 200+i;
            [searchBt addTarget:self action:@selector(HotSearchForResult:) forControlEvents:UIControlEventTouchUpInside];

            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12.5]};
            CGFloat length = [self.hotDataArr[i] boundingRectWithSize:CGSizeMake(320, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
            //为button赋值
            [searchBt setTitle:self.hotDataArr[i] forState:UIControlStateNormal];
            searchBt.frame = CGRectMake(15+w,0,length+15,21);
            [searchBt.titleLabel setTextAlignment:NSTextAlignmentCenter];
            searchBt.titleLabel.font = [UIFont systemFontOfSize:12.5];
            
            w = searchBt.frame.size.width + searchBt.frame.origin.x;
            NSLog(@"%f",w);
            
            if (i==self.hotDataArr.count-1) {
                sumW = w;
            }
            
            [hotScrollView addSubview:searchBt];
        }
        
        hotScrollView.contentSize = CGSizeMake(sumW+15,30);
        
        //底部横线分割
        UIView *horLine = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetHeight(bgView.frame)-0.6,KScreenWidth, 0.6)];
        horLine.backgroundColor = TableLineColor;
        [bgView addSubview:horLine];
        
        _searchTableView.tableHeaderView = bgView;
        
        //尾视图
        self.footView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, KScreenWidth, 80)];
        self.footView .backgroundColor = [UIColor whiteColor];
        
        UIButton *clearBt = [UIButton buttonWithType:UIButtonTypeCustom];
        //moreCouseBt.backgroundColor = [UIColor redColor];
        clearBt.frame = CGRectMake(50,15,KScreenWidth-100,40);
        [clearBt setTitle:@"清空历史搜索" forState:UIControlStateNormal];
        [clearBt.titleLabel setTextAlignment:NSTextAlignmentCenter];
        clearBt.titleLabel.font = [UIFont systemFontOfSize:12.5];
        clearBt.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        clearBt.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        [clearBt setTitleColor:KRGBCOLOR(53, 53, 53) forState:UIControlStateNormal];
        [clearBt setBackgroundColor:[UIColor whiteColor]];
        clearBt.layer.cornerRadius = 2.5;
        clearBt.layer.borderWidth = 0.6;
        clearBt.layer.borderColor = [UIColor grayColor].CGColor;
        [clearBt addTarget:self action:@selector(clearAllTheHistory) forControlEvents:UIControlEventTouchUpInside];
        [self.footView  addSubview:clearBt];
        
        _searchTableView.tableFooterView = self.footView;
    }
    return _searchTableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{ //组数
     return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView==self.searchTableView) {
        if (section == 0){
            return self.historyArray.count;
        }else{
            return 1;
        }
    }else{
        if (self.filterResultArray.count>0) {
            return self.filterResultArray.count;//筛选后的数组
        }else{
            return self.filterArray.count;//筛选建议的数量
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView==self.searchTableView) {
        if (section == 0){
            return 45;
        }else{
            return 0;
        }
    }else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView==self.searchTableView) {
        UIView *headerView = [[UIView alloc]init];
        headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        if (section == 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, KScreenWidth, 35)];
            label.backgroundColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentLeft;
            label.font  = [UIFont boldSystemFontOfSize:16];
            [headerView addSubview:label];
            
            NSString *_test  =  @"历史搜索" ;
            NSMutableParagraphStyle *paraStyle01 = [[NSMutableParagraphStyle alloc] init];
            paraStyle01.alignment = NSTextAlignmentLeft;  //对齐
            paraStyle01.headIndent = 0.0f;//行首缩进
            //参数：（字体大小17号字乘以2，34f即首行空出两个字符）
            CGFloat emptylen = 10;
            paraStyle01.firstLineHeadIndent = emptylen;//首行缩进
            //    paraStyle01.tailIndent = 0.0f;//行尾缩进
            //    paraStyle01.lineSpacing = 2.0f;//行间距
            NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:_test attributes:@{NSParagraphStyleAttributeName:paraStyle01}];
            label.attributedText = attrText;
        }else{
            
        }
        return headerView;
    }else{
        return nil;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView==self.searchTableView) {
        static NSString *SEarchID = @"SEarchID";
        
        MGSwipeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:SEarchID];
        if (!cell) {
            cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SEarchID];
        }
        
        __weak typeof(self) weakSelf = self;
        //滑动删除历史
        MGSwipeButton *deleteButton = [MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell *sender) {
            NSIndexPath *indexPath = [_searchTableView indexPathForCell:cell];
            NSLog(@"indexPath is = %ld",indexPath.row);
            NSLog(@"删除历史");
            [weakSelf deleteHitstoryWithCellIndex:indexPath.row];
            return YES;
        }];
        
        [deleteButton.titleLabel setFont:[UIFont systemFontOfSize:15.5]];
        
        cell.rightButtons = @[deleteButton];
        
        [cell.textLabel setText:self.historyArray[indexPath.row]];
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        
        return cell;
    }else{
        static NSString *FilterID = @"FilterID";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FilterID];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FilterID];
        }
        if (self.filterResultArray.count>0) {
            [cell.textLabel setText:self.filterResultArray[indexPath.row]];
        }else{
            [cell.textLabel setText:self.filterArray[indexPath.row]];
        }
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        
        return cell;
    }
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView==self.searchTableView) {
        [self.searBar resignFirstResponder];
        
        //跳转搜索结果界面
        SearchViewController *controller = [KStory instantiateViewControllerWithIdentifier:@"ResultVC"];
        controller.searchWordNew  = self.historyArray[indexPath.row];
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        [self.searBar resignFirstResponder];
        
        //有筛选过滤结果
        if (self.filterResultArray.count>0) {
            [self SearchText:self.filterResultArray[indexPath.row]];
            //跳转搜索结果界面
            SearchViewController *controller = [KStory instantiateViewControllerWithIdentifier:@"ResultVC"];
            controller.searchWordNew  = self.filterResultArray[indexPath.row];
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            [self SearchText:self.filterArray[indexPath.row]];
            SearchViewController *controller = [KStory instantiateViewControllerWithIdentifier:@"ResultVC"];
            controller.searchWordNew  = self.filterArray[indexPath.row];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (UITableView *)filterTableView{
    
    if (!_filterTableView) {
        
        _filterTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenHeight-64) style:UITableViewStylePlain];
        [_filterTableView setDelegate:self];
        [_filterTableView setDataSource:self];
        [_filterTableView setTableFooterView:[UIView new]];
        [_filterTableView setHidden:YES];
    }
    return _filterTableView;
}


//读取本地记录
-(void)readNSUserDefaults{
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    //读取数组NSArray类型的数据
    self.historyArray = [userDefaultes arrayForKey:@"searchHistory"];
    [self.searchTableView reloadData];
    
    NSLog(@"historyArray--%@",self.historyArray);
    
    if (self.historyArray.count>0) {
        _searchTableView.hidden = NO;
        _clearView.hidden = YES;
    }else{
        _searchTableView.hidden = YES;
        _clearView.hidden = NO;
    }
}

//保存搜索记录
-(void)SearchText :(NSString *)seaTxt{
    
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    //读取数组NSArray类型的数据
    NSArray *myArray = [[NSArray alloc] initWithArray:[userDefaultes arrayForKey:@"searchHistory"]];
    
    // NSArray --> NSMutableArray
    NSMutableArray *searTXT = [NSMutableArray array];
    searTXT = [myArray mutableCopy];
    
    BOOL isEqualTo1,isEqualTo2;
    isEqualTo1 = NO;
    isEqualTo2 = NO;
    
    if (searTXT.count > 0) {
        isEqualTo2 = YES;
        //判断搜索内容是否存在，存在的话放到数组第一位，不存在的话添加。
        for (NSString * str in myArray) {
            if ([seaTxt isEqualToString:str]) {
                //获取指定对象的索引
                NSUInteger index = [myArray indexOfObject:seaTxt];
                [searTXT removeObjectAtIndex:index];
                [searTXT insertObject:seaTxt atIndex:0];
                //[searTXT addObject:seaTxt];
                isEqualTo1 = YES;
                break;
            }
        }
    }
    if (!isEqualTo1 || !isEqualTo2) {
        [searTXT insertObject:seaTxt atIndex:0];
        //[searTXT addObject:seaTxt];
    }
    //大于15去掉最后一个
    if(searTXT.count > 15){
        [searTXT removeObjectAtIndex:searTXT.count-1];
    }
    //将上述数据全部存储到NSUserDefaults中
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:searTXT forKey:@"searchHistory"];
}

//清空所有搜索记录
- (void)clearAllTheHistory{
 
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSArray * myArray = [userDefaultes arrayForKey:@"searchHistory"];
    NSMutableArray *searTXT = [myArray mutableCopy];
    [searTXT removeAllObjects];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:searTXT forKey:@"searchHistory"];
    
    [self readNSUserDefaults];
    
    _searchTableView.tableFooterView  = nil ;
}

//点击热搜
- (void)HotSearchForResult:(UIButton *)bt{
    //存储搜索历史
    [self SearchText:self.hotDataArr[bt.tag-200]];
    
    [self.searBar resignFirstResponder];
    //跳转搜索结果界面
    SearchViewController *controller = [KStory instantiateViewControllerWithIdentifier:@"ResultVC"];
    controller.searchWordNew  = self.hotDataArr[bt.tag-200];
    [self.navigationController pushViewController:controller animated:YES];
}

//清楚搜索历史后的clearview上点击热搜
- (void)HotSearchForResultInClearView:(UIButton *)bt{
    //存储搜索历史
    [self SearchText:self.hotDataArr[bt.tag-300]];
    
    [self.searBar resignFirstResponder];
    //跳转搜索结果界面
    SearchViewController *controller = [KStory instantiateViewControllerWithIdentifier:@"ResultVC"];
    controller.searchWordNew  = self.hotDataArr[bt.tag-300];
    [self.navigationController pushViewController:controller animated:YES];
}

//滑动删除单个历史记录
- (void)deleteHitstoryWithCellIndex:(NSInteger)index{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSArray * myArray = [userDefaultes arrayForKey:@"searchHistory"];
    NSMutableArray *searTXT = [myArray mutableCopy];
    [searTXT removeObjectAtIndex:index];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:searTXT forKey:@"searchHistory"];
    
    [self readNSUserDefaults];
}

- (NSArray *)historyArray{
    if (!_historyArray) {
        _historyArray = [NSArray array];
    }
    return _historyArray;
}

- (NSArray *)hotDataArr{
    if (!_hotDataArr) {
        _hotDataArr = [NSArray array];
    }
    return _hotDataArr;
}

- (NSMutableArray *)filterArray{
    if (!_filterArray) {
        _filterArray = [NSMutableArray array];
    }
    return _filterArray;
}

- (NSMutableArray *)filterResultArray{
    if (!_filterResultArray) {
        _filterResultArray = [NSMutableArray array];
    }
    return _filterResultArray;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
