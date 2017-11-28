//
//  Test.m
//  LVAudioAndVideo
//
//  Created by LV on 2017/11/28.
//  Copyright © 2017年 LV. All rights reserved.
//  代码地址:http://blog.sina.com.cn/s/blog_942d71bb0102w9sg.html

#import "Test.h"
#import <AudioToolbox/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>

/*
 1.Drivers and Hardware
 2.Audio Unit
 3.Open AL / Audio ToolBox
 4.Media Player
 */

//接收区数据为一个循环队列
#define kRawDataLen (512*100)
typedef struct {
    NSInteger front;
    NSInteger rear;
    SInt16 receiveRawData[kRawDataLen];
}RawData;

#define kOutputBus 0
#define kInputBus 1

@interface Test() {
    AudioStreamBasicDescription audioFormat;
    AudioComponentInstance audioUnit;
    RawData _rawData;
}
@property (nonatomic,weak)   AVAudioSession *session;
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
    
    
    NSError *error;
    self.session = [AVAudioSession sharedInstance];
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [self.session setPreferredSampleRate:0.005 error:nil];
    [self.session setPreferredIOBufferDuration:44100 error:nil];
    [self.session setActive:YES error:nil];
    
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
    
    audioFormat.mSampleRate       = 44100.0;
    audioFormat.mFormatID         = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags      = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    audioFormat.mFramesPerPacket  = 1; //每个数据包多少帧
    audioFormat.mChannelsPerFrame = 1; //1单声道 2立体声
    audioFormat.mBitsPerChannel   = 16;//语音采样点占用位数
    audioFormat.mBytesPerPacket   = 2; //每个数据包的子节总数
    audioFormat.mBytesPerFrame    = 2; //每帧子节数
    
    //设置格式
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    
    //设置数据采集回调函数
    AURenderCallbackStruct inputCallbackStruct;
    AURenderCallbackStruct outputcallbackStruct;
    
    inputCallbackStruct.inputProc = recordingCallback;
    inputCallbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &inputCallbackStruct,
                                  sizeof(inputCallbackStruct));
    checkStatus(status);
    
    //设置声音输出回调函数，当speaker需要数据时就会调用回调函数去获取数据。它是‘拉’数据的概念。
    outputcallbackStruct.inputProc = playbackCallback;
    outputcallbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &outputcallbackStruct,
                                  sizeof(outputcallbackStruct));
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
}


- (void)readyStart {
    OSStatus status = AudioOutputUnitStart(audioUnit);
    checkStatus(status);
}

- (void)readyClose {
    OSStatus status = AudioOutputUnitStop(audioUnit);
    checkStatus(status);
}

- (void)readyDispose {
    AudioComponentInstanceDispose(audioUnit);
}

#pragma mark - CallBack

void checkStatus(OSStatus status) {
    if (status != 0) {
        printf("Error:%d",(int)status);
    }
}

//录制回调
 OSStatus recordingCallback(void *inRefCon,
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
    status = AudioUnitRender(THIS->audioUnit,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             &(THIS->_bufferList));
    checkStatus(status);
    //现在，我们想要的audio采样数据已经放在bufferList中的buffers中了
    
    return noErr;
}



 OSStatus playbackCallback(void *inRefCon,
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
    
//    Test *THIS=(__bridge Test*)inRefCon;
//
//    SInt16 *outSamplesChannelLeft   = (SInt16 *)ioData->mBuffers[0].mData;
//    RawData *rawData = &THIS->_rawData;
//    for (UInt32 frameNumber = 0; frameNumber < inNumberFrames; ++frameNumber) {
//        if (rawData->front != rawData->rear) {
//            outSamplesChannelLeft[frameNumber] = (rawData->receiveRawData[rawData->front]);
//            rawData->front = (rawData->front+1)%kRawDataLen;
//
//        }
//    }
    return 0;
}

@end
