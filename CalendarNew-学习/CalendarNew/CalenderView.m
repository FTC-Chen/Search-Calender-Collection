//
//  CalenderView.m
//  CalendarNew
//
//  Created by anyongxue on 2017/10/13.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CalenderView.h"
#import "CalenderCell.h"
#import "UIColor+ZXLazy.h"

NSString *const CalendarCellIdentifier = @"cell";

@interface CalenderView ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic , strong) NSArray *weekDayArray;
@property (nonatomic , strong) UIView *mask;
@property (nonatomic , strong) NSMutableArray *selectedArr;
@end

@implementation CalenderView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSLog(@"作用drawRect");
    [self addTapMaskView];
    [self addSwipe];
    [self show];
}

- (void)awakeFromNib{
    [super awakeFromNib];
    NSLog(@"加载nib");
    [_collectionView registerClass:[CalenderCell class] forCellWithReuseIdentifier:CalendarCellIdentifier];
    _weekDayArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
}

- (void)customInterface{
    NSLog(@"添加布局");
    
    CGFloat itemWidth = (_collectionView.frame.size.width-5) / 7;
    CGFloat itemHeight = _collectionView.frame.size.height / 7;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [_collectionView setCollectionViewLayout:layout animated:YES];
}

#pragma -mark collectionView delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return _weekDayArray.count;
    } else {
        return 42;//??不必执行42次
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CalenderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CalendarCellIdentifier forIndexPath:indexPath];
    cell.backgroundColor  = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        [cell.dateLabel setText:_weekDayArray[indexPath.row]];
        [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#15cc9c"]];
    }else{
        cell.dateLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
        
        NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
        //NSLog(@"daysInThisMonth-%ld",daysInThisMonth);
        NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
        //NSLog(@"firstWeekday-%ld",firstWeekday);//0 周日在0位置
        
        NSInteger day = 0;
        NSInteger i = indexPath.row;
        
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.date];
        
        if (i < firstWeekday) {
            [cell.dateLabel setText:@""];
        } else if (i > firstWeekday + daysInThisMonth - 1){
            [cell.dateLabel setText:@""];
        } else {
            day = i - firstWeekday + 1;
            [cell.dateLabel setText:[NSString stringWithFormat:@"%li",(long)day]];
            [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#6f6f6f"]];//111,111,111
            
            //this month
            if ([_today isEqualToDate:_date]) {
                if (day == [self day:_date]) {//当天
                    [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#15cc9c"]];
                } else if(day > [self day:_date]){//超过当天
                    [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#cbcbcb"]];
                }
            }else if([_today compare:_date] == NSOrderedAscending){
                [cell.dateLabel setTextColor:[UIColor colorWithHexString:@"#cbcbcb"]];
            }
            
            //
            NSString *dateStr = [NSString stringWithFormat:@"%ld%ld%ld",[comp year],[comp month],day];
            if ([self.selectedArr containsObject:dateStr]) {
                NSLog(@"已经选中 %@",dateStr);
                cell.backgroundColor = [UIColor colorWithHexString:@"#4898eb"];
                cell.isSelected = YES;
            }else{
                cell.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
                cell.isSelected = NO;
            }
        }
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        NSInteger daysInThisMonth = [self totaldaysInMonth:_date];
        NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
        // NSLog(@"点击- daysInThisMonth-%ld",daysInThisMonth);
        // NSLog(@"点击- firstWeekday-%ld",firstWeekday);
        
        NSInteger day = 0;
        NSInteger i = indexPath.row;
        
        if (i >= firstWeekday && i <= firstWeekday + daysInThisMonth - 1) {
            day = i - firstWeekday + 1;
            //this month
            if ([_today isEqualToDate:_date]) {
                if (day <= [self day:_date]) {
                    return YES;
                }else{
                    return YES;
                }
            }else if ([_today compare:_date] == NSOrderedDescending){
                return YES;
            }else if ([_today compare:_date] == NSOrderedAscending){
                return YES;
            }
        }
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    //点击选中的效果
    CalenderCell *cell = (CalenderCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.date];
    NSInteger firstWeekday = [self firstWeekdayInThisMonth:_date];
    
    NSInteger day = 0;
    NSInteger i = indexPath.row;
    day = i - firstWeekday + 1;
    if (self.calenderBlock) {
        self.calenderBlock(day, [comp month], [comp year]);
    }
    
    NSString *dateStr = [NSString stringWithFormat:@"%ld%ld%ld",[comp year],[comp month],day];
    NSLog(@"dateStr -- %@",dateStr);
    
    if (cell.isSelected == NO) {
        cell.isSelected = YES;
        cell.backgroundColor = [UIColor colorWithHexString:@"#4898eb"];
        [self.selectedArr addObject:dateStr];
    }else if (cell.isSelected == YES){
        cell.isSelected = NO;
        cell.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        [self.selectedArr removeObject:dateStr];
    }
    
    NSLog(@"-- %@",self.selectedArr);
}

//单元格与屏幕边缘的空隙
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 2.5, 0, 2.5);
}

