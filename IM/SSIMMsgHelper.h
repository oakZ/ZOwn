//
//  SSIMMsgHelper.h
//  SSportsIMtest
//
//  Created by zx on 17/3/6.
//  Copyright © 2017年 zx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSIMCommon.h"

@interface SSIMMsgHelper : NSObject

@property (nonatomic, weak) id<SSIMMsgDelegate> delegate;

- (instancetype)initWithChatRoom:(NSString *)roomID;

/**
 发送消息

 @param message 消息实例
 @param success 成功回调
 @param fail 失败回调
 */
- (void)sendMessage:(SSIMMessage *)message success:(SSIMSuccess)success failed:(SSIMFail)fail;

/**
 获取会话消息

 @param count 获取数量
 @param last 上次最后一条消息，如果传入nil，将从最新的消息开始获取
 @param success 获取成功回调
 @param fail 获取失败回调
 @return 0 成功
 */
- (int)getMessages:(int)count last:(id)last success:(SSIMGetMessageSuccess)success failed:(SSIMFail)fail;

@end
