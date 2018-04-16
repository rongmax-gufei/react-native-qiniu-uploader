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

#import "QNFileRecorder.h"
#import "QNNetworkInfo.h"
#import "QNResolver.h"
#import "QNDnsManager.h"
#import "QNUploadOption.h"
#import "QNUploadManager.h"
#import "QNConfiguration.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#import "ConstHeader.h"

@interface RCTQiniu()

@property (nonatomic, strong) NSString *token;
@property (nonatomic, assign) BOOL useHttps;
@property (nonatomic, assign) QNZoneTarget zoneTarget;
@property (nonatomic, assign) UploadType uploadType;

@end

@implementation RCTQiniu

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

#pragma mark init qiniu sdk
RCT_EXPORT_METHOD(init:(NSDictionary *)options) {
    self.token = options[@"token"];
    self.useHttps = [options[@"useHttps"] boolValue];
    self.zoneTarget = [options[@"zoneTarget"] integerValue];
}

#pragma mark upload file to qiniu
RCT_EXPORT_METHOD(uploadFileToQiniu:(NSString *)fileUrl fileName:(NSString *)fileName) {
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil
                                                      progressHandler:^(NSString *key, float percent)
                                                      {
                                                          NSString *per =[NSString stringWithFormat:@"%.2f", percent];
                                                          [self commentEvent:@"onUploading" code:kSuccess msg:per];
                                                      }
                                                               params:nil
                                                             checkCrc:NO
                                                   cancellationSignal:^BOOL() {
                                                               return self.uploadType == UPLOAD_STATUS_NO;
                                                             }];
    
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:[self config]];
    if (self.token) {
        [upManager putFile:fileUrl
                       key:fileName
                     token:self.token
                  complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                          [self commentEvent:@"onComplete" code:kSuccess msg:@"上传成功"];
                  }
                    option:uploadOption];
    } else {
        [self commentEvent:@"onError" code:kSuccess msg:@"token为空"];
    }
}

#pragma mark cancel file upload task
RCT_EXPORT_METHOD(cancelUploadTask) {
    self.uploadType = UPLOAD_STATUS_NO;
}

/**
 * useHttps:使用https=true，否则false
 * zoneTarget:华东1,华北2,华南3,北美4
 */
- (QNConfiguration *)config {
    QNConfiguration *config = nil;
    config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[QNResolver systemResolver]];
        QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:[QNNetworkInfo normal]];
        builder.dns = dns;
        //是否选择 https 上传
        builder.useHttps = self.useHttps;
        //设置断点续传
        NSError *error;
        builder.recorder =  [QNFileRecorder fileRecorderWithFolder:kCacheFolder error:&error];
        switch (self.zoneTarget) {
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
