//
//  RootViewController.m
//  SearchWithHotHistory
//
//  Created by anyongxue on 2017/10/9.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"

#define KStory [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]
#define KScreenWidth [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface RootViewController ()<UISearchBarDelegate>

@property (nonatomic,strong)UISearchBar *searchBar;

@end

@implementation RootViewController

- (void)viewWillAppear:(BOOL)animated{
        
    [self.searchBar resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //创建导航栏
    [self creatNavi];
}

- (void)creatNavi{ 
    //创建导航栏
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth-30, 44)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"搜索";
    
    UIView *wrapView = [[UIView alloc] initWithFrame:self.searchBar.frame];
    [wrapView addSubview:self.searchBar];
    
    UIView *searchView = [[UIView alloc] initWithFrame:self.searchBar.frame];
    searchView.backgroundColor = [UIColor clearColor];
    //点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToTheSearchViewController)];
    [searchView addGestureRecognizer:tap];
    [wrapView addSubview:searchView];
    
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

- (void)jumpToTheSearchViewController{
    //进行跳转界面
    ViewController *controller = [KStory instantiateViewControllerWithIdentifier:@"SearchVC"];
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:controller];
    navVC.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:navVC animated:NO completion:nil];
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
