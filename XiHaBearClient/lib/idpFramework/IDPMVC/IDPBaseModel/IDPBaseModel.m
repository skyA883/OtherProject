//
//  TBCBaseModel.m
//  Pickers
//
//  Created by zhangdongjin on 13-3-13.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <objc/runtime.h>
#import "IDPBaseModel.h"
#import "IDPLog.h"



@implementation IDPBaseModel
// 加载数据，自动加载缓存
- (void)load{}
// 停止加载
- (void)cancel{}
// 刷新当前页
- (void)refresh{}
// 回归init状态
- (void)reset{}
@end

@implementation TBCBaseListModel

// 总页数，ceil(totalCount/pageSize)
- (NSUInteger)totalPageCount{
    return ceil(self.totalCount/self.pageSize);
}

// 是否可加载更多或下一页
- (BOOL)hasNext {
    return NO;
}

- (BOOL)hasPrev {
    return NO;
}

// 定位，替换当前结果
- (void)gotoFirstPage{}
- (void)gotoPage:(NSUInteger)pn{}

// 增量，append或者prepend当前结果
- (void)mergeNextPage{}
- (void)mergePrevPage{}

// 翻页，替换当前结果
- (void)gotoNextPage{}
- (void)gotoPrevPage{}

@end

@implementation TBCBaseListItem

+ (id)itemWithData:(id)data {
    return [[[self alloc] initWithData:data] autorelease];
}

- (id)init {
    if (self = [super init]) {
        self.cellHeight = -1.0;
        _jsonDataMap = [[NSMutableDictionary alloc] init];
        _jsonArrayClassMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithData:(id)data {
    if (self = [self init]) {
        self.cellHeight = -1.0;
        [self setData:data];
    }
    return self;
}

// 反序列化自身包括子类
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int propertyCount = 0;
        objc_property_t *propertyList = class_copyPropertyList(self.class, &propertyCount);
        for (unsigned i = 0; i < propertyCount; i++) {
            objc_property_t property = propertyList[i];
            NSString * propertyName= [NSString stringWithUTF8String:property_getName(property)];
            @try {
                id value = [aDecoder decodeObjectForKey:propertyName];
                [self setValue:value forKey:propertyName];
                IDPLogDebug(@"decode: %@ = %@, type[%@]",propertyName, value, [value class]);
            }@catch (NSException *exception) {
                IDPLogWarning(0, @"proprty is not KVC compliant: %@", propertyName);
            }
        }
        free(propertyList);
        self.cellHeight = [aDecoder decodeFloatForKey:@"cellHeight"];
    }
    return self;
}

// 序列化自身包括子类
- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int propertyCount = 0;
    objc_property_t *propertyList = class_copyPropertyList(self.class, &propertyCount);
    for (unsigned i = 0; i < propertyCount; i++) {
        objc_property_t property = propertyList[i];
        NSString * propertyName= [NSString stringWithUTF8String:property_getName(property)];
        @try {
            id value = [self valueForKey:propertyName];
            [aCoder encodeObject:value forKey:propertyName];
            IDPLogDebug(@"encode: %@ = %@, type[%@]",propertyName, value, [value class]);
        }@catch (NSException *exception) {
            IDPLogWarning(0, @"proprty is not KVC compliant: %@", propertyName);
        }
    }
    free(propertyList);
    [aCoder encodeFloat:self.cellHeight forKey:@"cellHeight"];
}

- (id)setData:(id)data {
    [self parseData:data];
    return self;
}

- (void)addMappingRuleProperty:(NSString*)propertyName pathInJson:(NSString*)path
{
    [_jsonDataMap setObject:path forKey:propertyName];
}

- (void)addMappingRuleArrayProperty:(NSString*)propertyName class:(Class)class
{
    [_jsonArrayClassMap setObject:NSStringFromClass(class) forKey:propertyName];
}

