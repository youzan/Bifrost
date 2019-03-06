//
//  HomeViewController.m
//  Home
//
//  Created by yangke on 2017/9/17.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import <objc/runtime.h>
#import "HomeViewController.h"
#import "HomeBundle.h"
#import "HomeModuleService.h"
#import "ShopModuleService.h"
#import "SaleModuleService.h"
#import "GoodsModuleService.h"
#import "YZSTableViewModel.h"
#import "YZWeakDefine.h"

@interface HomeViewController ()<YZSTableViewModelDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) YZSTableViewModel *viewModel;
@end

@implementation HomeViewController

+ (void)load {
    [Bifrost bindURL:kRouteHomePage
           toHandler:^id _Nullable(NSDictionary * _Nullable parameters) {
        UIViewController *vc = [[HomeBundle storyboardWithName:@"home"] instantiateViewControllerWithIdentifier:@"HomeViewController"];
        return vc;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bifrost";
    self.navigationItem.backBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem.title = @"";
    [self reloadViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateShoppingCartBarButtonItem];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self postDidAppearNotivication];
}

- (void)postDidAppearNotivication {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHomePageDidAppear object:nil];
}

- (void)updateShoppingCartBarButtonItem {
    NSString *title = BFStr(@"购物车(%lu)", BFModule(SaleModuleService).shoppinCartGoodsNum);
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
    [item setTarget:self];
    [item setAction:@selector(goToShoppingCart)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)goToShoppingCart {
    UIViewController *vc = [Bifrost handleURL:kRouteSaleShoppingCart];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (YZSTableViewModel*)viewModel {
    if(!_viewModel) {
        _viewModel = [[YZSTableViewModel alloc] init];
        self.tableView.dataSource = _viewModel;
        self.tableView.delegate = _viewModel;
        _viewModel.delegate = self;
    }
    return _viewModel;
}

- (UITableViewCell*)reusableCellWithId:(NSString*)identifier
                                inView:(UITableView*)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
    }
    return cell;
}

- (void)reloadViewModel {
    [self.viewModel.sectionModelArray removeAllObjects];
    //shop info section
    {
        YZSTableViewSectionModel *sectionModel = [[YZSTableViewSectionModel alloc] init];
        [self.viewModel.sectionModelArray addObject:sectionModel];
        sectionModel.headerTitle = @"Shop Info";
        static NSString *CellIdentifier = @"ShopCell";
        YZWeak(self);
        //shop details entrance
        YZSTableViewCellModel *cellModel = [[YZSTableViewCellModel alloc] init];
        [sectionModel.cellModelArray addObject:cellModel];
        cellModel.height = 44;
        cellModel.renderBlock = ^UITableViewCell * _Nonnull(NSIndexPath * _Nonnull indexPath, UITableView * _Nonnull tableView) {
            YZStrong(self)
            UITableViewCell *cell = [self reusableCellWithId:CellIdentifier inView:tableView];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            id<ShopModuleService> shopModule = BFModule(ShopModuleService);
            cell.imageView.image = shopModule.shopLogo;
            NSString *text = BFStr(@"Shop Name: %@", shopModule.shopName);
            cell.textLabel.text = text;
            return cell;
        };
        cellModel.selectionBlock = ^(NSIndexPath * _Nonnull indexPath, UITableView * _Nonnull tableView) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIViewController *vc = [Bifrost handleURL:kRouteShopDetail];
            if (vc) {
                [self.navigationController pushViewController:vc animated:YES];
            }
        };
        //revenue info
        cellModel = [[YZSTableViewCellModel alloc] init];
        [sectionModel.cellModelArray addObject:cellModel];
        cellModel.height = 44;
        cellModel.renderBlock = ^UITableViewCell * _Nonnull(NSIndexPath * _Nonnull indexPath, UITableView * _Nonnull tableView) {
            YZStrong(self)
            UITableViewCell *cell = [self reusableCellWithId:CellIdentifier inView:tableView];
            NSString *text = BFStr(@"Revenue: ￥%.2f", [BFModule(ShopModuleService) shopRevenue]);
            cell.textLabel.text = text;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        };
    }
    //goods info section
    {
        YZSTableViewSectionModel *sectionModel = [[YZSTableViewSectionModel alloc] init];
        [self.viewModel.sectionModelArray addObject:sectionModel];
        sectionModel.headerTitle = @"Popular Goods";
        static NSString *CellIdentifier = @"GoodsCell";
        YZWeak(self);
        //popular goods list
        NSArray *list = [BFModule(GoodsModuleService) popularGoodsList];
        for (id<GoodsProtocol> goods in list) {
            YZSTableViewCellModel *cellModel = [[YZSTableViewCellModel alloc] init];
            [sectionModel.cellModelArray addObject:cellModel];
            cellModel.height = 44;
            cellModel.renderBlock = ^UITableViewCell * _Nonnull(NSIndexPath * _Nonnull indexPath, UITableView * _Nonnull tableView) {
                YZStrong(self)
                UITableViewCell *cell = [self reusableCellWithId:CellIdentifier inView:tableView];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                NSString *text = BFStr(@"%@ : ￥%.2f", goods.name, goods.price);
                cell.textLabel.text = text;
                return cell;
            };
            cellModel.selectionBlock = ^(NSIndexPath * _Nonnull indexPath, UITableView * _Nonnull tableView) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                NSString *routeURL = BFStr(@"%@?%@=%@", kRouteGoodsDetail, kRouteGoodsDetailParamId, goods.goodsId);
                UIViewController *vc = [Bifrost handleURL:routeURL];
                if (vc) {
                    [self.navigationController pushViewController:vc animated:YES];
                }
            };
        }
        //all goods entry
        YZSTableViewCellModel *cellModel = [[YZSTableViewCellModel alloc] init];
        [sectionModel.cellModelArray addObject:cellModel];
        cellModel.height = 44;
        cellModel.renderBlock = ^UITableViewCell * _Nonnull(NSIndexPath * _Nonnull indexPath, UITableView * _Nonnull tableView) {
            YZStrong(self)
            UITableViewCell *cell = [self reusableCellWithId:CellIdentifier inView:tableView];
            cell.textLabel.text = @"More Goods...";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        };
        cellModel.selectionBlock = ^(NSIndexPath * _Nonnull indexPath, UITableView * _Nonnull tableView) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIViewController *vc = [Bifrost handleURL:kRouteAllGoodsList];
            if (vc) {
                [self.navigationController pushViewController:vc animated:YES];
            }
        };
    }
    [self.tableView reloadData];
}

- (void)addShoppingCartGoods:(NSString*)goodsId {
    if (goodsId.length == 0) {
        return;
    }
    [BFModule(SaleModuleService) addShoppingCartGoods:goodsId];
    [self updateShoppingCartBarButtonItem];
}

@end
