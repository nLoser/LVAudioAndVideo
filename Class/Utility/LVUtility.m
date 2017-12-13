//
//  LVUtility.m
//  LVAudioAndVideo
//
//  Created by LV on 2017/12/8.
//  Copyright © 2017年 LV. All rights reserved.
//

#import "LVUtility.h"
#import <UIKit/UIKit.h>
#import <pthread.h>

typedef struct __BlendSELContext {
    const char * name;
    SEL method;
} *BlendSELContext ,LVBlendSELContext;

typedef struct __LVDispatchContext{
    const char * name;
    void ** queues;
    uint32_t queueCount;
    int32_t offset;
} *DispatchContext, LVDispatchContext;

static DispatchContext __LVDispatchContextCreate(const char * name,
                                                 uint32_t queueCount,
                                                 NSQualityOfService qos) {
    DispatchContext context = calloc(1, sizeof(LVDispatchContext));
    if (context == NULL) return NULL;
    
    context->queues = calloc(queueCount, sizeof(void *));
    if (context->queues == NULL) {
        free(context);
        return NULL;
    }
    
    for (int idx = 0; idx < queueCount; idx++) {
        dispatch_queue_t queue = dispatch_queue_create("lv", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, qos, 0));
        context->queues[idx] = (__bridge_retained void *)queue;
    }
    
    context->queueCount = queueCount;
    if (name) {
        context->name = strdup(name);
    }
    
    context->offset = 0;
    
    return context;
}

static void LVTransiaction(){
    
}

@interface LVUtility () {
    NSSet * _set;
}
@end
@implementation LVUtility

- (instancetype)init
{
    self = [super init];
    if (self) {
        //pthread_t//struct *
        //CFRunLoopRef
        //_CFSetTSD()
        //CFRunLoopGetMain();
        //CFRunLoopGetCurrent();
        //对应：
        //[NSThread mainThread];
        //[NSThread currentThread];
        //pthread_main_np();
        //pthread_self();
        
        //model item
        //UITrackingRunLoopMode
        //kCFRunLoopCommonModes
        //kCFRunLoopDefaultMode
        //NSRunLoopCommonModes
        //[[NSRunLoop mainRunLoop] addTimer:[NSTimer new] forMode:NSRunLoopCommonModes];
        
        //[NSRunLoop currentRunLoop];// 创建了当前runloop
        
        //runloop 创建是在第一次获取时
        
        
    }
    return self;
}

@end
