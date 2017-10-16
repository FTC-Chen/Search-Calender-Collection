//
//  CalenderCell.m
//  CalendarNew
//
//  Created by anyongxue on 2017/10/13.
//  Copyright © 2017年 cc. All rights reserved.
//

#import "CalenderCell.h"

@implementation CalenderCell

- (UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.font = [UIFont systemFontOfSize:17];
        [self addSubview:_dateLabel];
    }
    return _dateLabel;
}

@end
