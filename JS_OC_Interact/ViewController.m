//
//  ViewController.m
//  JS_OC_Interact
//
//  Created by zhouzheng on 2017/8/10.
//  Copyright © 2017年 zhouzheng. All rights reserved.
//

#import "ViewController.h"
#import "UIWebView+TS_JavaScriptContext.h"
#import <JavaScriptCore/JavaScriptCore.h>

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<TSWebViewDelegate>
{
    UILabel *_label;
    UIWebView *_webView;
    UIButton *_button;
    JSContext *_jsContext;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, ScreenWidth-60, 40)];
    _label.backgroundColor = [UIColor orangeColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"↓ 下面是一个webView ↓";
    [self.view addSubview:_label];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 80, ScreenWidth-20, ScreenHeight-80-10-60)];
    _webView.backgroundColor = [UIColor lightGrayColor];
    _webView.scalesPageToFit = YES;
    _webView.opaque = NO;
    _webView.scrollView.bounces = NO;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"ddd.html" withExtension:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(30, ScreenHeight-50, ScreenWidth-60, 40);
    _button.backgroundColor = [UIColor orangeColor];
    [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_button setTitle:@"点我给js传参" forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

#pragma mark - *********** OC调用JS ***********
- (void)onClick {
    
    //➡️第一种方案，注意：该方法会同步返回一个字符串，是一个同步方法，可能会阻塞UI⬅️
//    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"showAlert('%@')",@"这里是JS中alert弹出的message"]];
    
    //➡️第二种方案，使用JavaScriptCore库来做JS交互⬅️
    NSString *textJS = @"showAlert('这里是JS中alert弹出的message')";
    [_jsContext evaluateScript:textJS];
    
}

#pragma mark - *********** JS调用OC ***********
#pragma mark - webViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    //➡️第一种方案，JS发起一个假的URL请求，然后拦截这次请求，再做相应的处理⬅️
    NSString *scheme = [request.URL scheme];
    scheme = [scheme lowercaseString];
    if ([scheme isEqualToString:@"close"]) {
        NSLog(@"拦截了close操作");
        return NO;
    }
    
    //➡️第二种方案，针对a标签跳转链接拦截⬅️
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSString *string = [NSString stringWithFormat:@"%@",request.URL];
        if ([string rangeOfString:@"baidu"].location != NSNotFound) {
            NSLog(@"拦截了跳转baidu");
            return NO;
        }
    }
    
    return YES;
}


//➡️第三种方案，在iOS 7之后，apple添加了一个新的库JavaScriptCore，用来做JS交互，因此JS与原生OC交互也变得简单了许多⬅️
#pragma mark - TSWebViewDelegate
//如果JS调用OC方法的时机是在页面加载完成之后，比如点击web界面上的按钮或者由用户手动触发一个事件调用OC代码，这种情况一定是web页面加载完成之后才会发生的，这时我们在webViewDidFinishLoad注入了JS，一点问题都没有。但是，如果JS调用OC方法的时机刚好发生在页面加载过程中呢？比如web界面加载过程中自动执行一些操作需要调用OC代码，而此时webViewDidFinishLoad还没有回调，所以我们的JS代码并没有注入。因此找到UIWebView+TS_JavaScriptContext，这样就可以在js环境生成时调用。
- (void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx {
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [self registerJavaScriptFunction];
//        [self printWebSouceCode];
        NSLog(@"-----------------register->%zd",[[NSDate date] timeIntervalSince1970]);
    });
}

//注入js
- (void)registerJavaScriptFunction {
    
    //注入js
    [self addJavaScriptApp];
    [self addJavaScriptName:@"share" isLastInjection:YES];
    
    //当js调用oc注入的方法时，就会拦截
    [self interceptJSFunction];
}

//注入js app变量
- (void)addJavaScriptApp {
    NSString * jsString = [NSString stringWithFormat:@"var script = document.createElement('script');"
                           "script.type = 'text/javascript';"
                           "script.text = \" var app = {}\";"
                           "document.getElementsByTagName('head')[0].appendChild(script);"];
    [_webView stringByEvaluatingJavaScriptFromString:jsString];
}

/**
 *  注入js，在某些业务需求上需要判断是否注入完成，可以采用以下方法，如果没有相关需求，此步可以省略
 *  @param functionName    注入的方法名
 *  @param isLastInjection 是否是最后注入，并注入id ，告诉html我注入完毕
 */
- (void)addJavaScriptName:(NSString *)functionName isLastInjection:(BOOL)isLastInjection {
    
    NSString * scriptId = @"";
    if(isLastInjection) {
        scriptId = @"script.id = 'injectionJSEND';";//script标签，起一个标识作用
    }
    
    NSString * jsString = [NSString stringWithFormat:@"var script = document.createElement('script');"
                           "%@"
                           "script.text = \"app.%@ = function() {};\";"
                           //定义myFunction方法
                           "document.getElementsByTagName('head')[0].appendChild(script);", scriptId,   functionName];
    
    [_webView stringByEvaluatingJavaScriptFromString:jsString];
}

//拦截js方法
- (void)interceptJSFunction {
    //获取 app变量的share方法
    _jsContext = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSValue * app = [_jsContext objectForKeyedSubscript:@"app"];
    app[@"share"] = ^(id obj){
        //注意：在iOS9之后，这个block中的操作是在子线程，因此执行UI操作需要回到主线程，否则控制台有警告
        NSLog(@"拦截了share操作");
    };
}

- (void)printWebSouceCode {
    //获取header源码1
    NSString *JsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
    NSString *HTMLSource = [_webView stringByEvaluatingJavaScriptFromString:JsToGetHTMLSource];
    NSLog(@"\n%@\n\n",HTMLSource);
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
