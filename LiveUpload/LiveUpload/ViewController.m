//
//  ViewController.m
//  LiveUpload
//
//  Created by Migu on 2016/11/14.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "ViewController.h"
#import "KSYRKStreamerKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    KSYRKStreamerKit* kit =[KSYRKStreamerKit sharedInstance];
    // setup video resolution
    kit.videoResolution = nil;
    kit.videoCodec = @"hard";
    // start stream
    NSURL * url= [NSURL URLWithString:@"rtmp://172.29.17.253:7000/hls/test"];
    [kit startStream: url];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
