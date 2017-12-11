//
//  AudioEncodeVC.m
//  LVAudioAndVideo
//
//  Created by LV on 2017/11/29.
//  Copyright © 2017年 LV. All rights reserved.
//

#import "AudioEncodeVC.h"
#import <AudioToolbox/AudioConverter.h>

#import <AudioToolbox/AudioToolbox.h>

@interface AudioEncodeVC () {
    AudioStreamBasicDescription outputAudioStreamBasicDescription;
}
@end

@implementation AudioEncodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configure];
}

- (void)configure {
    
}

@end
























