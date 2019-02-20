//
//  RCCommandDelegate.m
//  RCJSBridgeDemo1
//
//  Created by 刘立新 on 2019/2/16.
//  Copyright © 2019年 刘立新. All rights reserved.
//

#import "RCCommandDelegate.h"

@interface RCCommandDelegate() {
    @private
    WKWebView* _wkWebView;
}
@end

@implementation RCCommandDelegate

-(RCCommandDelegate *)initWithWebView:(WKWebView*)webView; {
    self = [super init];
    if (self) {
        _wkWebView = webView;
    }
    return self;
}

- (void)sendPluginResult:(RCPluginResult *)pluginResult callbackId:(NSString *)callbackId {
    int status = [pluginResult.status intValue];
    NSString* argumentsAsJson = [pluginResult argumentsAsJson];
    NSString* js = [NSString stringWithFormat:@"RCJSBridge.nativeCallback('%@',%d,%@);",callbackId,status,argumentsAsJson];
    NSLog(@"PluginResult:status=%d result=%@",status,argumentsAsJson);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_wkWebView evaluateJavaScript:js completionHandler:^(id _Nullable res, NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"ERROR: %@",error);
            }
        }];
    });
}

- (void)evalJs:(NSString *)js {
    
}
@end