- (BOOL)parseData:(NSDictionary *)data
{
    if(![data isKindOfClass:[NSDictionary class]])
    {
        return NO;
    }
    NSDictionary* dict = (NSDictionary*)data;
    Class cls = [self class];
    while (cls != [TBCBaseListItem class])
    {
        unsigned int propertyCount = 0;
        objc_property_t *propertyList = class_copyPropertyList(cls, &propertyCount);//获取cls 类成员变量列表
        for (unsigned i = 0; i < propertyCount; i++) {
            objc_property_t property = propertyList[i];
            const char *attr = property_getAttributes(property); //取得这个变量的类型
            NSString *attrString = [NSString stringWithUTF8String:attr];
            NSString *typeAttr = [[attrString componentsSeparatedByString:@","] objectAtIndex:0];
            NSString *typeString = [typeAttr substringWithRange:NSMakeRange(3, typeAttr.length - 4)];
            NSString *key = [NSString stringWithUTF8String:property_getName(property)];//取得这个变量的名称
            NSString* path = [_jsonDataMap objectForKey:key];
            id value = [dict objectAtPath:path];
            [self setfieldName:key fieldClassName:typeString value:value];
        }
        cls = class_getSuperclass(cls);
    }
    return YES;
}

- (void)setfieldName:(NSString*)name fieldClassName:(NSString*)className value:(id)value
{
    NSString* path = [_jsonDataMap objectForKey:name];
    if (value == nil) {
        IDPLogWarning(0,@"json at %@ is nil field %@ type",path,name);
        return;
    }
    //如果结构里嵌套了TBCBaseListItem 也解析
    if ([NSClassFromString(className) isSubclassOfClass:[TBCBaseListItem class]])
    {
        Class entityClass = NSClassFromString(className);
        if (entityClass)
        {
            TBCBaseListItem* entityInstance = [[entityClass alloc] init];
            [entityInstance parseData:value];
            [self setValue:entityInstance forKey:name];
            [entityInstance release];
        }
    }
    else if (![value isKindOfClass:NSClassFromString(className)])
    {
        IDPLogWarning(0,@"json at %@ is dismatch field %@ type",path,name);
        return;
    }
    //如果是array判断array内类型
    else if ([NSClassFromString(className) isSubclassOfClass:[NSArray class]])
    {
        NSString* typeName = [_jsonArrayClassMap objectForKey:name];
        if (typeName)
        {
            //json中不是array 类型错误
            if (![value isKindOfClass:[NSArray class]]) {
                
                IDPLogWarning(0,@"json at %@ is not array field %@ type",path,name);
                return;
            }
            Class entityClass = NSClassFromString(typeName);
            //entiyClass不存在
            if (!entityClass)
            {
                IDPLogWarning(0,@"json at %@ class %@ is not exist field %@ type",path,typeName,name);
                return;
            }
            //entiyClass不是TBCJsonEntityBase的子类
            if (![entityClass isSubclassOfClass:[IDPBaseModel class]])
            {
                IDPLogWarning(0,@"json at %@ class %@ is not subclass of TBCJsonEntityBase field %@ type",path,typeName,name);
                return;
            }
            NSMutableArray* mutableArr = [[NSMutableArray alloc] initWithCapacity:[(NSArray*)value count]];
            for (NSDictionary*dict in (NSArray*)value )
            {
                //arry中存的不是dict
                if (![dict isKindOfClass:[NSDictionary class]])
                {
                    IDPLogWarning(0,@"json at %@ class dict in Array is dict type field %@ type",path,name);
                    [mutableArr release];
                    return;
                }
                TBCBaseListItem* entityInstance =  [[entityClass alloc] init];
                [entityInstance parseData:dict];
                [mutableArr addObject:entityInstance];
                [entityInstance release];
            }
            [self setValue:mutableArr forKey:name];
            [mutableArr release];
        }
        else
        {
            [self setValue:value forKey:name];
        }
    }
    //正常情况
    else
    {
        [self setValue:value forKey:name];
    }
}

- (void)dealloc {
    self.renderCache = nil;
    [_jsonDataMap release];
    _jsonDataMap = nil;
    [_jsonArrayClassMap release];
    _jsonArrayClassMap = nil;
    [super dealloc];
}

@end