//
//  YZSTableViewSectionModel.h
//  SmartTableView
//
//  Created by yangke on 8/25/15.
//  Copyright (c) 2015 yangke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YZSTableViewCellModel.h"

typedef UIView * (^YZSViewRenderBlock)(NSInteger section, UITableView *tableView);

/** Table view's section model */
@interface YZSTableViewSectionModel : NSObject

@property (nonatomic, strong) NSMutableArray<YZSTableViewCellModel *> *cellModelArray;
@property (nonatomic, strong) NSString *headerTitle;  // optional
@property (nonatomic, strong) NSString *footerTitle;  // optional
// if not specified, will use UITableViewAutomaticDimension as default value
@property (nonatomic, assign) CGFloat headerHeight;  // optional
@property (nonatomic, assign) CGFloat footerHeight;  // optional

// view render blocks' priority is higher then view property.
// e.g. if headerViewRenderBlock and headerView are both provided, headerViewRenderBlock will be
// used
@property (nonatomic, copy) YZSViewRenderBlock headerViewRenderBlock;  // block to render header
// view
@property (nonatomic, copy) YZSViewRenderBlock footerViewRenderBlock;  // block to render footer
// view
@property (nonatomic, strong) UIView *headerView;  // section header view
@property (nonatomic, strong) UIView *footerView;  // section footer view
@property (nonatomic, strong) NSString *key;       // optional, used to identify the model

@end
