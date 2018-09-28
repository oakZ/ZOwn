//
//  SSIMCommon.h
//  SSportsIMtest
//
//  Created by zx on 17/3/7.
//  Copyright © 2017年 zx. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SSIMMsgType) {
    SSIMMsgUnknown, // 未知消息
    SSIMMsgText, // 文本消息
    SSIMMsgLike, // 点赞消息
    SSIMMsgGift, // 礼物消息
    SSIMMsgLiveEnd, // 直播结束
    SSIMMsgSetSilence, // 用户禁言
    SSIMMsgStreamOff, // 断流
};

@class SSIMMessage;

@protocol SSIMMsgDelegate <NSObject>

@optional
- (void)didReceiveMessage:(SSIMMessage *)message;

@end

@interface SSIMCommon : NSObject

@end

/**
 *  一般操作成功回调
 */
typedef void (^SSIMSuccess)();

/**
 *  操作失败回调
 *
 *  @param code 错误码
 *  @param msg  错误描述，配合错误码使用，如果问题建议打印信息定位
 */
typedef void (^SSIMFail)(int code, NSString * msg);

/**
 *  获取消息回调
 *
 *  @param messages 消息列表
 */
typedef void (^SSIMGetMessageSuccess)(NSArray *messages);