- (void)setDate:(NSDate *)date{
    NSLog(@"day- %.2ld",(long)[self day:date]);
    NSLog(@"month- %.2ld",(long)[self month:date]);
    NSLog(@"year- %.2ld",(long)[self year:date]);
    
    _date = date;
    [_monthLabel setText:[NSString stringWithFormat:@"%.2ld-%li",(long)[self year:date],(long)[self month:date]]];
    [_collectionView reloadData];
}

+ (instancetype)showOnView:(UIView *)view{
    CalenderView *calendarView = [[[NSBundle mainBundle] loadNibNamed:@"CalenderView" owner:self options:nil] firstObject];
    calendarView.mask = [[UIView alloc] initWithFrame:view.bounds];
    calendarView.mask.backgroundColor = [UIColor blackColor];
    calendarView.mask.alpha = 0.3;
    [view addSubview:calendarView.mask];
    [view addSubview:calendarView];
    return calendarView;
}

- (void)addTapMaskView{
    NSLog(@"添加点击");
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self.mask addGestureRecognizer:tap];
}

- (void)show{
    //提前布局
    [self customInterface];
    
    self.transform = CGAffineTransformTranslate(self.transform, 0, -CGRectGetMaxY(self.frame));
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL isFinished) {
        [self customInterface];
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.5 animations:^(void) {
        self.transform = CGAffineTransformTranslate(self.transform, 0, -CGRectGetMaxY(self.frame));
        self.mask.alpha = 0;
    } completion:^(BOOL isFinished) {
        [self.mask removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)addSwipe
{
    UISwipeGestureRecognizer *swipLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextDate:)];
    swipLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipLeft];
    
    UISwipeGestureRecognizer *swipRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousDate:)];
    swipRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipRight];
}

//上月  //UIViewAnimationOptionTransitionFlipFromRight 旋转 类似网易云音乐的
       //UIViewAnimationOptionTransitionFlipFromTop   上下旋转
       //UIViewAnimationOptionPreferredFramesPerSecond30 直接显示
- (IBAction)previousDate:(id)sender {
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlDown animations:^(void) {
        self.date = [self lastMonth:self.date];
    } completion:nil];
}

//下月
- (IBAction)nextDate:(id)sender {
    [UIView transitionWithView:self duration:0.5 options:UIViewAnimationOptionTransitionCurlUp animations:^(void) {
        self.date = [self nextMonth:self.date];
    } completion:nil];
}


#pragma mark - date
- (NSInteger)day:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components day];
}

- (NSInteger)month:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components month];
}

- (NSInteger)year:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components year];
}

//这个月有多少天
- (NSInteger)totaldaysInMonth:(NSDate *)date{
    NSRange daysInLastMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInLastMonth.length;
}

//方法未用到
- (NSInteger)totaldaysInThisMonth:(NSDate *)date{
    NSRange totaldaysInMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return totaldaysInMonth.length;
}

//第一天是周几
- (NSInteger)firstWeekdayInThisMonth:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}

//上一月
- (NSDate *)lastMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

//下一月
- (NSDate*)nextMonth:(NSDate *)date{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = +1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

- (NSMutableArray *)selectedArr{
    if (!_selectedArr) {
        _selectedArr = [NSMutableArray array];
    }
    return _selectedArr;
}
@end
