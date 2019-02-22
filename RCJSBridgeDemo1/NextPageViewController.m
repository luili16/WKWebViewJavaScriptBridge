//
//  NextPageViewController.m
//  RCJSBridgeDemo1
//
//  Created by 刘立新 on 2019/2/20.
//  Copyright © 2019年 刘立新. All rights reserved.
//

#import "NextPageViewController.h"
#import <WebKit/WebKit.h>
#import "RCJSBridge/RCWebViewBridge.h"

@interface NextPageViewController (){
@private
    RCWebViewBridge* _webViewEngine;
@private
    WKWebView* _wkWebView;
@private
    WKWebViewConfiguration* _configuration;
}

@end

@implementation NextPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _configuration = [[WKWebViewConfiguration alloc]init];
    WKUserContentController* controller = [[WKUserContentController alloc]init];
    NSString* configFile = [[NSBundle mainBundle]pathForResource:@"plugin1.json" ofType:nil inDirectory:@"BridgeConfig"];
    _webViewEngine = [[RCWebViewBridge alloc]initWithConfiguration:_configuration userContentController:controller frame:self.view.frame viewController:self configFile:configFile];
    _wkWebView = _webViewEngine.wkWebView;
    [self.view addSubview:_wkWebView];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"index1.html" ofType:nil inDirectory:@"www"];
    NSURL* url = [NSURL fileURLWithPath:path];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [_wkWebView loadRequest:request];
}

- (void)viewDidDisappear:(BOOL)animated {
   [_webViewEngine dispose];
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
