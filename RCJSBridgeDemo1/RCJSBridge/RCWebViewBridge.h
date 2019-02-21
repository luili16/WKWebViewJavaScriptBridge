//
//  RCWebViewEngine.h
//  RCJSBridgeDemo
//
//  Created by 刘立新 on 2019/2/15.
//  Copyright © 2019年 刘立新. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCWebViewBridge : NSObject {
}
@property(nonatomic,strong,readonly) WKWebView* wkWebView;
-(RCWebViewBridge*) initWithConfiguration:(WKWebViewConfiguration*)configuration userContentController:(WKUserContentController*)userContentController frame:(CGRect)frame viewController:(UIViewController*)viewController configFile:(NSString*)path;
// 代理ViewController的全部生命周期

@end

NS_ASSUME_NONNULL_END
