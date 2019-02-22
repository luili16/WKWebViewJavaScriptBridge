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
        // 将插件注册进去
        [userContentController addScriptMessageHandler:self name:@"RCJSBridgeHandler"];
        [configuration setUserContentController:userContentController];
        _wkWebView = [[WKWebView alloc]initWithFrame:frame configuration:configuration];
        _commandDelegate = [[RCCommandDelegate alloc]initWithWebView:_wkWebView];
        _commandQueue = [[NSOperationQueue alloc]init];
        _commandQueue.name = @"RCJSBridgeDispatchEventQueue";
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
    NSArray* jsonEntry = message.body;
    if (jsonEntry == nil) {
        return;
    }
    RCInvokedUrlCommand* command = [RCInvokedUrlCommand commandFrom:jsonEntry];
    //NSLog(@"RCInvokedUrlCommand:callbackId=%@",command.callbackId);
    //NSLog(@"RCInvokedUrlCommand:className=%@",command.className);
    //NSLog(@"RCInvokedUrlCommand:methodName=%@",command.methodName);
    //NSLog(@"RCInvokedUrlCommand:arguments=%@",command.arguments);
    [self exec:command];
}

-(void)exec:(RCInvokedUrlCommand*)command {
    
    if (command.className == nil || [command.className isKindOfClass:[NSNull class]]) {
        RCPluginResult* result = [RCPluginResult resultWithStatus:CDVCommandStatus_CLASS_NOT_FOUND_EXCEPTION messageAsString:@"service name is null"];
        [_commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    
    if (command.methodName == nil || [command.methodName isKindOfClass:[NSNull class]]) {
        RCPluginResult* result = [RCPluginResult resultWithStatus:CDVCommandStatus_INVALID_ACTION messageAsString:@"actioin name is null"];
        [_commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    RCPlugin* plugin = plugin = _pluginsObject[command.className];;
    if (plugin == nil || !([plugin isKindOfClass:[RCPlugin class]])) {
        NSString* err =[NSString stringWithFormat:@"ERROR: Plugin '%@' not found, or is not a CDVPlugin. Check your plugin mapping in plugin.json.",command.className];
        NSLog(@"%@", err);
        RCPluginResult* result = [RCPluginResult resultWithStatus:CDVCommandStatus_CLASS_NOT_FOUND_EXCEPTION messageAsString:err];
        [_commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    NSString* realMethodName = [command.methodName stringByAppendingString:@":"];
    NSLog(@"exec method: %@ from class: %@",realMethodName,command.className);
    SEL normalSelector = NSSelectorFromString(realMethodName);
    if (![plugin respondsToSelector:normalSelector]) {
        NSString* err = [NSString stringWithFormat:@"ERROR: Plugin '%@' could not response to method name '%@'",command.className,command.methodName];
        NSLog(@"%@",err);
        RCPluginResult* result = [RCPluginResult resultWithStatus:CDVCommandStatus_INVALID_ACTION messageAsString:err];
        [_commandDelegate sendPluginResult:result callbackId:command.callbackId];
        return;
    }
    NSInvocationOperation* operation = [[NSInvocationOperation alloc]initWithTarget:plugin selector:normalSelector object:command];
    [_commandQueue addOperation:operation];
}

-(void)dispose {
    NSLog(@"RCWebViewBridge call dispose");
    for (NSString* key in _pluginsObject) {
        RCPlugin* plugin = _pluginsObject[key];
        [plugin dispose];
    }
}

@end
