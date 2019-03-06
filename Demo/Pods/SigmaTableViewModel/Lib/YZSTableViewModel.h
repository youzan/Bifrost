//
//  YZSTableViewModel.h
//  SmartTableView
//
//  Created by yangke on 8/25/15.
//  Copyright (c) 2015 yangke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YZSTableViewSectionModel.h"

/**
 用于补充未实现的UITableViewDataSource和UITableViewDelegate的方法
 为了避免没有添加required的方法出现警告所以没有直接继承他们。
 本protocol的对象所实现的所有UITableViewDataSource和UITableViewDelegate方法都会被YZSTableViewModel优先使用
 （类似子类override的作用）
 */
@protocol YZSTableViewModelDelegate<NSObject>
@end

/**
 *  YZSTableViewModel implements some methods in UITableViewDelegate & UITableViewDataSource.
 *  it can be used as the delegate & dataSource of a tableView.
 *  For those methods it doesn't implement, you can implement them in its subclass.
 */
@interface YZSTableViewModel : NSObject <UITableViewDelegate, UITableViewDataSource>
/** table view's section model array */
@property (nonatomic, strong) NSMutableArray<YZSTableViewSectionModel *> *sectionModelArray;
/**
 用于补充更多的UITableViewDataSource/UITableViewDelegate实现。
 如果delegate有相应实现，YZSTableViewModel会优先使用delegate的实现(类似override的效果)。
 注：请在设置tableview的dataSource和delegat之前设置好delegate！
 因为它们的setter方法会触发responseToSelector系列检查。 如果设置本delegate较晚，则tableview会认为有些方法没有实现。
 */
@property (nonatomic, weak) id <YZSTableViewModelDelegate> delegate; //optional

/**
 @param tableView required
 @param delegate optional, can be nil
 @return view model instance
 */
- (instancetype)initWithTableView:(UITableView*)tableView
                      andDelegate:(id<YZSTableViewModelDelegate>)delegate;

// Methods to get view model by key
- (YZSTableViewSectionModel *)sectionModelForKey:(NSString *)sectionKey;
- (YZSTableViewCellModel *)cellModelForKey:(NSString *)rowKey;

// Methods to manage section models directly, and to support row animation
// Following methods are NOT thread safe!!! Don't invoke them in different threads at the same time.
- (void)insertSectionModels:(NSArray<YZSTableViewSectionModel *> *)sectionModels
                     before:(BOOL)before
                sectionKeys:(NSArray<NSString *> *)keys
                inTableView:(UITableView *)tableView
           withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadSectionModels:(NSArray<YZSTableViewSectionModel *> *)sectionModels
             forSectionKeys:(NSArray<NSString *> *)keys
                inTableView:(UITableView *)tableView
           withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteSectionModelsWithKeys:(NSArray<NSString *> *)sectionKeys
                        inTableView:(UITableView *)tableView
                   withRowAnimation:(UITableViewRowAnimation)animation;

// Methods to manage cell models directly, and to support row animation
// Following methods are not thread safe!!! Don't invoke them in different threads at the same time.
- (void)insertCellModels:(NSArray<YZSTableViewCellModel *> *)cellModels
                  before:(BOOL)before
                cellKeys:(NSArray<NSString *> *)keys
             inTableView:(UITableView *)tableView
        withRowAnimation:(UITableViewRowAnimation)animation;
- (void)reloadCellModels:(NSArray<YZSTableViewCellModel *> *)cellModels
             forCellKeys:(NSArray<NSString *> *)keys
             inTableView:(UITableView *)tableView
        withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteCellModelsWithKeys:(NSArray<NSString *> *)cellKeys
                     inTableView:(UITableView *)tableView
                withRowAnimation:(UITableViewRowAnimation)animation;

@end
