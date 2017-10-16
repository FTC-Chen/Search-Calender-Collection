//
//  CalenderView.h
//  CalendarNew
//
//  Created by anyongxue on 2017/10/13.
//  Copyright © 2017年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalenderView : UIView<UICollectionViewDelegate , UICollectionViewDataSource>

@property (nonatomic,strong) NSDate *date;
@property (nonatomic,strong) NSDate *today;

@property (nonatomic,strong) void(^calenderBlock)(NSInteger day, NSInteger month ,NSInteger year);

+ (instancetype)showOnView:(UIView *)view;

@end
