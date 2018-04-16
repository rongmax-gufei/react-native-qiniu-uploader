//
//  RCTQiniuModule.m
//  RCTQiniuModule
//
//  Created by Apple on 2018/4/12.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "RCTQiniuModule.h"

#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTEventEmitter.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <React/RCTUtils.h>

#import "QNUploadOption.h"
#import "QNUploadManager.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "ConstHeader.h"

@interface RCTQiniuModule()

@property (nonatomic, strong) NSString *token;
@property (nonatomic, assign) BOOL useHttps;
@property (nonatomic, assign) QNHttpsTarget httpsTarget;
@property (nonatomic, assign) QNZoneTarget zoneTarget;

@end

@implementation RCTQiniuModule

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

#pragma mark init qiniu sdk
RCT_EXPORT_METHOD(init:(NSDictionary *)options) {
  self.token = options[@"token"];
  self.useHttps = [options[@"useHttps"] boolValue];
  self.httpsTarget = [options[@"httpsTarget"] integerValue];
  self.zoneTarget = [options[@"zoneTarget"] integerValue];
}

#pragma mark upload image to qiniu
RCT_EXPORT_METHOD(uploadImageToQiniu:(NSString *)filePath) {
  self.callback = callback;
  __block BOOL flag = NO;
  QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil
                                                      progressHandler:^(NSString *key, float percent)
                                                      {
                                                          NSString *per =[NSString stringWithFormat:@"%.2f", percent];
                                                          [self commentEvent:@"onUploading" code:kSuccess msg:per];
                                                      }
                                                               params:nil
                                                             checkCrc:NO
                                                   cancellationSignal:^BOOL() {
                                                               return flag;
                                                             }];
  QNUploadManager *upManager = [[QNUploadManager alloc] init];
  [upManager putFile:filePath
                 key:nil
               token:self.token
            complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
              [self commentEvent:@"onComplete" code:kSuccess msg:@"上传成功"];
              option:uploadOption];
}

#pragma mark - native to js event method
- (NSArray<NSString *> *)supportedEvents {
    return @[@"qiniuEvent"];
}

- (void)commentEvent:(NSString *)type code:(int )code msg:(NSString *)msg {
    NSMutableDictionary *params = @{}.mutableCopy;
    params[kType] = type;
    params[kCode] = [NSString stringWithFormat:@"%d", code];
    params[kMsg] = msg;
    NSLog(@"返回commentEvent%@", params );
    dispatch_async(dispatch_get_main_queue(), ^{
        [self sendEventWithName:@"qiniuEvent" body:params];
    });
}

// RCT必须的方法体，不可删除，否则所有暴露的RCT_EXPORT_METHOD不在主线程执行
- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end
