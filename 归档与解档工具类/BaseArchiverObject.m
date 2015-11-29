//
//  BaseArchiverObject.m
//  B01_runtime
//
//  Created by apple on 15/4/13.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "BaseArchiverObject.h"
#import <objc/runtime.h>

@implementation BaseArchiverObject
-(void)encodeWithCoder:(NSCoder *)aCoder{
    // 1.使用runtime获取所有属性名字 _name,_englishName,_height,age
    // 1.1 类的属性个数
    unsigned int numOfProps;
    Ivar *props = class_copyIvarList([self class], &numOfProps);
    
    // 1.2.遍历类的属性
    for (int i = 0; i < numOfProps; i++) {
        // 1.2.1 获取对应索引的属性
        Ivar var = props[i];
        
        // 1.2.2获取属性的名字 ---> 属性获取是无序
        const char *propName = ivar_getName(var);
        
        // 1.2.3把c语言字符串转成OC
        NSString *propNameStr = [[NSString alloc] initWithCString:propName encoding:NSUTF8StringEncoding];
        
        // 2.通过runtime遍历"属性名: 来encode
        
        // 使用kvc的方法来获取值
        id propValue = [self valueForKey:[propNameStr substringFromIndex:1]];
        NSLog(@"%@ %@",propNameStr,propValue);
        
        [aCoder encodeObject:propValue forKey:propNameStr];
    }
    
#pragma 在C语言里，使用copy/return/create声明资源要释放，在ARC里，C语言的资源是不会自动释放
    free(props);
    
}

/**
 *  解归档
 *
 */
-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        // 1.使用runtime获取所有属性名字 _name,_englishName,_height,age
        // 1.1 类的属性个数
        unsigned int numOfProps;
        Ivar *props = class_copyIvarList([self class], &numOfProps);
        
        // 1.2.遍历类的属性
        for (int i = 0; i < numOfProps; i++) {
            // 1.2.1 获取对应索引的属性
            Ivar var = props[i];
            
            // 1.2.2获取属性的名字 ---> 属性获取是无序
            const char *propName = ivar_getName(var);
            
            // 1.2.3把c语言字符串转成OC
            NSString *propNameStr = [[NSString alloc] initWithCString:propName encoding:NSUTF8StringEncoding];
            
            //2.通过runtime获取属性 从 归档文件获取值，然后赋值给自己self
            id objFromFile = [aDecoder decodeObjectForKey:propNameStr];
            [self setValue:objFromFile forKey:[propNameStr substringFromIndex:1]];
        }
        
        //释放资源
        free(props);
        
    }
    
    return self;
}

@end
