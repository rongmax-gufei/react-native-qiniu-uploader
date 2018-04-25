# react-native-qiniu-uploader

[![npm version](https://badge.fury.io/js/react-native-qiniu-uploader.svg)](https://badge.fury.io/js/react-native-qiniu-uploader)
[![npm](https://img.shields.io/npm/dt/react-native-qiniu-uploader.svg)](https://www.npmjs.com/package/react-native-qiniu-uploader)
![Platform - Android and iOS](https://img.shields.io/badge/platform-Android%20%7C%20iOS-yellow.svg)
![MIT](https://img.shields.io/dub/l/vibe-d.svg)

| Author        |     E-mail      |
| ------------- |:---------------:|
| gufei         | 799170694@qq.com|

## 功能介绍

- 支持 iOS Android  七牛云存储断点续传
- 支持 上传图片和视频等其他文件
 
 ## android 环境配置
 
 - 拷贝 android/RCTQiniu 文件夹下的所有文件至项目 app/src/main/java/com.yourcompany.qiniu/ 根目录
 
 - app/build.gradle 文件中新增：
 ```
 compile 'com.qiniu:qiniu-android-sdk:7.3.+'
 ```
 - proguard-rules.pro 文件中新增混淆：
 ``` 
-keep class com.qiniu.**{*;}
-keep class com.qiniu.**{public <init>();}
-ignorewarnings
```

 - AndroidManifest.xml文件中添加授权：
 ```
 <uses-permission android:name="android.permission.CAMERA" />
 <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
 ```
 ## iOS 环境配置

- 拷贝 ios/RCTQiniu 文件夹下的所有文件至项目 ios/ios_proj_name/ 根目录
- cd rn_proj_name/ios/，执行 Pod init，生成 Podfile 和 Podfile.lock
- 打开 Podfile，添加 pod "Qiniu", "~> 7.1.5"
- 执行 Pod install

```
info.plist文件中添加授权：
<plist version="1.0">
  <dict>
    ...
    <key>NSPhotoLibraryUsageDescription</key>
    <string>$(PRODUCT_NAME) would like access to your photo gallery</string>
    <key>NSCameraUsageDescription</key>
    <string>$(PRODUCT_NAME) would like to use your camera</string>
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>$(PRODUCT_NAME) would like to save photos to your photo gallery</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>$(PRODUCT_NAME) would like to your microphone (for videos)</string>
  </dict>
</plist>
```

## react-native
```
  拷贝QNEngine.js文件至ReactNative项目中

  import {QNEngine} from '../libs/QNEngine'
  
  componentDidMount() {
    //所有的原生通知统一管理
    QNEngine.eventEmitter({
            onProgress: (data) => {
                console.log(data.percent);
            },
            onComplete: (data) => {
                console.log(data)
            },
            onError: (data) => {
                console.log(data);
                switch (data.code) {
                    case '-2':
                        Toast.info('任务已暂停', 2)
                        break;
                    default:
                        Toast.fail('错误：' + data.msg, 2)
                        break;
                }
            }        
    })    
 }

  componentWillUnmount() {
    QNEngine.removeEmitter()
  }
  
  /**
  * @param filePath:文件路径
  * @param upKey:文件名（唯一，不能重复）
  * @param upToken:上传token，服务端获取或本地生成
  * @param zone:上传至指定区域：华东：1,华北：2,华南：3,北美：4
  */     
  const params = {
        filePath: '文件路径',
        upKey: '文件名字',
        upToken: '上传token',
        zone: 1
       }
  QNEngine.setParams(params)
  
  // 开始上传任务
  QNEngine.startTask()
  
  // 暂停上传任务
  QNEngine.pauseTask()
  
  // 恢复上传任务
  QNEngine.resumeTask()
  
```

## 错误码

```
  1000 ：success
  1001 ：fail

  七牛错误代码：
  -2 ：任务暂停
  -4 ：文件路径不正确
  ...
```

## 运行示例

[Example](https://github.com/midas-gufei/react-native-qiniu-uploader-demo)

## 运行示例图
 
 <center class="half">
    <a href="https://raw.githubusercontent.com/midas-gufei/react-native-qiniu-uploader/master/screen-shoot/uploading.png"><img width="375" height="667" src="https://raw.githubusercontent.com/midas-gufei/react-native-qiniu-uploader/master/screen-shoot/uploading.png"/></a>
    <a href="https://raw.githubusercontent.com/midas-gufei/react-native-qiniu-uploader/master/screen-shoot/pause.png"><img width="375" height="667" src="https://raw.githubusercontent.com/midas-gufei/react-native-qiniu-uploader/master/screen-shoot/pause.png"/></a>
</center> 
<center class="half">
    <a href="https://raw.githubusercontent.com/midas-gufei/react-native-qiniu-uploader/master/screen-shoot/android-uploading.png"><img width="375" height="750" src="https://raw.githubusercontent.com/midas-gufei/react-native-qiniu-uploader/master/screen-shoot/android-uploading.png"/></a>
    <a href="https://raw.githubusercontent.com/midas-gufei/react-native-qiniu-uploader/master/screen-shoot/android-pause.png"><img width="375" height="750" src="https://raw.githubusercontent.com/midas-gufei/react-native-qiniu-uploader/master/screen-shoot/android-pause.png"/></a>
</center>

## 更新信息

#### 2018-04-26
- iOS/Android 新增文件唯一主键，并在上传过程中返回js

#### 2018-04-21
- Android 客户端封装完成

#### 2018-04-20
- iOS 客户端封装完成

