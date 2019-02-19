//
//  RCWebViewEngine.m
//  RCJSBridgeDemo
//
//  Created by 刘立新 on 2019/2/15.
//  Copyright © 2019年 刘立新. All rights reserved.
//

#import "RCWebViewBridge.h"
#import <WebKit/WebKit.h>
#import "RCPlugin.h"
#import "RCCommandDelegate.h"
#import "RCInvokedUrlCommand.h"
#import <Foundation/Foundation.h>
#import "RCJSON_private.h"

@interface RCWebViewBridge()<WKScriptMessageHandler> {
    @private
    WKWebView* _wkWebView;
    @private
    UIViewController* _viewController;
    @private
    NSMutableDictionary<NSString*,RCPlugin*>* _pluginsObject;
    @private
    RCCommandDelegate* _commandDelegate;
    @private
    NSOperationQueue* _commandQueue;
}
@end

@implementation RCWebViewBridge

-(RCWebViewBridge *)initWithConfiguration:(WKWebViewConfiguration *)configuration userContentController:(WKUserContentController *)userContentController frame:(CGRect)frame viewController:(UIViewController *)viewController configFile:(NSString *)path {
    self = [super init];
    if (self) {
        _viewController = viewController;
        _pluginsObject = [[NSMutableDictionary alloc]initWithCapacity:20];
        _commandDelegate = [[RCCommandDelegate alloc]init];
        _commandQueue = [[NSOperationQueue alloc]init];
        // 将插件注册进去
        //WKUserContentController* userContentController = [[WKUserContentController alloc]init];
        [userContentController addScriptMessageHandler:self name:@"RCJSBridge"];
        [configuration setUserContentController:userContentController];
        _wkWebView = [[WKWebView alloc]initWithFrame:frame configuration:configuration];
        _commandDelegate = [[RCCommandDelegate alloc]initWithWebView:_wkWebView];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSData* data = [fileManager contentsAtPath:path];
        NSArray* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        for (int i = 0; i < dic.count; i++) {
            NSDictionary* obj = dic[i];
            NSDictionary* service = obj[@"service"];
            NSString* className = service[@"className"];
            NSLog(@"className : %@",className);
            RCPlugin* plugin = [[NSClassFromString(className) alloc] initWithWebView:_wkWebView viewController:viewController commandDelegate:_commandDelegate];
            [plugin pluginInitialize];
            [_pluginsObject setObject:plugin forKey:className];
        }
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    // 建立InvokedUrlCommand
    NSArray* jsonEntry = message.body;
    if (jsonEntry == nil) {
        return;
    }
    RCInvokedUrlCommand* command = [RCInvokedUrlCommand commandFrom:jsonEntry];
    BOOL ok = [self exec:command];
    if (!ok) {
        NSLog(@"执行命令失败!");
    }
}

-(BOOL)exec:(RCInvokedUrlCommand*)command {
    RCPlugin* plugin = _pluginsObject[command.className];
    if (plugin == nil || !([plugin isKindOfClass:[RCPlugin class]])) {
        NSLog(@"ERROR: Plugin '%@' not found, or is not a CDVPlugin. Check your plugin mapping in config.xml.", command.className);
        return NO;
    }
    NSString* realMethodName = [command.methodName stringByAppendingString:@":"];
    NSLog(@"real method name : %@",realMethodName);
    SEL normalSelector = NSSelectorFromString(realMethodName);
    if (![plugin respondsToSelector:normalSelector]) {
        return NO;
    }
    NSInvocationOperation* operation = [[NSInvocationOperation alloc]initWithTarget:plugin selector:normalSelector object:command];
    [_commandQueue addOperation:operation];
    return YES;
}

@end
