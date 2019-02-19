//
//  EchoPlugin.m
//  RCJSBridgeDemo1
//
//  Created by 刘立新 on 2019/2/18.
//  Copyright © 2019年 刘立新. All rights reserved.
//

#import "EchoPlugin.h"

@implementation EchoPlugin
- (void)pluginInitialize {
    NSLog(@"EchoPlugin pluginInitialize");
}

- (void)dispose {
}

-(void)echo:(RCInvokedUrlCommand *)command {
    NSLog(@"call echo at thread : %@",[NSThread currentThread]);
    RCPluginResult* result = [RCPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:123];
    [_commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
@end
