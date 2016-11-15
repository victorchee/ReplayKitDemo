//
//  SampleHandler.h
//  KSYRKUploadExt
//
//  Created by yiqian on 9/28/16.
//  Copyright © 2016 ksyun. All rights reserved.
//

#import <ReplayKit/ReplayKit.h>
#import "libksygpulive/libksygpulive.h"


@interface KSYRKStreamerKit : NSObject

/** 单例 */
+ (KSYRKStreamerKit*) sharedInstance;

/** 直播服务器的地址 */
@property (nonatomic, assign) NSURL        *rtmpUrl;

/** 直播视频的分辨率 (字符串解析为宽x高)*/
@property (nonatomic, assign) NSString     *videoResolution;
/** 视频编码器 */
@property (nonatomic, assign) NSString     *videoCodec;

/**
 @abstract   获取初始化时创建的底层推流工具
 @discussion 1. 通过它来设置推流参数
 @discussion 2. 通过它来启动，停止推流
 */
@property (nonatomic, readonly) KSYStreamerBase        *streamerBase;

/**
 @abstract   开始向url对应的地址推流
 @param      url 推流地址
 */
- (void) startStream : (NSURL*) url;

/** 麦克风通道 */
@property (nonatomic, readonly) int micTrack;
/** APP声音通道 */
@property (nonatomic, readonly) int appTrack;

/**
 @abstract   音频混合器
 @discussion 用于将多路音频进行混合,将混合后的音频送入streamerBase
 */
@property (nonatomic, readonly) KSYAudioMixer          *aMixer;

/**
 @abstract   将声音送入混音器
 @param      buf 声音数据
 @param      idx 音频通道
 */
- (void) mixAudio:(CMSampleBufferRef)buf
               to:(int)idx;
@end
