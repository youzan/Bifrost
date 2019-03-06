//
//  YZSTableViewModel.m
//  SmartTableView
//
//  Created by yangke on 8/25/15.
//  Copyright (c) 2015 yangke. All rights reserved.
//

#import "YZSTableViewModel.h"

#define YZSLogException(exception)                                                                 \
    NSLog(@"%s [Line %d]: %@", __PRETTY_FUNCTION__, __LINE__, (exception))

@implementation YZSTableViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sectionModelArray = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithTableView:(UITableView*)tableView
                      andDelegate:(id<YZSTableViewModelDelegate>)delegate {
    self = [super init];
    if (self) {
        self.sectionModelArray = [NSMutableArray array];
        self.delegate = delegate;
        tableView.dataSource = self;
        tableView.delegate = self;
    }
    return self;
}

#pragma mark - Private Methods
- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL response = [super respondsToSelector:aSelector] || [self.delegate respondsToSelector:aSelector];
    return response;
}
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.delegate respondsToSelector:aSelector]) {
        return self.delegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}
- (YZSTableViewSectionModel*)sectionModelAtSection:(NSInteger)section {
    @try {
        YZSTableViewSectionModel *sectionModel = self.sectionModelArray[section];
        return sectionModel;
    }
    @catch (NSException *exception) {
        YZSLogException(exception);
        return nil;
    }
}

- (YZSTableViewCellModel*)cellModelAtIndexPath:(NSIndexPath *)indexPath {
    @try {
        YZSTableViewSectionModel *sectionModel = self.sectionModelArray[indexPath.section];
        YZSTableViewCellModel *cellModel = sectionModel.cellModelArray[indexPath.row];
        return cellModel;
    }
    @catch (NSException *exception) {
        YZSLogException(exception);
        return nil;
    }
}

- (NSInteger)indexForSectionKey:(NSString *)key {
    NSInteger index = NSNotFound;
    if (key.length > 0) {
        NSInteger i = 0;
        for (YZSTableViewSectionModel *sectionModel in self.sectionModelArray) {
            if ([key isEqualToString:sectionModel.key]) {
                index = i;
                break;
            }
            i++;
        }
    }
    return index;
}

- (NSIndexPath *)indexPathForRowKey:(NSString *)key {
    NSIndexPath *indexPath = nil;
    if (key.length > 0) {
        NSInteger row = 0, section = 0;
        for (YZSTableViewSectionModel *sectionModel in self.sectionModelArray) {
            for (YZSTableViewCellModel *cellModel in sectionModel.cellModelArray) {
                if ([key isEqualToString:cellModel.key]) {
                    indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                    break;
                }
                row++;
            }
            if (indexPath) {
                break;
            }
            // check next section
            section++;
            row = 0;
        }
    }
    return indexPath;
}

#pragma mark - Public Methods
- (YZSTableViewSectionModel *)sectionModelForKey:(NSString *)sectionKey {
    @try {
        YZSTableViewSectionModel *model = nil;
        NSInteger index = [self indexForSectionKey:sectionKey];
        if (index != NSNotFound) {
            model = self.sectionModelArray[index];
        }
        return model;
    } @catch (NSException *exception) {
        YZSLogException(exception);
        return nil;
    }
}

- (YZSTableViewCellModel *)cellModelForKey:(NSString *)rowKey {
    @try {
        NSIndexPath *indexPath = [self indexPathForRowKey:rowKey];
        if (indexPath) {
            YZSTableViewSectionModel *sectionModel = self.sectionModelArray[indexPath.section];
            YZSTableViewCellModel *cellModel = sectionModel.cellModelArray[indexPath.row];
            return cellModel;
        } else {
            return nil;
        }
    } @catch (NSException *exception) {
        YZSLogException(exception);
        return nil;
    }
}

