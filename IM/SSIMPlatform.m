//
//  SSIMPlatform.m
//  SSportsIMtest
//
//  Created by zx on 17/3/6.
//  Copyright © 2017年 zx. All rights reserved.
//

#import "SSIMPlatform.h"
#import <ImSDK/ImSDK.h>
#import "SSIMUser.h"
#import "SSIMCommon.h"

static NSString * const kLoginParamUserDefaultKey = @"kLoginParamUserDefaultKey";

static SSIMPlatform *_sharedInstance = nil;

@interface SSIMPlatform ()<TIMConnListener, TIMUserStatusListener, TIMRefreshListener>

@property (nonatomic, readwrite, strong) SSIMUser *user;

@end

@implementation SSIMPlatform

#pragma mark - setter & getter

- (SSIMUser *)user
{
    if (!_user) {
        _user = [[SSIMUser alloc] init];
    }
    
    return _user;
}

#pragma mark - public

+ (void)startIMEngine:(NSString *)appid
{
    // close crash report
    [[TIMManager sharedInstance] disableCrashReport];
    
    // close auto report
    [[TIMManager sharedInstance] disableAutoReport];
    
    // disable local storage
    [[TIMManager sharedInstance] disableStorage];
    
    // init imsdk
    [[TIMManager sharedInstance] initSdk:[appid intValue]];
    
    // config platform
    [[[self class] sharedInstance] configPlatform];
}

+ (SSIMPlatform *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SSIMPlatform alloc] init];
        
    });
    
    return _sharedInstance;
}

- (void)enterChatRoom:(NSString *)roomID success:(SSIMSuccess)success failed:(SSIMFail)fail
{
    if (!roomID.length) return;
    
    [[TIMGroupManager sharedInstance] JoinGroup:roomID msg:@"申请信息" succ:^{
        
        // success
        NSLog(@"加入聊天室成功！");
        if (success) {
            success();
        }
        
    } fail:^(int code, NSString *msg) {
        
        // failed
        NSLog(@"加入聊天室失败！［%d-%@］", code, msg);
        
        if (fail) {
            fail(code, msg);
        }
    }];
}

- (void)exitChatRoom:(NSString *)roomID success:(SSIMSuccess)success failed:(SSIMFail)fail
{
    if (!roomID.length) return;
    
    [[TIMGroupManager sharedInstance] QuitGroup:roomID succ:^{
        
        // success
        NSLog(@"退出聊天室成功！");
        if (success) {
            success();
        }
        
    } fail:^(int code, NSString *msg) {
        
        // failed
        NSLog(@"退出聊天室失败！［%d-%@］", code, msg);
        if (fail) {
            fail(code, msg);
        }
    }];
}

#pragma mark - private

- (void)configPlatform
{
    // connecting callback
    [[TIMManager sharedInstance] setConnListener:self];
    
    // user status changes callback
    [[TIMManager sharedInstance] setUserStatusListener:self];
    
    // refresh callback
    [[TIMManager sharedInstance] setRefreshListener:self];
    
}

@end


#pragma mark - Login

@implementation SSIMPlatform (Login)

- (SSIMUser *)loadLocalUser
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginParamUserDefaultKey];
    if (dict && [dict isKindOfClass:[NSDictionary class]] && dict.allKeys.count > 0) {
        TIMLoginParam *loginParam = [[TIMLoginParam alloc] init];
        loginParam.identifier = dict[@"id"];
        loginParam.userSig = dict[@"sig"];
        SSIMUser *user = [[SSIMUser alloc] init];
        [user updateWithLoginParam:loginParam];
        return user;
    }
    return nil;
}

- (void)clearLocalUser
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kLoginParamUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveLoginParamToLacal
{
    if (!self.user.identifier || !self.user.userSig) {
        return;
    }
    
    NSDictionary *param = @{
                            @"id" : self.user.identifier,
                            @"sig" : self.user.userSig,
                            };
    [[NSUserDefaults standardUserDefaults] setObject:param forKey:kLoginParamUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)loginIMWithUid:(NSString *)uid userSig:(NSString *)userSig success:(SSIMSuccess)success failed:(SSIMFail)fail
{
    if (!uid.length || !userSig.length) {
        return;
    }
    
    [[TIMManager sharedInstance] login:uid userSig:userSig succ:^{
        
        NSLog(@"登录IM成功!");
        // success
        // save login params
        TIMLoginParam *loginParam = [[TIMLoginParam alloc] init];
        loginParam.identifier = uid;
        loginParam.userSig = userSig;
        
        [self.user updateWithLoginParam:loginParam];
        
        if (success) {
            success();
        }
        
    } fail:^(int code, NSString *msg) {
        
        NSLog(@"登录IM失败！［%d-%@］", code, msg);
        // login failed
        if (fail) {
            fail(code, msg);
        }
        
    }];
}

@end

#pragma mark - callback

/**
 IMSDK回调（除MessageListener外）统一处理
 */
@interface SSIMPlatform (Callback)

@end

@implementation SSIMPlatform (Callback)

#pragma mark - TIMConnListener

/**
 *  网络连接成功
 */
- (void)onConnSucc
{
    self.isConnected = YES;
    NSLog(@"网络连接成功！");
}

/**
 *  网络连接失败
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onConnFailed:(int)code err:(NSString*)err
{
    
    self.isConnected = NO;
    NSLog(@"网络连接失败");
}

/**
 *  网络连接断开
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onDisconnect:(int)code err:(NSString*)err
{
    
    self.isConnected = NO;
    NSLog(@"网络连接断开 code = %d, err = %@", code, err);
}


/**
 *  连接中
 */
- (void)onConnecting
{
    NSLog(@"连接中");
}

#pragma mark - TIMUserStatusListener

/**
 *  踢下线通知
 */
- (void)onForceOffline
{
    NSLog(@"被踢下线");
}

/**
 *  断线重连失败
 */
- (void)onReConnFailed:(int)code err:(NSString*)err
{
    NSLog(@"断线重连失败");
}

/**
 *  用户登录的userSig过期，需要重新登录
 */
- (void)onUserSigExpired
{
    NSLog(@"用户userSig过期");
}

#pragma mark - TIMRefreshListener

- (void)onRefresh
{
    
}

- (void)onRefreshConversations:(NSArray*)conversations
{
    
}


@end

