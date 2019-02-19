//
//  RCCommandDelegate.h
//  RCJSBridgeDemo1
//
//  Created by 刘立新 on 2019/2/16.
//  Copyright © 2019年 刘立新. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCPluginResult.h"
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCCommandDelegate : NSObject
-(RCCommandDelegate*)initWithWebView:(WKWebView*)wkWebView;
-(void)sendPluginResult:(RCPluginResult*)pluginResult callbackId:(NSString*)callbackId;
-(void)evalJs:(NSString*)js;
@end

NS_ASSUME_NONNULL_END