- (void)insertSectionModels:(NSArray<YZSTableViewSectionModel *> *)sectionModels
                     before:(BOOL)before
                sectionKeys:(NSArray<NSString *> *)keys
                inTableView:(UITableView *)tableView
           withRowAnimation:(UITableViewRowAnimation)animation {
    if (sectionModels.count == 0 || tableView == nil || sectionModels.count != keys.count) {
        return;
    }
    @try {
        // insert models
        NSMutableArray *validModels = [NSMutableArray arrayWithCapacity:sectionModels.count];
        for (NSInteger i = 0; i < keys.count; i++) {
            NSString *key = keys[i];
            NSInteger index = [self indexForSectionKey:key];
            if (index == NSNotFound) {
                continue;
            }
            YZSTableViewSectionModel *newModel = sectionModels[i];
            if (!before) {
                index++;
            }
            [self.sectionModelArray insertObject:newModel atIndex:index];
            [validModels addObject:newModel];
        }
        // get index after new models are inserted
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (YZSTableViewSectionModel *model in validModels) {
            NSInteger index = [self.sectionModelArray indexOfObject:model];
            if (index != NSNotFound) {
                [indexSet addIndex:index];
            }
        }
        // update table view
        if (validModels.count > 0 && validModels.count == indexSet.count) {
            [tableView insertSections:indexSet withRowAnimation:animation];
        }
    } @catch (NSException *exception) {
        YZSLogException(exception);
        return;
    }
}
- (void)deleteSectionModelsWithKeys:(NSArray<NSString *> *)sectionKeys
                        inTableView:(UITableView *)tableView
                   withRowAnimation:(UITableViewRowAnimation)animation {
    if (sectionKeys.count == 0 || tableView == nil) {
        return;
    }
    @try {
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (NSInteger i = 0; i < sectionKeys.count; i++) {
            NSString *key = sectionKeys[i];
            NSInteger index = [self indexForSectionKey:key];
            if (index == NSNotFound) {
                continue;
            }
            [indexSet addIndex:index];
        }
        if (indexSet.count > 0) {
            [self.sectionModelArray removeObjectsAtIndexes:indexSet];
            [tableView deleteSections:indexSet withRowAnimation:animation];
        }
    } @catch (NSException *exception) {
        YZSLogException(exception);
        return;
    }
}

- (void)reloadSectionModels:(NSArray<YZSTableViewSectionModel *> *)sectionModels
             forSectionKeys:(NSArray<NSString *> *)keys
                inTableView:(UITableView *)tableView
           withRowAnimation:(UITableViewRowAnimation)animation {
    if (sectionModels.count == 0 || tableView == nil || sectionModels.count != keys.count) {
        return;
    }
    @try {
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        for (NSInteger i = 0; i < keys.count; i++) {
            NSString *key = keys[i];
            NSInteger index = [self indexForSectionKey:key];
            if (index == NSNotFound) {
                continue;
            }
            YZSTableViewSectionModel *newModel = sectionModels[i];
            [self.sectionModelArray replaceObjectAtIndex:index withObject:newModel];
            [indexSet addIndex:index];
        }
        if (indexSet.count > 0) {
            [tableView reloadSections:indexSet withRowAnimation:animation];
        }
    } @catch (NSException *exception) {
        YZSLogException(exception);
        return;
    }
}

- (void)insertCellModels:(NSArray<YZSTableViewCellModel *> *)cellModels
                  before:(BOOL)before
                cellKeys:(NSArray<NSString *> *)keys
             inTableView:(UITableView *)tableView
        withRowAnimation:(UITableViewRowAnimation)animation {
    if (cellModels.count == 0 || tableView == nil || cellModels.count != keys.count) {
        return;
    }
    @try {
        NSMutableArray *indexArray = [NSMutableArray arrayWithCapacity:cellModels.count];
        NSMutableArray *validModels = [NSMutableArray arrayWithCapacity:cellModels.count];
        for (NSInteger i = 0; i < keys.count; i++) {
            NSString *key = keys[i];
            NSIndexPath *indexPath = [self indexPathForRowKey:key];
            if (!indexPath) {
                continue;
            }
            YZSTableViewCellModel *newModel = cellModels[i];
            YZSTableViewSectionModel *sectionModel = self.sectionModelArray[indexPath.section];
            if (!before) {
                indexPath =
                [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            }
            [sectionModel.cellModelArray insertObject:newModel atIndex:indexPath.row];
            [validModels addObject:newModel];
            [indexArray addObject:@(indexPath.section)];
        }

        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:cellModels.count];
        for (NSInteger i = 0; i < validModels.count; i++) {
            YZSTableViewCellModel *model = validModels[i];
            NSInteger section = [indexArray[i] integerValue];
            YZSTableViewSectionModel *sectionModel = self.sectionModelArray[section];
            NSInteger row = [sectionModel.cellModelArray indexOfObject:model];
            if (row != NSNotFound) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
            }
        }
        if (indexPaths.count > 0 && indexPaths.count == validModels.count) {
            [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        }
    } @catch (NSException *exception) {
        YZSLogException(exception);
        return;
    }
}

