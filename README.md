# ZZOC_JS_Interact
OC与JS之间的交互

分别使用UIWebView和WKWebView针对常用交互模式进行讲解。其中使用WKWebView时，有针对dealloc方法不走的解决方案，在代码中对此作了说明。
通过注入JS来进行交互，在html代码中，主要区别在于

    //UIWebView  分享功能，JS调用OC通过注入js
    $("#share").on('click',function () {
        //添加动画效果
        //调用app方法
        if (typeof app !== 'undefined' && app.share) {
            app.share('qqq');
        } else {
            alert('没有注入');
        }
    });
    
    //WKWebView  分享功能，JS调用OC通过注入js
    $("#share").on('click',function () {
        //添加动画效果
        //调用app方法
        if (isApple) {
            window.webkit.messageHandlers.share.postMessage('qqq');
        } else {
            alert('没有注入');
        }
    });
    
    
![image](https://github.com/ZhouZhengzz/ZZOC_JS_Interact/blob/master/%E6%95%88%E6%9E%9C%E5%9B%BE/zhushi.jpg)
