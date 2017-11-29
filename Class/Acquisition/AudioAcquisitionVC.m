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
    compoentDesc.componentType      = kAudioUnitType_Output;
    compoentDesc.componentSubType   = kAudioUnitSubType_RemoteIO;
    compoentDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    compoentDesc.componentFlags     = 0;
    compoentDesc.componentFlagsMask = 0;
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &compoentDesc);
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    
    //为录制播放开启IO
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    
    //描述音频格式
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mSampleRate = 44100; ///< 标准44.1KHZ
    audioFormat.mFormatID = kAudioFormatLinearPCM; //liner pulse-code modulation
    audioFormat.mFramesPerPacket = 1;//数据包多少帧
    audioFormat.mChannelsPerFrame = 1; //1单声道 2立体声
    audioFormat.mBitsPerChannel = 16; //采样点16位
    audioFormat.mBytesPerPacket = 2; //数据包的字节总数
    audioFormat.mBytesPerFrame = 2; //每帧子节数
    
}

#pragma mark - Private Method



@end
