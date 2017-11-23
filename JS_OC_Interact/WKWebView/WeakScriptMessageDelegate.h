//
//  WeakScriptMessageDelegate.h
//  JS_OC_Interact
//
//  Created by 周正 on 2017/11/23.
//  Copyright © 2017年 zhouzheng. All rights reserved.
//
//解决WKWebView导致ViewController不调用dealloc

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
@interface WeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
