//
//  TestPlugin1.m
//  RCJSBridgeDemo1
//
//  Created by 刘立新 on 2019/2/22.
//  Copyright © 2019年 刘立新. All rights reserved.
//

#import "TestPlugin1.h"

@implementation TestPlugin1

- (void)pluginInitialize {
    NSLog(@"TestPlugin1 pluginInitialize");
}

- (void)echoString:(RCInvokedUrlCommand *)command {
    NSString* arg0 = command.arguments[0];
    NSLog(@"TestPlugin1 call echoString: arg0=%@",command.arguments[0]);
    NSArray* res = @[arg0,(NSNumber*)command.arguments[1]];
    [NSThread sleepForTimeInterval:5];
    RCPluginResult* result = [RCPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:res];
    [_commandDelegate sendPluginResult:result callbackId:command.callbackId];
}
@end
