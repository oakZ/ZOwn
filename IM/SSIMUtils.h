//
//  SSIMUtils.h
//  SuperSports
//
//  Created by zx on 17/3/16.
//  Copyright © 2017年 zx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSIMUtils : NSObject

+ (NSDictionary *)convertIntoDictionayWith:(NSString *)string;

+ (NSString *)convertIntoStringWith:(NSDictionary *)dict;

@end
