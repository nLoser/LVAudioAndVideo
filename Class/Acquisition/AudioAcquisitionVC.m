//
//  AudioAcquisitionVC.m
//  LVAudioAndVideo
//
//  Created by LV on 2017/11/29.
//  Copyright © 2017年 LV. All rights reserved.
//

#import "AudioAcquisitionVC.h"
#import <AudioToolbox/AudioUnit.h>

#define kInputBus  1
#define kOutputBus 0

@interface AudioAcquisitionVC () {
    AudioComponentInstance audioUnit; ///< AudioUnit
    AudioStreamBasicDescription audioFormat; ///< 描述音频格式
    AudioBufferList bufferList; ///< 缓冲区
}
@end

@implementation AudioAcquisitionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - configure

- (void)configure {
    OSStatus status;
    
    //创建AuidoUnit
    AudioComponentDescription compoentDesc;
    compoentDesc.componentType = kAudioUnitType_Output;
    compoentDesc.componentSubType = kAudioUnitSubType_RemoteIO;
    compoentDesc.componentFlags = 0;
    compoentDesc.componentFlagsMask = 0;
    compoentDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
}

#pragma mark - Private Method



@end
