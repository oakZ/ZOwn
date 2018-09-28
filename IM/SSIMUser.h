//
//  SSIMUser.h
//  SSportsIMtest
//
//  Created by zx on 17/3/7.
//  Copyright © 2017年 zx. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TIMLoginParam;

@interface SSIMUser : NSObject

@property (nonatomic, copy, readonly) NSString *accountType; // 用户的账号类型

@property (nonatomic, copy, readonly) NSString *identifier; // 用户名

@property (nonatomic, copy, readonly) NSString *userSig; //


/**
 绑定底层SDK的登录信息

 @param loginParam 底层SDK登录信息
 */
- (void)updateWithLoginParam:(TIMLoginParam *)loginParam;

@end
