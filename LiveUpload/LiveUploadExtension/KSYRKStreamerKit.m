//
//  SampleHandler.m
//  KSYRKUploadExt
//
//  Created by yiqian on 9/28/16.
//  Copyright © 2016 ksyun. All rights reserved.
//


#import "KSYRKStreamerKit.h"

@interface KSYRKStreamerKit(){
}

@end

@implementation KSYRKStreamerKit

+ (KSYRKStreamerKit*)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[KSYRKStreamerKit alloc] initWithDefaultCfg];
    });
    return _sharedObject;
}

- (id) initWithDefaultCfg {
    self = [super init];
    _rtmpUrl = nil;
    // 创建 推流模块
    _streamerBase = [[KSYStreamerBase alloc] initWithDefaultCfg];
    
    // init cfgs
    _streamerBase.videoCodec = KSYVideoCodec_VT264;
    _streamerBase.audioCodec = KSYAudioCodec_AAC;
    _streamerBase.videoMaxBitrate  = 800;
    _streamerBase.videoInitBitrate = 200;
    _streamerBase.videoMinBitrate  = 0;
    
    // 核心部件:音频叠加混合
    _aMixer = [[KSYAudioMixer alloc]init];
    _micTrack = 0;
    _appTrack = 1;
    // 组装音频通道
    [self setupAudioPath];
    [self addObservers];
    return self;
}
- (void)dealloc {
    NSLog(@"dealloc KSYRKStreamerKit");
    [self rmObservers];
}


/**
 @abstract   开始向url对应的地址推流
 @param      url 推流地址
 */
- (void) startStream : (NSURL*) url {
    _rtmpUrl = url;
    _streamerBase.videoCodec = [self getVideoCodec];
    _streamerBase.audioCodec = KSYAudioCodec_AT_AAC;
    [_streamerBase startStream:url];
}

- (KSYVideoCodec) getVideoCodec{
    if ([_videoCodec isEqualToString:@"hard"]) {
        return KSYVideoCodec_AUTO;
    }
    else {
        return KSYVideoCodec_X264;
    }
}

- (void) addObservers {
    //KSYStreamer state changes
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(onStreamStateChange:)
               name:KSYStreamStateDidChangeNotification
             object:nil];
    [dc addObserver:self
           selector:@selector(onNetStateEvent:)
               name:KSYNetStateEventNotification
             object:nil];
}

- (void) rmObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) onStreamStateChange :(NSNotification *)notification{
    NSLog(@"stream State %@", [_streamerBase getCurStreamStateName]);
    if(_streamerBase.streamState == KSYStreamStateError) {
        [self onStreamError: _streamerBase.streamErrorCode];
    }
}
- (void) onStreamError:(KSYStreamErrorCode) errCode{
    NSLog(@"stream Error %@", [_streamerBase getCurKSYStreamErrorCodeName]);
    if (errCode == KSYStreamErrorCode_CONNECT_BREAK ||
        errCode == KSYStreamErrorCode_ENCODE_FRAMES_FAILED ||
        errCode == KSYStreamErrorCode_CODEC_OPEN_FAILED) {
        // Reconnect
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            [_streamerBase startStream:_rtmpUrl];
        });
    }
}
- (void) onNetStateEvent     :(NSNotification *)notification{
    NSLog(@"netevent %lu", (unsigned long)_streamerBase.netStateCode);
}

#pragma mark - audio config
// 将声音送入混音器
- (void) mixAudio:(CMSampleBufferRef)buf to:(int)idx{
    if (![_streamerBase isStreaming]){
        return;
    }
    [_aMixer processAudioSampleBuffer:buf of:idx];
}
// 组装声音通道
- (void) setupAudioPath {
    __weak KSYRKStreamerKit * kit = self;
    // 混音结果送入streamer
    _aMixer.audioProcessingCallback = ^(CMSampleBufferRef buf){
        if (![kit.streamerBase isStreaming]){
            return;
        }
        [kit.streamerBase processAudioSampleBuffer:buf];
    };
    // mixer 的主通道为麦克风,时间戳以main通道为准
    _aMixer.mainTrack = _micTrack;
    [_aMixer setTrack:_micTrack enable:YES];
    [_aMixer setTrack:_appTrack enable:YES];
}

@end
