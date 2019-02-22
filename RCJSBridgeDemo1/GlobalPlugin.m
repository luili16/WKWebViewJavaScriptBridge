//
//  GlobalPlugin.m
//  RCJSBridgeDemo1
//
//  Created by 刘立新 on 2019/2/22.
//  Copyright © 2019年 刘立新. All rights reserved.
//

#import "GlobalPlugin.h"

@implementation GlobalPlugin
- (void)echoGlobalString:(RCInvokedUrlCommand *)command {
    NSLog(@"GlobalPlugin call echoGlobalString");
    RCPluginResult* result = [RCPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"hello from gloabl plugin!"];
    [_commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
@end
