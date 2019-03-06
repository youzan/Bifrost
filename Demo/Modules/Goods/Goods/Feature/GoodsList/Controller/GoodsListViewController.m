//
//  GoodsListViewController.m
//  Goods
//
//  Created by yangke on 2019/3/3.
//  Copyright © 2019 jackie@youzan. All rights reserved.
//

#import "GoodsListViewController.h"
#import "GoodsModuleService.h"
#import "SaleModuleService.h"

@interface GoodsListViewController ()
@property (nonatomic, strong) NSArray *goodsList;
@end

@implementation GoodsListViewController

+ (void)load {
    [Bifrost bindURL:kRouteAllGoodsList toHandler:^id _Nullable(NSDictionary * _Nullable parameters) {
        GoodsListViewController *vc = [[self alloc] initWithStyle:UITableViewStylePlain];
        return vc;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"All Goods List";
    self.navigationItem.backBarButtonItem.title = @"";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.goodsList = BFModule(GoodsModuleService).allGoodsList;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateShoppingCartBarButtonItem];
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.goodsList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    id<GoodsProtocol> goods = self.goodsList[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    NSString *text = BFStr(@"%@ : ￥%.2f", goods.name, goods.price);
    cell.textLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id<GoodsProtocol> goods = self.goodsList[indexPath.row];
    NSString *routeURL = BFStr(@"%@?%@=%@", kRouteGoodsDetail, kRouteGoodsDetailParamId, goods.goodsId);
    UIViewController *vc = [Bifrost handleURL:routeURL];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
