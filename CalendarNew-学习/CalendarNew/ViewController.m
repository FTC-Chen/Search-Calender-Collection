//
//  ViewController.m
//  CalendarNew
//
//  Created by anyongxue on 2017/10/13.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "ViewController.h"
#import "CalenderView.h"

#define KScreenWidth [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取当前时间日期
    NSDate *date=[NSDate date];
    NSDateFormatter *format1=[[NSDateFormatter alloc] init];
    [format1 setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateStr;
    dateStr=[format1 stringFromDate:date];
    NSLog(@"%@",dateStr);
    
    //这个月有几天
    NSRange totaldaysInMonth  = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    NSLog(@"%ld",totaldaysInMonth.length);
    
    //这一天是周几
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear |NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate*firstDayOfMonthDate = [calendar dateFromComponents:comp];
    NSUInteger firstWeeked = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    NSLog(@"%ld",firstWeeked-1);
    
    //日历控件
}

- (IBAction)showCalenderAction:(id)sender {
    CalenderView *calender = [CalenderView showOnView:self.view];
    calender.today = [NSDate date];
    calender.date = calender.today;
    calender.frame = CGRectMake(0, 100, KScreenWidth, 352);
    calender.calenderBlock = ^(NSInteger day, NSInteger month, NSInteger year){
        NSLog(@"%ld-%ld-%ld",year,month,day);
    };
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
