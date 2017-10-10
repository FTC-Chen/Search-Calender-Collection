//
//  SearchViewController.m
//  SearchWithHotHistory
//
//  Created by anyongxue on 2017/10/9.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "SearchViewController.h"
#import "ViewController.h"
#import "RootViewController.h"

#define KStory [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]
#define KScreenWidth [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight [[UIScreen mainScreen] bounds].size.height
@interface SearchViewController ()<UISearchBarDelegate>

@property (nonatomic,strong)UISearchBar *searchBar;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //创建导航栏
    [self creatNavi];

}

- (void)creatNavi{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"fanhui"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    //创建导航栏
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth-44*2, 44)];
    self.searchBar.delegate = self;
    self.searchBar.text = self.searchWordNew;
    
    UIView *wrapView = [[UIView alloc] initWithFrame:self.searchBar.frame];
    [wrapView addSubview:self.searchBar];
    
    UIView *searchView = [[UIView alloc] initWithFrame:self.searchBar.frame];
    searchView.backgroundColor = [UIColor clearColor];
    //点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpBackViewController)];
    [searchView addGestureRecognizer:tap];
    [wrapView addSubview:searchView];
    
    [[UISearchBar appearance] setSearchFieldBackgroundImage:[self searchFieldBackgroundImage] forState:UIControlStateNormal];
    [[UISearchBar appearance] setSearchFieldBackgroundImage:[self searchFieldBackgroundImage] forState:UIControlStateNormal];
    UITextField *txfSearchField = [self.searchBar valueForKey:@"_searchField"];
    [txfSearchField setDefaultTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.5]}];
    
    self.searchBar.searchTextPositionAdjustment = UIOffsetMake(7, 0);
    self.navigationItem.titleView = wrapView;
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

- (void)jumpBackViewController{
    NSDictionary* dic =@{@"word":self.searchBar.text};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"backToSearchVCWord" object:nil userInfo:dic];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:NO];
    });
}



- (void)backAction{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"backToRootVC" object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.55 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
