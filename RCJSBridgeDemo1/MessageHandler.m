//
//  MessageHandler.m
//  RCJSBridgeDemo1
//
//  Created by 刘立新 on 2019/2/16.
//  Copyright © 2019年 刘立新. All rights reserved.
//

#import "MessageHandler.h"

@implementation MessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"call MessageHandler1 ... ");
}
@end
