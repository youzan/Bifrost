//
//  YZSTableViewSectionModel.m
//  SmartTableView
//
//  Created by yangke on 8/25/15.
//  Copyright (c) 2015 yangke. All rights reserved.
//

#import "YZSTableViewSectionModel.h"

@implementation YZSTableViewSectionModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.headerHeight = UITableViewAutomaticDimension;
        self.footerHeight = UITableViewAutomaticDimension;
        self.cellModelArray = [NSMutableArray array];
    }
    return self;
}

- (void)setHeaderHeight:(CGFloat)headerHeight {
    if (headerHeight == 0) {
        // tableview will use default value if height is 0, so set it as the min float
        headerHeight = CGFLOAT_MIN;
    }
    _headerHeight = headerHeight;
}

- (void)setFooterHeight:(CGFloat)footerHeight {
    if (footerHeight == 0) {
        // tableview will use default value if height is 0, so set it as the min float
        footerHeight = CGFLOAT_MIN;
    }
    _footerHeight = footerHeight;
}

@end
