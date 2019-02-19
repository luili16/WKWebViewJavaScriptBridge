//
//  EchoPlugin.h
//  RCJSBridgeDemo1
//
//  Created by 刘立新 on 2019/2/18.
//  Copyright © 2019年 刘立新. All rights reserved.
//

#import "RCPlugin.h"
#import "RCJSBridge/RCInvokedUrlCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface EchoPlugin : RCPlugin
-(void)echo:(RCInvokedUrlCommand*)command;
@end

NS_ASSUME_NONNULL_END
