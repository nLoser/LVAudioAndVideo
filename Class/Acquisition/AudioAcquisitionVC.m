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
    
    //[1]创建AuidoUnit
    AudioComponentDescription compoentDesc;
    compoentDesc.componentType      = kAudioUnitType_Output;
    compoentDesc.componentSubType   = kAudioUnitSubType_RemoteIO;
    compoentDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    compoentDesc.componentFlags     = 0;
    compoentDesc.componentFlagsMask = 0;
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &compoentDesc);
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    
    //[2]为录制播放开启IO
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
    
    //[3]描述音频格式
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mSampleRate = 44100; ///< 标准44.1KHZ
    audioFormat.mFormatID = kAudioFormatLinearPCM; //liner pulse-code modulation
    audioFormat.mFramesPerPacket = 1;//数据包多少帧
    audioFormat.mChannelsPerFrame = 1; //1单声道 2立体声
    audioFormat.mBitsPerChannel = 16; //采样点16位
    audioFormat.mBytesPerPacket = 2; //数据包的字节总数
    audioFormat.mBytesPerFrame = 2; //每帧子节数
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    
    //[4]为录制播放设置回调函数
    AURenderCallbackStruct inputCallbackStruct;
    inputCallbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    inputCallbackStruct.inputProc = inputCallback;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &inputCallbackStruct,
                                  sizeof(inputCallbackStruct));
    AURenderCallbackStruct outputCallbackkStruct;
    outputCallbackkStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    outputCallbackkStruct.inputProc = outputCallback;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &outputCallbackkStruct,
                                  sizeof(outputCallbackkStruct));
    
    //[5]使用自己分配的缓冲区，关闭系统提供的缓冲区
    flag = 0;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    
    //[6]实例化Audio Unit
    status = AudioUnitInitialize(audioUnit);
}

#pragma mark - Private Method

OSStatus inputCallback(void *                            inRefCon,
                       AudioUnitRenderActionFlags *    ioActionFlags,
                       const AudioTimeStamp *            inTimeStamp,
                       UInt32                            inBusNumber,
                       UInt32                            inNumberFrames,
                       AudioBufferList * __nullable    ioData)
{
    
    return noErr;
}

OSStatus outputCallback(void *                            inRefCon,
                        AudioUnitRenderActionFlags *    ioActionFlags,
                        const AudioTimeStamp *            inTimeStamp,
                        UInt32                            inBusNumber,
                        UInt32                            inNumberFrames,
                        AudioBufferList * __nullable    ioData)
{
    
    return noErr;
}

@end
