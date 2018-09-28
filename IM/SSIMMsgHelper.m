//
//  SSIMMsgHelper.m
//  SSportsIMtest
//
//  Created by zx on 17/3/6.
//  Copyright © 2017年 zx. All rights reserved.
//

#import "SSIMMsgHelper.h"
#import <ImSDK/ImSDK.h>
#import "SSIMMessage.h"

@interface SSIMMsgHelper ()<TIMMessageListener> {
    NSString *_roomID;
}

@end

@implementation SSIMMsgHelper

- (instancetype)initWithChatRoom:(NSString *)roomID
{
    if (self = [super init]) {
        _roomID = roomID;
        [[TIMManager sharedInstance] setMessageListener:self];
    }
    return self;
}

- (void)dealloc
{
    [[TIMManager sharedInstance] removeMessageListener:self];
}


#pragma mark - public

- (void)sendMessage:(SSIMMessage *)message success:(SSIMSuccess)success failed:(SSIMFail)fail
{
    
    TIMMessage *tMessage = [message getTIMMessage];
    
    // get the conversation
    TIMConversation *conversation = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:_roomID];
    
    // send
    [conversation sendMessage:tMessage succ:^{
        
        // success
        NSLog(@"发送成功！");
        if (success) {
            success();
        }
        
    } fail:^(int code, NSString *msg) {
        
        // failed
        NSLog(@"发送失败！［%d-%@］", code, msg);
        if (fail) {
            fail(code, msg);
        }
    }];
}

- (int)getMessages:(int)count last:(id)last success:(SSIMGetMessageSuccess)success failed:(SSIMFail)fail
{
    
    // get the conversation
    TIMConversation *conversation = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:_roomID];
    int operation = [conversation getMessage:count last:last succ:^(NSArray *msgs) {
        
        // fetch success
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:msgs.count];
        for (TIMMessage *msg in msgs) {
            SSIMMessage * sMessage = [SSIMMessage messageWith:msg];
            [result addObject:sMessage];

        }
        
        if (success) {
            success(result);
        }
        
    } fail:^(int code, NSString *msg) {
        
        // fetch failed
        if (fail) {
            fail(code, msg);
        }
        
    }];
    
    return operation;
}

#pragma mark - private

// new chat message
- (void)onNewChatMessage:(TIMMessage *)message
{
    
    SSIMMessage *msg = [SSIMMessage messageWith:message];
    
    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:)]) {
        [self.delegate didReceiveMessage:msg];
    }
    
}

#pragma mark - TIMMessageListener

- (void)onNewMessage:(NSArray *)msgs
{
    for(TIMMessage *msg in msgs)
    {
        TIMConversationType conversationType = msg.getConversation.getType;
        
        switch (conversationType)
        {
            case TIM_C2C:{} break;
                
            case TIM_GROUP:{
                
                if([[msg.getConversation getReceiver] isEqualToString:_roomID]) {
                    
                    // 只接受来自该聊天室的消息
                    [self onNewChatMessage:msg];
                    
                }
                
            } break;
                
            case TIM_SYSTEM:{} break;
                
            default:
                break;
        }
    }
}

@end
