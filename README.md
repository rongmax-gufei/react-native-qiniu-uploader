# README
| Author        |     E-mail      |
| ------------- |:---------------:|
| gufei         | 799170694@qq.com|

# react-native-qiniu-uploader

## 功能介绍

- 基于七牛云存储，封装支持断点续传的React-Native控件，支持 iOS Android

## 安装使用

 `npm install --save react-native-qiniu-uploader`

Then link with:

 `react-native link react-native-qiniu-uploader`
 
 ## iOS环境配置
```
1、cd proj_name/ios/，执行 Pod init，生成 Podfile 和 Podfile.lock
2、打开 Podfile，添加 pod "Qiniu", "~> 7.1.5"
3、执行 Pod install
4、将如下三个下载的文件路径拖拽到Targets/proj_name/Build Settings/Header Search Paths/
  proj_name/ios/Pods/Headers/Public/AFNetworking
  proj_name/ios/Pods/Headers/Public/HappyDNS
  proj_name/ios/Pods/Headers/Public/Qiniu
```
## react-native
```
  import { RtcEngine } from 'react-native-qiniu-uploader'
  
  componentWillMount() {
    const options = {
      token: '111',
      useHttps: true,// useHttps:使用https=true，否则false
      zoneTarget: 1 // zoneTarget:华东1,华北2,华南3,北美4
    }
    RtcEngine.init(options)
  }

  componentDidMount() {
    //所有的原生通知统一管理
    RtcEngine.eventEmitter({
      onUploading: (data) => {
          console.log(data);
      },
      onComplete: (data) => {
          console.log(data)
      },
      onError: (data) => {
          console.log(data);
      }
    })
  }

  componentWillUnmount() {
    RtcEngine.removeEmitter()
  }
  
  // 上传文件fileurl：文件路径，filename：文件名字
  RtcEngine.uploadFileToQiniu(fileurl, filename)
  // 取消上传
  RtcEngine.cancelUploadTask()       
```

## 运行示例

[Example](https://github.com/midas-gufei/react-native-qiniu-uploader-demo)


