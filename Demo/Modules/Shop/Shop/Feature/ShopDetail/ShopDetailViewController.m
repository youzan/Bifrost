//
//  ShopDetailViewController.m
//  Shop
//
//  Created by yangke on 2017/9/17.
//  Copyright © 2017年 jackie@youzan. All rights reserved.
//

#import "ShopDetailViewController.h"
#import "ShopModuleService.h"
#import "SaleModuleService.h"
#import "ShopModule.h"

@interface ShopDetailViewController ()

@end

@implementation ShopDetailViewController

+ (void)load {
    [Bifrost bindURL:kRouteShopDetail toHandler:^id _Nullable(NSDictionary * _Nullable parameters) {
        ShopDetailViewController *vc = [[self alloc] init];
        return vc;
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [ShopModule sharedInstance].shopName;
    self.navigationItem.backBarButtonItem.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    label.text = @"This is the page for shop details";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
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

@end
