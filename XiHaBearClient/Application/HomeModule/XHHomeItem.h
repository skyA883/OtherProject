//
//  XHHomeItem.h
//  XiHaBearClient
//
//  Created by lcfapril on 15/5/7.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "XHBaseItem.h"

@protocol CategoryItem <NSObject>
@end

@protocol Recommend_NewsItem <NSObject>
@end

@protocol R_NewsItem <NSObject>
@end

@interface XHHomeItem : XHBaseItem
@property (nonatomic, strong)NSArray<Optional,CategoryItem>* category;
@property (nonatomic, strong)NSArray<Optional,Recommend_NewsItem>* t_recommend;
@property (nonatomic, strong)NSArray<Optional,Recommend_NewsItem>* t_news;
@property (nonatomic, strong)NSArray<Optional,R_NewsItem>* r_news;

@end


@interface CategoryItem:XHBaseItem
@property (nonatomic,strong)NSString<Optional>* code;
@property (nonatomic,strong)NSString<Optional>* name;

@end


@interface Recommend_NewsItem : XHBaseItem

@property (nonatomic,strong)NSString<Optional>* subject;
@property (nonatomic,strong)NSString<Optional>* title;
@property (nonatomic,strong)NSString<Optional>* depict;
@property (nonatomic,strong)NSString<Optional>* img;

@end


@interface R_NewsItem : XHBaseItem

@property (nonatomic, strong)NSString<Optional>* Single;
@property (nonatomic, strong)NSString<Optional>* category;
@property (nonatomic, strong)NSString<Optional>* category_name;

@end