- (void)deleteCellModelsWithKeys:(NSArray<NSString *> *)cellKeys
                     inTableView:(UITableView *)tableView
                withRowAnimation:(UITableViewRowAnimation)animation {
    if (cellKeys.count == 0 || tableView == nil) {
        return;
    }
    @try {
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:cellKeys.count];
        for (NSInteger i = 0; i < cellKeys.count; i++) {
            NSString *key = cellKeys[i];
            NSIndexPath *indexPath = [self indexPathForRowKey:key];
            if (!indexPath) {
                continue;
            }
            [indexPaths addObject:indexPath];
        }
        [indexPaths sortUsingComparator:^NSComparisonResult(NSIndexPath *indexPath1, NSIndexPath *indexPath2) {
            if (indexPath1.section > indexPath2.section) {
                return NSOrderedDescending;
            } else if (indexPath1.section < indexPath2.section) {
                return NSOrderedAscending;
            } else {
                if (indexPath1.row > indexPath2.row) {
                    return NSOrderedDescending;
                } else if (indexPath1.row < indexPath2.row) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedSame;
                }
            }
        }];
        for (NSIndexPath *indexPath in [indexPaths reverseObjectEnumerator]) {
            YZSTableViewSectionModel *sectionModel = self.sectionModelArray[indexPath.section];
            [sectionModel.cellModelArray removeObjectAtIndex:indexPath.row];
        }
        if (indexPaths.count > 0) {
            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        }
    } @catch (NSException *exception) {
        YZSLogException(exception);
        return;
    }
}

