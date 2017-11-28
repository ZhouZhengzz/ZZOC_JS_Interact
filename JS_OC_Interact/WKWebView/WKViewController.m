//
//  WKViewController.m
//  JS_OC_Interact
//
//  Created by 周正 on 2017/11/22.
//  Copyright © 2017年 zhouzheng. All rights reserved.
//

#import "WKViewController.h"
#import <WebKit/WebKit.h>
#import "WeakScriptMessageDelegate.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface WKViewController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>
{
    UILabel *_label;
    WKWebView *_webView;
    WKWebViewConfiguration *_config;
    UIButton *_button;
}
@end

@implementation WKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"WKWebView";
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(30, 80, ScreenWidth-60, 40)];
    _label.backgroundColor = [UIColor orangeColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"↓ 下面是一个WKWebView ↓";
    [self.view addSubview:_label];
    
    _config = [[WKWebViewConfiguration alloc]init];
    _config.userContentController = [[WKUserContentController alloc]init];
    NSString * javaScriptSource = [NSString stringWithFormat:@"var script = document.createElement('script');"
                                   "script.text = \"var app = {};\";"
                                   "document.getElementsByTagName('head')[0].appendChild(script);"];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:javaScriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [_config.userContentController addUserScript:userScript];
    //解决WKWebView导致ViewController不调用dealloc
    [_config.userContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:self] name:@"share"];
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(10, 130, ScreenWidth-20, ScreenHeight-80-10-60-50) configuration:_config];
    _webView.backgroundColor = [UIColor lightGrayColor];
    _webView.opaque = NO;
    _webView.scrollView.bounces = NO;
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"WKWebView.html" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    
    // 添加KVO监听
    [_webView addObserver:self
                forKeyPath:@"loading"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    [_webView addObserver:self
                forKeyPath:@"title"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    [_webView addObserver:self
                forKeyPath:@"estimatedProgress"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(30, ScreenHeight-50, ScreenWidth-60, 40);
    _button.backgroundColor = [UIColor orangeColor];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button setTitle:@"点我给js传参" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

#pragma mark - >>>>>>>>> OC调用JS <<<<<<<<<
- (void)onClick {
    NSString *textJS = @"showAlert('这里是JS中的message')";
    [_webView evaluateJavaScript:textJS completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"result:%@  error:%@",result, error);
    }];
}

#pragma mark - >>>>>>>>> webView kvo <<<<<<<<<
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"loading"]) {
        NSLog(@"loading");
        
    } else if ([keyPath isEqualToString:@"title"]) {
        NSLog(@"%@",_webView.title);
        
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"%.2f",_webView.estimatedProgress);
    }
  
}

#pragma mark - >>>>>>>>> WKScriptMessageHandler JS调用OC <<<<<<<<<
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"share"]) {
        NSLog(@"%@",message.body);
        NSLog(@"拦截了share操作");
    }
    
}

#pragma mark - >>>>>>>>> WKNavigationDelegate <<<<<<<<<
//发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    
    //➡️第一种方案，JS发起一个假的URL请求，然后拦截这次请求，再做相应的处理⬅️
    NSString *scheme = [navigationAction.request.URL scheme];
    scheme = [scheme lowercaseString];
    if ([scheme containsString:@"close"]) {
        NSLog(@"拦截了close操作");
        //不允许跳转
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    
    //➡️第二种方案，针对a标签跳转链接拦截⬅️
    else if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        NSString *string = navigationAction.request.URL.absoluteString;
        if ([string containsString:@"baidu"]) {
            NSLog(@"拦截了跳转baidu操作");
            //不允许跳转
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }
    
    else {
        //允许跳转
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    
}

//响应完成时
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(nonnull WKNavigationResponse *)navigationResponse decisionHandler:(nonnull void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"页面开始加载");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"页面加载完成");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"页面加载失败");
}

#pragma mark - >>>>>>>>> WKUIDelegate <<<<<<<<<
//在JS端调用alert函数时，会调用此方法
//JS端调用alert时所传的数据通过message拿到
//在原生得到结果后，需要回调JS，通过completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)dealloc {
    [_config.userContentController removeScriptMessageHandlerForName:@"share"];
    [_webView removeObserver:self forKeyPath:@"loading"];
    [_webView removeObserver:self forKeyPath:@"title"];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
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
