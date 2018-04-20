//
//  RCTQiniu.h
//  RCTQiniu
//
//  Created by gufei on 2018/4/12.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

// 华东,华北,华南,北美
typedef NS_ENUM(NSInteger, QNZoneTarget) {
    QNZoneTargetZ0 = 1,
    QNZoneTargetZ1 = 2,
    QNZoneTargetZ2 = 3,
    QNZoneTargetNa0 = 4
};

typedef NS_ENUM(NSUInteger, UploadType) {
    UPLOAD_STATUS_YES = 1,
    UPLOAD_STATUS_NO = 0
};

@interface RCTQiniu : RCTEventEmitter<RCTBridgeModule>
@end
