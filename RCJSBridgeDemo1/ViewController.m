//
//  ViewController.m
//  RCJSBridgeDemo1
//
//  Created by 刘立新 on 2019/2/16.
//  Copyright © 2019年 刘立新. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "RCJSBridge/RCWebViewBridge.h"

@interface ViewController () {
    @private
    RCWebViewBridge* _webViewEngine;
    @private
    WKWebView* _wkWebView;
    @private
    WKWebViewConfiguration* _configuration;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _configuration = [[WKWebViewConfiguration alloc]init];
    WKUserContentController* controller = [[WKUserContentController alloc]init];
    NSString* configFile = [[NSBundle mainBundle]pathForResource:@"plugin.json" ofType:nil inDirectory:@"BridgeConfig"];
    _webViewEngine = [[RCWebViewBridge alloc]initWithConfiguration:_configuration userContentController:controller frame:self.view.frame viewController:self configFile:configFile];
    _wkWebView = _webViewEngine.wkWebView;
    [self.view addSubview:_wkWebView];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"index.html" ofType:nil inDirectory:@"www"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [_wkWebView loadRequest:request];
}

- (void)viewDidDisappear:(BOOL)animated {
    
}

- (void)dealloc
{
    [_webViewEngine dispose];
}
@end
