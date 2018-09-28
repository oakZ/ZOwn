//
//  SSIMPlatform.h
//  SSportsIMtest
//
//  Created by zx on 17/3/6.
//  Copyright © 2017年 zx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ImSDK/ImSDK.h>
#import "SSIMCommon.h"

@class SSIMUser;

@interface SSIMPlatform : NSObject 

@property (nonatomic, readonly, strong) SSIMUser *user;

@property (nonatomic, assign) BOOL isConnected; // 当前是否连接上，外部可用此方法判断是否有网

/**
 启动IM
 @param appid AppID
 */
+ (void)startIMEngine:(NSString *)appid;


/**
 统一管理IM相关的全局设置

 @return 单例
 */
+ (SSIMPlatform *)sharedInstance;

/**
 进入聊天室

 @param roomID 聊天室ID
 @param success 成功回调
 @param fail 失败回调
 */
- (void)enterChatRoom:(NSString *)roomID success:(SSIMSuccess)success failed:(SSIMFail)fail;

/**
 退出聊天室

 @param roomID 聊天室ID
 @param success 成功回调
 @param fail 失败回调
 */
- (void)exitChatRoom:(NSString *)roomID success:(SSIMSuccess)success failed:(SSIMFail)fail;

@end


/**
 IMSDK登录相关业务放在此分类
 */
@interface SSIMPlatform (Login)


/**
 获取本地登录用户信息

 @return 用户信息
 */
- (SSIMUser *)loadLocalUser;


/**
 清除本地登录用户信息

 */
- (void)clearLocalUser;


/**
 保存登录信息
 */
- (void)saveLoginParamToLacal;

/**
 登录腾讯IM，独立帐号模式

 @param uid 用户标识，这里用设备唯一标识来对应
 @param userSig userSig，鉴权用
 @param success 登录成功回调
 @param fail 登录失败回调
 */
- (void)loginIMWithUid:(NSString *)uid userSig:(NSString *)userSig success:(SSIMSuccess)success failed:(SSIMFail)fail;

@end