- (void)reloadCellModels:(NSArray<YZSTableViewCellModel *> *)cellModels
             forCellKeys:(NSArray<NSString *> *)keys
             inTableView:(UITableView *)tableView
        withRowAnimation:(UITableViewRowAnimation)animation {
    if (cellModels.count == 0 || tableView == nil || cellModels.count != keys.count) {
        return;
    }
    @try {
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:cellModels.count];
        for (NSInteger i = 0; i < keys.count; i++) {
            NSString *key = keys[i];
            NSIndexPath *indexPath = [self indexPathForRowKey:key];
            if (!indexPath) {
                continue;
            }
            YZSTableViewCellModel *newModel = cellModels[i];
            YZSTableViewSectionModel *sectionModel = self.sectionModelArray[indexPath.section];
            [sectionModel.cellModelArray replaceObjectAtIndex:indexPath.row withObject:newModel];
            [indexPaths addObject:indexPath];
        }
        if (indexPaths.count > 0) {
            [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
        }
    } @catch (NSException *exception) {
        YZSLogException(exception);
        return;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDataSource>)self.delegate numberOfSectionsInTableView:tableView];
    }
    return self.sectionModelArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDataSource>)self.delegate tableView:tableView
                                             numberOfRowsInSection:section];
    }
    YZSTableViewSectionModel *sectionModel = [self sectionModelAtSection:section];
    return sectionModel.cellModelArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDataSource>)self.delegate tableView:tableView
                                             cellForRowAtIndexPath:indexPath];
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    UITableViewCell *cell = cellModel.renderBlock(indexPath, tableView);
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDataSource>)self.delegate tableView:tableView
                                           titleForHeaderInSection:section];
    }
    YZSTableViewSectionModel *sectionModel = [self sectionModelAtSection:section];
    return sectionModel.headerTitle;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDataSource>)self.delegate tableView:tableView
                                           titleForFooterInSection:section];
    }
    YZSTableViewSectionModel *sectionModel = [self sectionModelAtSection:section];
    return sectionModel.footerTitle;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDataSource>)self.delegate tableView:tableView
                                             canEditRowAtIndexPath:indexPath];
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    return cellModel.canEdit;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UITableViewDataSource>)self.delegate tableView:tableView
                                         commitEditingStyle:editingStyle
                                          forRowAtIndexPath:indexPath];
        return;
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    YZSCellEditingStyleBlock commitEditBlock = cellModel.commitEditBlock;
    if (commitEditBlock) {
        commitEditBlock(indexPath, tableView, editingStyle);
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                         heightForRowAtIndexPath:indexPath];
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    CGFloat height = cellModel.height;
    if (cellModel.cellHeightBlock) {
        height = cellModel.cellHeightBlock(indexPath, tableView);
    }
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                        heightForHeaderInSection:section];
    }
    YZSTableViewSectionModel *sectionModel = [self sectionModelAtSection:section];
    return sectionModel.headerHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                        heightForFooterInSection:section];
    }
    YZSTableViewSectionModel *sectionModel = [self sectionModelAtSection:section];
    return sectionModel.footerHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                          viewForHeaderInSection:section];
    }
    YZSTableViewSectionModel *sectionModel = [self sectionModelAtSection:section];
    YZSViewRenderBlock headerViewRenderBlock = sectionModel.headerViewRenderBlock;
    if (headerViewRenderBlock) {
        return headerViewRenderBlock(section, tableView);
    } else {
        return sectionModel.headerView;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                          viewForFooterInSection:section];
    }
    YZSTableViewSectionModel *sectionModel = [self sectionModelAtSection:section];
    YZSViewRenderBlock footerViewRenderBlock = sectionModel.footerViewRenderBlock;
    if (footerViewRenderBlock) {
        return footerViewRenderBlock(section, tableView);
    } else {
        return sectionModel.footerView;
    }
}
- (nullable NSIndexPath *)tableView:(UITableView *)tableView
           willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                        willSelectRowAtIndexPath:indexPath];
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    YZSCellIndexPathBlock willSelectBlock = cellModel.willSelectBlock;
    if (willSelectBlock) {
        return willSelectBlock(indexPath, tableView);
    }
    return indexPath;
}
- (nullable NSIndexPath *)tableView:(UITableView *)tableView
         willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                      willDeselectRowAtIndexPath:indexPath];
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    YZSCellIndexPathBlock willDeselectBlock = cellModel.willDeselectBlock;
    if (willDeselectBlock) {
        return willDeselectBlock(indexPath, tableView);
    }
    return indexPath;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                  didSelectRowAtIndexPath:indexPath];
        return;
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    YZSCellVoidBlock selectionBlock = cellModel.selectionBlock;
    if (selectionBlock) {
        selectionBlock(indexPath, tableView);
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                didDeselectRowAtIndexPath:indexPath];
        return;
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    YZSCellVoidBlock deselectionBlock = cellModel.deselectionBlock;
    if (deselectionBlock) {
        deselectionBlock(indexPath, tableView);
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView
               titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
     YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    return cellModel.deleteConfirmationButtonTitle;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                          willDisplayCell:cell
                                        forRowAtIndexPath:indexPath];
        return;
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    YZSCellDisplayBlock willDisplayBlock = cellModel.willDisplayBlock;
    if (willDisplayBlock) {
        willDisplayBlock(cell, indexPath, tableView);
    }
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                     shouldHighlightRowAtIndexPath:indexPath];
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    YZSCellBoolBlock block = cellModel.shouldHighlightBlock;
    if (block) {
        return block(indexPath,tableView);
    } else {
        return cellModel.shouldHighlight;
    }
}
- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UITableViewDelegate>)self.delegate tableView:tableView
                               didHighlightRowAtIndexPath:indexPath];
        return;
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    YZSCellVoidBlock block = cellModel.didHighlightBlock;
    if (block) {
        block(indexPath,tableView);
    }
}
- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UITableViewDelegate>)self.delegate tableView:tableView
                             didUnhighlightRowAtIndexPath:indexPath];
        return;
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    YZSCellVoidBlock block = cellModel.didUnhighlightBlock;
    if (block) {
        block(indexPath,tableView);
    }
}
- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UITableViewDelegate>)self.delegate tableView:tableView
                           willBeginEditingRowAtIndexPath:indexPath];
        return;
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    YZSCellVoidBlock block = cellModel.willBeginEditingBlock;
    if (block) {
        block(indexPath,tableView);
    }
}
- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UITableViewDelegate>)self.delegate tableView:tableView
                              didEndEditingRowAtIndexPath:indexPath];
        return;
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    YZSCellVoidBlock block = cellModel.didEndEditingBlock;
    if (block) {
        block(indexPath,tableView);
    }
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        [(id<UITableViewDelegate>)self.delegate tableView:tableView
                 accessoryButtonTappedForRowWithIndexPath:indexPath];
        return;
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    YZSCellVoidBlock block = cellModel.accessoryButtonTappedBlock;
    if (block) {
        block(indexPath,tableView);
    }
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView
                          shouldIndentWhileEditingRowAtIndexPath:indexPath];
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    return cellModel.shouldIndentWhileEditing;
}
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                    editActionsForRowAtIndexPath:indexPath];
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    return cellModel.editActions;
}
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                 shouldShowMenuForRowAtIndexPath:indexPath];
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    return cellModel.shouldShowMenu;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:_cmd]) {
        return [(id<UITableViewDelegate>)self.delegate tableView:tableView
                                 editingStyleForRowAtIndexPath:indexPath];
    }
    YZSTableViewCellModel *cellModel = [self cellModelAtIndexPath:indexPath];
    return cellModel.editingStyle;
}

@end
