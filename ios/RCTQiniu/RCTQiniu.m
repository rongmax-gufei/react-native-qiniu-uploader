//
//  RCTQiniu.m
//  RCTQiniu
//
//  Created by gufei on 2018/4/12.
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

@property QNUploadManager *upManager;
@property NSInteger fixedZone;
@property NSString *filePath;
@property NSString *upKey;
@property NSString *upToken;
@property BOOL isTaskPause;

@end

@implementation RCTQiniu

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

#pragma mark init qiniu sdk
RCT_EXPORT_METHOD(setParams:(NSDictionary *)options) {
  self.filePath = options[@"filePath"];
  self.upKey = options[@"upKey"];
  self.upToken = options[@"upToken"];
  self.fixedZone = [options[@"zone"] integerValue];
  self.upManager = [[QNUploadManager alloc] initWithConfiguration:[self config]];
}

#pragma mark start upload file
RCT_EXPORT_METHOD(startTask) {
  if ([self checkParams]) {
    [self uploadTask];
  }
}

#pragma mark resume upload task
RCT_EXPORT_METHOD(resumeTask) {
  self.isTaskPause = NO;
  [self uploadTask];
}

#pragma mark pause upload task
RCT_EXPORT_METHOD(pauseTask) {
  self.isTaskPause = YES;
}

/**
 * zoneTarget:华东1,华北2,华南3,北美4
 */
- (QNConfiguration *)config {
  QNConfiguration *config = nil;
  config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
    //设置断点续传
    NSError *error;
    builder.recorder =  [QNFileRecorder fileRecorderWithFolder:[NSTemporaryDirectory() stringByAppendingString:kCacheFolder] error:&error];
    switch (self.fixedZone) {
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

- (BOOL)checkParams {
  
  BOOL pass = YES;
  NSString *msg = @"";
  
  if (nil == self.filePath || [self.filePath isEqual:[NSNull null]]) {
    msg = @"filePath can not be nil";
    pass = NO;
  } else if (nil == self.upKey || [self.upKey isEqual:[NSNull null]]) {
    msg = @"upKey can not be nil";
    pass = NO;
  } else if (nil == self.upToken || [self.upToken isEqual:[NSNull null]]) {
    msg = @"upToken can not be nil";
    pass = NO;
  }
  
  if (!pass) {
    [self commentEvent:onError code:kFail msg:msg];
  }
  
  if (pass && [self.filePath hasPrefix:@"file://"])
    self.filePath = [self.filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
  
  return pass;
}

- (void)uploadTask {
  
  __weak typeof(self) weakSelf = self;
  
  QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil
                                                      progressHandler:^(NSString *key, float percent) {
                                                        __strong typeof(weakSelf) strongSelf = weakSelf;
                                                        NSString *per =[NSString stringWithFormat:@"%.2f", percent];
                                                        [strongSelf commentEvent:onProgress code:kSuccess msg:key percent:per];
                                                      }
                                                               params:nil
                                                             checkCrc:NO
                                                   cancellationSignal:^BOOL() {
                                                     __strong typeof(weakSelf) strongSelf = weakSelf;
                                                     return strongSelf.isTaskPause;
                                                   }];
  [self.upManager putFile:self.filePath key:self.upKey token:self.upToken complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
    if (info.isOK) {
      [self commentEvent:onComplete code:kSuccess msg:@"上传成功"];
    } else {
      NSString *errorStr = @"";
      for (NSString *key in info.error.userInfo) {
        [errorStr stringByAppendingString:key];
      }
      [self commentEvent:onError code:info.statusCode msg:errorStr];
    }
  }
                   option:uploadOption];
}

#pragma mark - native to js event method
- (NSArray<NSString *> *)supportedEvents {
    return @[qiniuEvent];
}

- (void)commentEvent:(NSString *)type code:(int)code msg:(NSString *)msg {
  [self commentEvent:type code:code msg:msg percent:@""];
}

- (void)commentEvent:(NSString *)type code:(int)code msg:(NSString *)msg percent:(NSString *)percent {
  NSMutableDictionary *params = @{}.mutableCopy;
  params[kType] = type;
  params[kCode] = [NSString stringWithFormat:@"%d", code];
  params[kMsg] = msg;
  params[kPercent] = percent;
  NSLog(@"返回commentEvent%@", params );
  dispatch_async(dispatch_get_main_queue(), ^{
    [self sendEventWithName:qiniuEvent body:params];
  });
}
// RCT必须的方法体，不可删除，否则所有暴露的RCT_EXPORT_METHOD不在主线程执行
- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end
