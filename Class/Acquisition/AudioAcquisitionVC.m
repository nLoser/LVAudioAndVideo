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
@property (nonatomic, strong) UISegmentedControl * control;
@end

@implementation AudioAcquisitionVC

- (instancetype)init {
    if (self = [super init]) {
        [self configure];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.control];
}

- (void)dealloc {
    [self audioComponentInstanceDispose];
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
    checkStatus(status);
    
    //[2]为录制播放开启IO
    UInt32 flag = 1;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
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
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkStatus(status);
    
    //[4]为录制播放设置回调函数
    AURenderCallbackStruct inputCallbackStruct;
    inputCallbackStruct.inputProc = inputHandleCallback;
    inputCallbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &inputCallbackStruct,
                                  sizeof(inputCallbackStruct));
    checkStatus(status);
    
    AURenderCallbackStruct outputCallbackkStruct;
    outputCallbackkStruct.inputProc = outputHandleCallback;
    outputCallbackkStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &outputCallbackkStruct,
                                  sizeof(outputCallbackkStruct));
    checkStatus(status);
    
    //[5]使用自己分配的缓冲区，关闭系统提供的缓冲区
    flag = 0;
    status = AudioUnitSetProperty(audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus, //Element1 和 outputScope的交集
                                  &flag,
                                  sizeof(flag));
    checkStatus(status);
    
    //[6]实例化Audio Unit
    status = AudioUnitInitialize(audioUnit);
    checkStatus(status);
}

#pragma mark - Private Method

OSStatus inputHandleCallback(void *                            inRefCon,
                       AudioUnitRenderActionFlags *    ioActionFlags,
                       const AudioTimeStamp *            inTimeStamp,
                       UInt32                            inBusNumber,
                       UInt32                            inNumberFrames,
                       AudioBufferList * __nullable    ioData)
{
    
    AudioAcquisitionVC * THIS = (__bridge AudioAcquisitionVC *)inRefCon;
    
    OSStatus status;
    status = AudioUnitRender(THIS->audioUnit,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             &(THIS->bufferList));
    
    return noErr;
}

OSStatus outputHandleCallback(void *                            inRefCon,
                        AudioUnitRenderActionFlags *    ioActionFlags,
                        const AudioTimeStamp *            inTimeStamp,
                        UInt32                            inBusNumber,
                        UInt32                            inNumberFrames,
                        AudioBufferList * __nullable    ioData)
{
    NSLog(@"%d",(unsigned int)inBusNumber);
    return noErr;
}

static void checkStatus(OSStatus status) {
    if (status != noErr) {
        NSLog(@"%d",(int)status);
    }else {
        NSLog(@"success");
    }
}

#pragma mark - Target Action

- (void)audioOutputUnitStart {
    OSStatus status = AudioOutputUnitStart(audioUnit);
    checkStatus(status);
}

- (void)audioOutputUnitStop {
    OSStatus status = AudioOutputUnitStop(audioUnit);
    checkStatus(status);
}

- (void)audioComponentInstanceDispose {
    AudioComponentInstanceDispose(audioUnit);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)click:(UISegmentedControl *)control {
    switch (control.selectedSegmentIndex) {
        case 0:
            [self audioOutputUnitStart];
            break;
        case 1:
            [self audioOutputUnitStop];
            break;
        case 2:
            [self audioComponentInstanceDispose];
            break;
        default:
            break;
    }
}

#pragma mark - Getter

- (UISegmentedControl *)control {
    if (!_control) {
        NSArray * arr = @[@"开始采集",@"关闭采集",@"结束采集"];
        _control = [[UISegmentedControl alloc] initWithItems:arr];
        _control.frame = CGRectMake(0, 100, CGRectGetWidth(self.view.frame), 50);
        [_control addTarget:self action:@selector(click:) forControlEvents:UIControlEventValueChanged];
    }
    return _control;
}

@end






