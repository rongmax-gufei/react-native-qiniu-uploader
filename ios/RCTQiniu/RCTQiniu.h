//
//  RCTQiniuModule.h
//  RCTQiniuModule
//
//  Created by Apple on 2018/4/12.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <UIKit/UIKit.h>

// 华东,华北,华南,北美
typedef NS_ENUM(NSInteger, QNZoneTarget) {
    QNZoneTargetZ0 = 1,
    QNZoneTargetZ1 = 2,
    QNZoneTargetZ2 = 3,
    QNZoneTargetNa0 = 4
};

typedef NS_ENUM(Boolean, UploadType) {
    UPLOAD_STATUS_YES = YES,
    UPLOAD_STATUS_NO = NO
};

@interface RCTQiniu : RCTEventEmitter<RCTBridgeModule>
@end
