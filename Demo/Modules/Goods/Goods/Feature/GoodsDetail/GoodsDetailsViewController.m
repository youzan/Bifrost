//
//  GoodsDetailsViewController.m
//  Goods
//
//  Created by yangke on 2017/9/17.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import "GoodsDetailsViewController.h"
#import "GoodsModuleService.h"
#import "SaleModuleService.h"
#import "GoodsModule.h"
#import "GoodsModel.h"

@interface GoodsDetailsViewController ()

@property (nonatomic, strong) NSString *goodsId;

@end

@implementation GoodsDetailsViewController

+ (void)load {
    [Bifrost bindURL:kRouteGoodsDetail toHandler:^id _Nullable(NSDictionary * _Nullable parameters) {
        GoodsDetailsViewController *vc = [[self alloc] init];
        vc.goodsId = parameters[kRouteGoodsDetailParamId];
        return vc;
    }];
    for (NSInteger i=0; i<10000; i++) {
        NSString *url = BFStr(@"//test/test_%ld", i);
        [Bifrost bindURL:url toHandler:^id _Nullable(NSDictionary * _Nullable parameters) {
            GoodsDetailsViewController *vc = [[self alloc] init];
            vc.goodsId = parameters[kRouteGoodsDetailParamId];
            return vc;
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Goods Detail";
    self.navigationItem.backBarButtonItem.title = @"";
    GoodsModel *goods = [[GoodsModule sharedInstance] goodsById:self.goodsId];
    if (goods) {
        self.title = goods.name;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    //buy button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"加入购物车" forState:UIControlStateNormal];
    button.frame = CGRectMake(100, 400, self.view.frame.size.width - 200, 100);
    [button addTarget:self
               action:@selector(addToShoppingCart)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
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

- (void)addToShoppingCart {
    [BFModule(SaleModuleService) addShoppingCartGoods:self.goodsId];
    [self updateShoppingCartBarButtonItem];
}

- (void)goToShoppingCart {
    UIViewController *vc = [Bifrost handleURL:kRouteSaleShoppingCart];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
