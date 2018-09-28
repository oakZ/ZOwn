//
//  SSIMMessage.m
//  SSportsIMtest
//
//  Created by zx on 17/3/7.
//  Copyright © 2017年 zx. All rights reserved.
//

#import "SSIMMessage.h"
#import <ImSDK/ImSDK.h>
#import "SSIMUtils.h"
#import "SSIMPlatform.h"
#import "SSIMUser.h"

@interface SSIMMessage () {
    TIMMessage *_tMessage;
}

@end

NSString * const kMessageExtraUidKey = @"uid";
NSString * const kMessageExtraNicknameKey = @"nick_name";
NSString * const kMessageExtraAvatarKey = @"avatar";
NSString * const kMessageExtraUserLevelKey = @"user_level";

static NSString * const kMessageSenderIDKey = @"sender_id";
static NSString * const kMessageTypeKey = @"type";
static NSString * const kMessageContentKey = @"text";
static NSString * const kMessageExtraKey = @"extra";

@implementation SSIMMessage

+ (instancetype)messageWithType:(SSIMMsgType)type content:(NSString *)content extra:(NSDictionary *)extra
{
    TIMMessage *tMessage = [[TIMMessage alloc] init];
    switch (type) {
        case SSIMMsgText:{
            // 文本消息
            TIMTextElem *elem = [[TIMTextElem alloc] init];
            NSString *text = content ?: @"";
            BOOL hasExtra = extra && [extra isKindOfClass:[NSDictionary class]];
            NSString *sender = [SSIMPlatform sharedInstance].user.identifier ?: @"";
            NSDictionary *dict = @{kMessageSenderIDKey : sender, kMessageTypeKey : @1001, kMessageContentKey : text, kMessageExtraKey : hasExtra ? extra : @{},};
            elem.text = [SSIMUtils convertIntoStringWith:dict];
            [tMessage addElem:elem];
            
        }break;
        case SSIMMsgLike:{
            
            // 点赞消息
            TIMTextElem *elem = [[TIMTextElem alloc] init];
            elem.text = @"";
            [tMessage addElem:elem];
            
        }break;
        case SSIMMsgGift:{
            
            // 礼物消息
            TIMTextElem *elem = [[TIMTextElem alloc] init];
            elem.text = @"";
            [tMessage addElem:elem];
            
        }break;
        case SSIMMsgLiveEnd:{
            
            // 直播结束消息
            TIMTextElem *elem = [[TIMTextElem alloc] init];
            elem.text = @"";
            [tMessage addElem:elem];
            
        }break;
        case SSIMMsgSetSilence:{
            
            // 禁言消息
            TIMTextElem *elem = [[TIMTextElem alloc] init];
            elem.text = @"";
            [tMessage addElem:elem];
            
        }break;
            
        default:
            break;
    }
    
    
    SSIMMessage *instance = [[SSIMMessage alloc] initWith:tMessage type:type];
    return instance;
}

+ (instancetype)messageWith:(TIMMessage *)message
{
    if (message.elemCount == 0) {
        return nil;
    }
    
    SSIMMsgType type = SSIMMsgUnknown;
    
    if (message.elemCount > 1) {
        
        // 暂时不支持多个elem
        type = SSIMMsgUnknown;
        
    }else if (message.elemCount == 1) {
        
        TIMElem *elem = [message getElem:0];
        if([elem isKindOfClass:[TIMTextElem class]]) {
            
            // 文本消息
            NSDictionary *msgDict = [SSIMUtils convertIntoDictionayWith:[(TIMTextElem *)elem text]];
            if (!msgDict) {
                type = SSIMMsgUnknown;
            }else {
                int code = [msgDict[kMessageTypeKey] intValue];
                switch (code) {
                    case 1001:{
                        type = SSIMMsgText;
                    }break;
                    case 1002:{
                        type = SSIMMsgLike;
                    }break;
                    case 1003:{
                        type = SSIMMsgGift;
                    }break;
                    case 1004:{
                        type = SSIMMsgLiveEnd;
                    }break;
                    case 1005:{
                        type = SSIMMsgSetSilence;
                    }break;
                    case 1006:{
                        type = SSIMMsgStreamOff;
                    }break;
   
                    default:{
                        type = SSIMMsgUnknown;
                    }break;
                }
            }
            
        }else if([elem isKindOfClass:[TIMCustomElem class]]) {
            
            // 暂时不支持自定义消息
            type = SSIMMsgUnknown;
            
        }else if ([elem isKindOfClass:[TIMGroupTipsElem class]]) {
            
            // 暂时不支持群Tips
            type = SSIMMsgUnknown;
        }
    }
    
    SSIMMessage *instance = [[SSIMMessage alloc] initWith:message type:type];
    return instance;
    
}

+ (instancetype)messageWithData:(id)data
{
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dict = data;
        
        TIMMessage *tMessage = [[TIMMessage alloc] init];
        
        NSString *text = [dict[@"MsgContent"] objectForKey:@"Text"];
        if ([dict[@"MsgType"] isEqual:@"TIMTextElem"] && text) {
            TIMTextElem *elem = [[TIMTextElem alloc] init];
            elem.text = text;
            [tMessage addElem:elem];
        }
        
        return [SSIMMessage messageWith:tMessage];
    }
    
    return [[SSIMMessage alloc] init];
}

- (instancetype)initWith:(TIMMessage *)tMessage type:(SSIMMsgType)type
{
    if (self = [super init]) {
        _tMessage = tMessage;
        _type = type;
    }
    
    return self;
}

- (TIMMessage *)getTIMMessage
{
    return _tMessage;
}

#pragma mark - setter & getter

- (NSString *)senderID
{
//    return [_tMessage GetSenderProfile].identifier;
    return _tMessage.sender;
    
}

- (NSString *)text
{

    TIMElem *elem = [_tMessage getElem:0];
    if ([elem isKindOfClass:[TIMTextElem class]]) {
        
        NSDictionary *msgDict = [SSIMUtils convertIntoDictionayWith:[(TIMTextElem *)elem text]];
        
        if (!msgDict) return @"";
        
        return msgDict[kMessageContentKey];
        
    }
    
    return @"";
    
}

- (NSDictionary *)extra
{
    TIMElem *elem = [_tMessage getElem:0];
    if ([elem isKindOfClass:[TIMTextElem class]]) {
        
        NSDictionary *msgDict = [SSIMUtils convertIntoDictionayWith:[(TIMTextElem *)elem text]];
        
        if (!msgDict) return nil;
        
        return msgDict[kMessageExtraKey];
        
    }

    return nil;
}

@end
