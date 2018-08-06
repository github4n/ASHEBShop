//
//  NSString+ASHUtil.m
//  ASHEBShop
//
//  Created by xmfish on 2018/8/4.
//  Copyright © 2018年 ash. All rights reserved.
//

#import "NSString+ASHUtil.h"

@implementation NSString (ASHUtil)
-(NSInteger)getInteger
{
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-Z\u4e00-\u9fa5/:.]+" options:0 error:NULL];
    NSString* result = [regular stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@""];
    return [result integerValue];
}
@end
