//
//  SSIMUtils.m
//  SuperSports
//
//  Created by zx on 17/3/16.
//  Copyright © 2017年 zx. All rights reserved.
//

#import "SSIMUtils.h"

@implementation SSIMUtils


#pragma mark - tool

+ (NSDictionary *)convertIntoDictionayWith:(NSString *)string
{
    if (![string isKindOfClass:[NSString class]] || !string.length) {
        return nil;
    }
    
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    if (jsonObject && [jsonObject isKindOfClass:[NSDictionary class]]) {
        return jsonObject;
    }
    
    return nil;
    
}

+ (NSString *)convertIntoStringWith:(NSDictionary *)dict
{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return result;
}

@end
