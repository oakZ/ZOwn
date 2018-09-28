//
//  SSIMMessage.h
//  SSportsIMtest
//
//  Created by zx on 17/3/7.
//  Copyright © 2017年 zx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSIMCommon.h"

@class TIMMessage;

extern NSString * const kMessageExtraUidKey;
extern NSString * const kMessageExtraNicknameKey;
extern NSString * const kMessageExtraAvatarKey;
extern NSString * const kMessageExtraUserLevelKey;

@interface SSIMMessage : NSObject

@property (nonatomic, copy, readonly) NSString *senderID;

@property (nonatomic, assign, readonly) SSIMMsgType type;

@property (nonatomic, copy, readonly) NSString *text;

@property (nonatomic, copy, readonly) NSDictionary *extra; // 用于携带用户信息



/**
 将底层SDK返回的消息转换

 @param message 底层消息对象
 @return 转换后的消息对象
 */
+ (instancetype)messageWith:(TIMMessage *)message;


/**
 获得消息对象

 @param type 消息类型
 @param content 消息内容
 @param extra 新英用户信息
 @return 消息对象
 */
+ (instancetype)messageWithType:(SSIMMsgType)type content:(NSString *)content extra:(NSDictionary *)extra;


/**
 根据json数据获取消息对象

 @param data json数据
 @return 消息对象
 */
+ (instancetype)messageWithData:(id)data;

/**
 获取内部的底层SDK消息对象

 @return 底层SDK消息对象
 */
- (TIMMessage *)getTIMMessage;

@end
