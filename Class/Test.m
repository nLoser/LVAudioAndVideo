//
//  Test.m
//  LVAudioAndVideo
//
//  Created by LV on 2017/11/28.
//  Copyright © 2017年 LV. All rights reserved.
//  代码地址:http://blog.sina.com.cn/s/blog_942d71bb0102w9sg.html

#import "Test.h"
#import <AudioToolbox/AudioUnit.h>

/*
 1.Drivers and Hardware
 2.Audio Unit
 3.Open AL / Audio ToolBox
 4.Media Player
 */


#define kOutputBus 0
#define kInputBus 1

@interface Test()
@property (nonatomic, assign) AudioUnit rioUnit;
@property (nonatomic, assign) AudioBufferList bufferList;
@end

@implementation Test

- (instancetype)init {
    if (self = [super init]) {
        [self getAudioComponentInstance];
    }
    return self;
}

- (void)getAudioComponentInstance {
    OSStatus status;
    AudioComponentInstance audioUnit;
    
    //描述
    AudioComponentDescription desc;
    desc.componentType      = kAudioUnitType_Output;
    desc.componentSubType   = kAudioUnitSubType_RemoteIO;
    desc.componentFlags     = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    //元件
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    //Audio Unit
    status = AudioComponentInstanceNew(inputComponent, &audioUnit);
    checkStatus(status);
    
    //为录制打开IO
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    //为播放打开IO
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate       = 44100.0;
    audioFormat.mFormatID         = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket  = 1;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel   = 16;
    audioFormat.mBytesPerPacket   = 2;
    audioFormat.mBytesPerFrame    = 2;
    
    //设置格式
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    
    //设置数据采集回调函数
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status);
    
    //设置声音输出回调函数，当speaker需要数据时就会调用回调函数去获取数据。它是‘拉’数据的概念。
    callbackStruct.inputProc = playbackCallback;
    callbackStruct.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkStatus(status);
    
    //关闭为录制分配的缓冲区，使用自定义缓冲区
    flag = 0;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    //初始化
    status = AudioUnitInitialize(audioUnit);
    checkStatus(status);
    
    _rioUnit = audioUnit;
}


- (void)readyStart {
    OSStatus status = AudioOutputUnitStart(_rioUnit);
    checkStatus(status);
}

- (void)readyClose {
    OSStatus status = AudioOutputUnitStop(_rioUnit);
    checkStatus(status);
}

- (void)readyDispose {
    AudioComponentInstanceDispose(_rioUnit);
}

#pragma mark - CallBack

void checkStatus(OSStatus status) {
    if (status != 0) {
        printf("Error:%d",(int)status);
    }
}

//录制回调
static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    //TODO:
    //1.使用inNumberFrames计算有多少数据是有效的
    //2.在audioBufferlist里面存放更多的有效空间
    
    Test * THIS = (__bridge Test *)inRefCon;
    
    OSStatus status;
    status = AudioUnitRender(THIS.rioUnit,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             &(THIS->_bufferList));
    checkStatus(status);
    //现在，我们想要的audio采样数据已经放在bufferList中的buffers中了
    
    
    return noErr;
}

static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    // Notes: ioData contains buffers (may be more than one!)
    // Fill them up as much as you can. Remember to set the size value in each buffer to match how
    // much data is in the buffer.
    //中文：ioData包含很多buffers
    //尽量填充ioData的数据，记得设置每一个buffer的大小要与buffer匹配好。
    return noErr;
}

@end
