//
//  TBCBaseModel.h
//  Pickers
//
//  Created by zhangdongjin on 13-3-13.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IDPServerAPI.h"

/*
 VC如何使用Model：

 // init 里面：block里面判断error，停掉HUD、下拉动画、上拉动画，并reloadData
 self.frsModel = [[TBCFrsModel alloc] initWithTid:xxx ... completionBlock:^(){...}];

 // viewDidLoad 里面
 [self.frsModel load];
 if (self.frsModel.hasData) { // 有缓存数据
    [self.tableView reloadData];
 }
 if (self.frsModel.procStatus == TBC_PROC_STATUS_LOADING) { // 发起了网络请求
    // show HUD
 }
 
 // cellCount
 return self.frsModel.items.count;
 
 // cellHeight
 return [xxcell caculHeight:item];
 
 // cellForxxx
 TBCFrsListItem *item = self.frsModel.items[index];
 TBCFrsCell *cell = [[TBCFrsCell alloc] initWithData:item];
 
 // 下拉刷新的处理函数
 [self.frsModel refresh];
 
 // 上拉加载更多的处理函数
 [self.frsModel mergeNextPage];
 
 // 上拉加载下一页的处理函数
 [self.frsModel gotoNextPage];

 */

@class IDPBaseModel;

typedef void(^IDPModelBlock)(IDPBaseModel*);

@interface IDPBaseModel : NSObject

@property (nonatomic, copy) IDPModelBlock completionBlock;

@property (nonatomic, assign) NSError *error;

@property (nonatomic, assign) IDPProcessStateEnum procState;
@property (nonatomic, assign) BOOL hasData;

// 时间、超时和缓存控制
@property (nonatomic, readonly) NSDate *updateTime;
@property (nonatomic, readonly) NSDate *expireTime;
@property (nonatomic, assign) BOOL isNeedCache;

// 缓存
@property (nonatomic, readonly) NSDictionary *keys;

// 加载数据，自动加载缓存
- (void)load;
// 停止加载
- (void)cancel;
// 刷新当前页
- (void)refresh;
// 回归init状态
- (void)reset;

@end


/*
 列表型数据
 */

@interface TBCBaseListModel: IDPBaseModel

// 预定义的列表属性
@property (nonatomic, assign) NSUInteger totalCount;        // 可返回的总结果数
@property (nonatomic, assign) NSUInteger pageSize;          // 每次请求的结果数
@property (nonatomic, assign) NSUInteger currPage;          // 当前起始页，从1开始
@property (nonatomic, assign) NSUInteger sartID;            // 当前起始页，从1开始

@property (nonatomic, assign) BOOL isHasNext;               // 上拉更多
@property (nonatomic, assign) BOOL isHasPrev;               // 下拉更多

// 列表数据，成员是TBCBaseListItem的子类
@property (nonatomic, retain) NSMutableArray *items;

// 其他属性成员由子类定义
// tid、pid、barname、keyword、manager等等


// 总页数，ceil(totalCount/pageSize)
- (NSUInteger)totalPageCount;

// 是否可加载更多或下一页
- (BOOL)hasNext;
- (BOOL)hasPrev;

// 定位，替换当前结果
- (void)gotoFirstPage;
- (void)gotoPage:(NSUInteger)pn;

// 增量，append或者prepend当前结果
- (void)mergeNextPage;
- (void)mergePrevPage;

// 翻页，替换当前结果
- (void)gotoNextPage;
- (void)gotoPrevPage;

// TODO: 如何方便子类实现

@end



/*
 列表项，子类需要：
 1、定义自己的特定属性，如tid
 2、重载setData，也可不实现，交由外层类处理
 3、通常不需要重载其他方法，除非你知道自己在干什么
 4、通常不应计算cellHeight，仅仅存储即可
 5、不需要实现NSCoding方法，父类自动处理，除非你知道自己在干什么
 */
@interface TBCBaseListItem : NSObject <NSCoding>
{
    NSMutableDictionary *_jsonDataMap;
    NSMutableDictionary *_jsonArrayClassMap;
}

@property (nonatomic, retain) id renderCache;               // 渲染结果缓存，如view、富文本等，不参与序列化
@property (nonatomic, assign) CGFloat cellHeight;           // 最常用的单独抽出来，参与序列化

- (id)init;
- (id)initWithData:(id)data;
+ (id)itemWithData:(id)data;
- (id)setData:(id)data;



/* Property-JSON映射规则，须在子类Init函数中设定 */

// property中如有包含TBCBaseListItem对象的数组，需要设定此规则
- (void)addMappingRuleArrayProperty:(NSString*)propertyName class:(Class)class;
// 所有需要映射的property都需要设定此规则
- (void)addMappingRuleProperty:(NSString*)propertyName pathInJson:(NSString*)path;

@end

