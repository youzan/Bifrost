//
//  YZSTableViewCellModel.h
//  SmartTableView
//
//  Created by yangke on 8/25/15.
//  Copyright (c) 2015 yangke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef CGFloat (^YZSCellHeightBlock)(NSIndexPath *_Nonnull indexPath,
                                      UITableView *_Nonnull tableView);
typedef void (^YZSCellVoidBlock)(NSIndexPath *_Nonnull indexPath,
                                 UITableView *_Nonnull tableView);
typedef BOOL (^YZSCellBoolBlock)(NSIndexPath *_Nonnull indexPath,
                                 UITableView *_Nonnull tableView);
typedef UITableViewCell *_Nonnull (^YZSCellRenderBlock)(NSIndexPath *_Nonnull indexPath,
                                                        UITableView *_Nonnull tableView);
typedef void (^YZSCellDisplayBlock)(UITableViewCell *_Nonnull cell, NSIndexPath *_Nonnull indexPath,
                                        UITableView *_Nonnull tableView);
typedef void (^YZSCellEditingStyleBlock)(NSIndexPath *_Nonnull indexPath, UITableView *_Nonnull tableView,
                                       UITableViewCellEditingStyle editingStyle);
typedef NSIndexPath *_Nullable (^YZSCellIndexPathBlock)(NSIndexPath *_Nonnull indexPath,
                                                        UITableView *_Nonnull tableView);
/** Table view's row model */
@interface YZSTableViewCellModel : NSObject

@property (nonatomic, copy, nonnull) YZSCellRenderBlock renderBlock;             // required
@property (nonatomic, copy, nullable) YZSCellDisplayBlock willDisplayBlock;  // optional
@property (nonatomic, copy, nullable) YZSCellDisplayBlock didEndDisplayBlock;  // optional
@property (nonatomic, copy, nullable) YZSCellIndexPathBlock willSelectBlock;    // optional
@property (nonatomic, copy, nullable) YZSCellIndexPathBlock willDeselectBlock;  // optional
@property (nonatomic, copy, nullable) YZSCellVoidBlock selectionBlock;      // optional
@property (nonatomic, copy, nullable) YZSCellVoidBlock deselectionBlock;    // optional
@property (nonatomic, copy, nullable) YZSCellEditingStyleBlock commitEditBlock;    // optional
@property (nonatomic, copy, nullable) YZSCellBoolBlock shouldHighlightBlock;    // optional
@property (nonatomic, copy, nullable) YZSCellVoidBlock didHighlightBlock;  // optional
@property (nonatomic, copy, nullable) YZSCellVoidBlock didUnhighlightBlock;  // optional
@property (nonatomic, copy, nullable) YZSCellVoidBlock willBeginEditingBlock;  // optional
@property (nonatomic, copy, nullable) YZSCellVoidBlock didEndEditingBlock;  // optional
@property (nonatomic, copy, nullable) YZSCellVoidBlock accessoryButtonTappedBlock;   // optional
/**
 if not specified, will use UITableViewAutomaticDimension as default value.
 if height and cellHeightBlock are both provided, cellHeightBlock will be used
 */
@property (nonatomic, assign) CGFloat height;  // optional
@property (nonatomic, copy) YZSCellHeightBlock _Nullable cellHeightBlock;  // optional
/** used by tableView:canEditRowAtIndexPath: */
@property (nonatomic, assign) BOOL canEdit;    // default NO
/** used by tableView:shouldHighlightForRowAtIndexPath: */
@property (nonatomic, assign) BOOL shouldHighlight; //default is YES, shouldHighlightBlock has higher priority
/** used by tableView:shouldIndentWhileEditingRowAtIndexPath: */
@property (nonatomic, assign) BOOL shouldIndentWhileEditing; //default is YES
/** used by tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: */
@property (nonatomic, strong, nullable) NSString *deleteConfirmationButtonTitle; // delete confirmation title
/** used by tableView:editActionsForRowAtIndexPath: */
@property (nonatomic, strong, nullable) NSArray<UITableViewRowAction *> *editActions; //supersedes deleteConfirmationButtonTitle
/** used by tableView:shouldIndentWhileEditingRowAtIndexPath: */
@property (nonatomic, assign) BOOL shouldShowMenu; // optional, default NO.
/** used by tableView:editingStyleForRowAtIndexPath: */
@property (nonatomic, assign) UITableViewCellEditingStyle editingStyle;  // default value UITableViewCellEditingStyleDelete
@property (nonatomic, strong, nullable) NSString *key;  // optional, used to identify the model

@end
