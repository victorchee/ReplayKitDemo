//
//  BroadcastViewController.m
//  LiveUploadExtensionUI
//
//  Created by VictorChee on 2016/11/14.
//  Copyright © 2016年 VictorChee. All rights reserved.
//

#import "BroadcastViewController.h"

@interface BroadcastViewController()

@property (weak, nonatomic) IBOutlet UITextField *addressTextField;

@end

@implementation BroadcastViewController

- (IBAction)broadcast:(UIButton *)sender {
    [self userDidFinishSetup];
}

// Called when the user has finished interacting with the view controller and a broadcast stream can start
- (void)userDidFinishSetup {
    NSString *address = self.addressTextField.text;
    if (address.length == 0) {
        address = self.addressTextField.placeholder;
    }
    
    // Broadcast url that will be returned to the application
    NSURL *broadcastURL = [NSURL URLWithString:address];
    
    // Service specific broadcast data example which will be supplied to the process extension during broadcast
    NSString *userID = @"user1";
    NSString *endpointURL = address;
    NSString *videoCodec = @"hard";
    NSDictionary *setupInfo = @{ @"userID" : userID, @"endpointURL" : endpointURL, @"videoCodec" : videoCodec };
    
    // Set broadcast settings
    RPBroadcastConfiguration *broadcastConfig = [[RPBroadcastConfiguration alloc] init];
    broadcastConfig.clipDuration = 5.0; // deliver movie clips every 5 seconds
    
    // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
    [self.extensionContext completeRequestWithBroadcastURL:broadcastURL broadcastConfiguration:broadcastConfig setupInfo:setupInfo];
}

- (void)userDidCancelSetup {
    // Tell ReplayKit that the extension was cancelled by the user
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"YourAppDomain" code:-1     userInfo:nil]];
}

@end
