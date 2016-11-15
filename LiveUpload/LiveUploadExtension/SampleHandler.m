//
//  SampleHandler.m
//  KSYRKUploadExt
//
//  Created by yiqian on 9/28/16.
//  Copyright © 2016 ksyun. All rights reserved.
//

#import "SampleHandler.h"
#import "KSYRKStreamerKit.h"

//  To handle samples with a subclass of RPBroadcastSampleHandler set the following in the extension's Info.plist file:
//  - RPBroadcastProcessMode should be set to RPBroadcastProcessModeSampleBuffer
//  - NSExtensionPrincipalClass should be set to this class

@implementation SampleHandler

#pragma mark - RPBroadcastSampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    for ( NSString* info in  setupInfo.allKeys) {
        NSLog(@"cfg: %@ = %@",info, [setupInfo valueForKey:info] );
    }
    KSYRKStreamerKit* kit =[KSYRKStreamerKit sharedInstance];
    // setup video resolution
    kit.videoResolution = (NSString*)[setupInfo valueForKey:@"videoResolution"];
    kit.videoCodec = (NSString*)[setupInfo valueForKey:@"videoCodec"];
    // start stream
    NSString * str = (NSString*)[setupInfo valueForKey:@"endpointURL"];
    NSURL * url= [NSURL URLWithString:str];
    [kit startStream: url];
}

- (void)broadcastPaused {
    KSYRKStreamerKit* kit =[KSYRKStreamerKit sharedInstance];
    [kit.streamerBase stopStream];
}

- (void)broadcastResumed {
    KSYRKStreamerKit* kit =[KSYRKStreamerKit sharedInstance];
    [kit.streamerBase startStream:kit.rtmpUrl];
}

- (void)broadcastFinished {
    KSYRKStreamerKit* kit =[KSYRKStreamerKit sharedInstance];
    [kit.streamerBase stopStream];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer
                   withType:(RPSampleBufferType)sampleBufferType {
    KSYRKStreamerKit* kit =[KSYRKStreamerKit sharedInstance];
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            [kit.streamerBase processVideoSampleBuffer:sampleBuffer];
            break;
        case RPSampleBufferTypeAudioApp:
            [kit mixAudio:sampleBuffer to:kit.appTrack];
            break;
        case RPSampleBufferTypeAudioMic:
            [kit mixAudio:sampleBuffer to:kit.micTrack];
            break;
        default:
            break;
    }
}
@end
