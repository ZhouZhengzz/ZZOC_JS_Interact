//
//  HomeViewController.m
//  JS_OC_Interact
//
//  Created by 周正 on 2017/11/22.
//  Copyright © 2017年 zhouzheng. All rights reserved.
//

#import "HomeViewController.h"
#import "ViewController.h"
#import "WKViewController.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"首页";
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 100, ScreenWidth-120, 50)];
    label.backgroundColor = [UIColor orangeColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:18];
    label.textColor = [UIColor blackColor];
    label.text = @"webView & JS 交互";
    [self.view addSubview:label];
    
    NSArray *titleArray = @[@"UIWebView", @"WKWebView"];
    for (int i=0; i<2; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(((ScreenWidth-280)/2+i*160), 200, 120, 40);
        button.backgroundColor = [UIColor orangeColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        button.tag = 1000+i;
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
}

- (void)btnClick:(UIButton *)btn {
    if (btn.tag == 1000) {
        ViewController *UIWebVC = [[ViewController alloc] init];
        [self.navigationController pushViewController:UIWebVC animated:YES];
        
    }else if (btn.tag == 1001) {
        WKViewController *WKWebVC = [[WKViewController alloc] init];
        [self.navigationController pushViewController:WKWebVC animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
