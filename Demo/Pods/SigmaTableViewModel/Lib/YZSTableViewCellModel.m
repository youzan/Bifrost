//
//  YZSTableViewCellModel.m
//  SmartTableView
//
//  Created by yangke on 8/25/15.
//  Copyright (c) 2015 yangke. All rights reserved.
//

#import "YZSTableViewCellModel.h"

@implementation YZSTableViewCellModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.height = UITableViewAutomaticDimension;
        self.shouldIndentWhileEditing = YES;
        self.shouldHighlight = YES;
        self.editingStyle = UITableViewCellEditingStyleDelete;
    }
    return self;
}

@end
