//
//  RCTQiniuModule.m
//  RCTQiniuModule
//
//  Created by Apple on 2018/4/12.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "RCTQiniu.h"

#import <React/RCTUtils.h>
#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import <QiniuSDK.h>

#import "ConstHeader.h"

@interface RCTQiniu()

@property (nonatomic, assign) BOOL cancelTask;

@end

@implementation RCTQiniu

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

#pragma mark upload file to qiniu
RCT_EXPORT_METHOD(uploadFileToQNFilePath:(NSString *)filePath key:(NSString *)key token:(NSString *)uptoken fixedZone:(int)zone) {
  
  filePath = [self filePathFormat:filePath];
  
  if (!uptoken || !filePath) {
    [self commentEvent:@"onError" code:kFail msg:@"uptoken or filePath can not be nil"];
    return;
  }
  
  QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:[self configWithZone:zone]];
  QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil
                                                      progressHandler:^(NSString *key, float percent) {
                                    NSString *per =[NSString stringWithFormat:@"%.2f", percent];
                                    [self commentEvent:@"onUploading" code:kSuccess msg:per];
                                  }
                                                               params:nil
                                                             checkCrc:NO
                                                   cancellationSignal:^BOOL() {
                                                     return self.cancelTask;
                                                   }];
  [upManager putFile:filePath key:key token:uptoken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
    int code = info.isOK?kSuccess:info.statusCode;
    NSString *msg = info.isOK?@"上传成功":info.error.localizedDescription;
    [self commentEvent:@"onComplete" code:code msg:msg];
  }
              option:uploadOption];
}

#pragma mark cancel file upload task
RCT_EXPORT_METHOD(cancelUploadTask) {
  self.cancelTask = !self.cancelTask;
}

/**
 * zoneTarget:华东1,华北2,华南3,北美4
 */
- (QNConfiguration *)configWithZone:(int)zone {
  QNConfiguration *config = nil;
  config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
    //设置断点续传
    NSError *error;
    builder.recorder =  [QNFileRecorder fileRecorderWithFolder:[NSTemporaryDirectory() stringByAppendingString:kCacheFolder] error:&error];
    switch (zone) {
      case 1:
        // 华东
        builder.zone = [QNFixedZone zone0];
        break;
      case 2:
        // 华北
        builder.zone = [QNFixedZone zone1];
        break;
      case 3:
        // 华南
        builder.zone = [QNFixedZone zone2];
        break;
      case 4:
        // 北美
        builder.zone = [QNFixedZone zoneNa0];
        break;
      default:
        break;
    }
    }];
    return config;
}

- (NSString *)filePathFormat:(NSString *)filePath {
  return [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
}

#pragma mark - native to js event method
- (NSArray<NSString *> *)supportedEvents {
    return @[@"qiniuEvent"];
}

- (void)commentEvent:(NSString *)type code:(int)code msg:(NSString *)msg {
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
