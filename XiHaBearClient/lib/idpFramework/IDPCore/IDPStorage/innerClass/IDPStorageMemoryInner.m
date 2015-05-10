//
//  IDPStorageMemoryInner.m
//  IDP
//
//  Created by douj on 17-3-12.
//
//

#import "IDPStorageMemoryInner.h"
#import "IDPLog.h"
@interface IDPStorageMemoryItem : NSObject

@property (nonatomic,retain) id cacheObj;

@end
@implementation IDPStorageMemoryItem

- (void)dealloc
{
    self.cacheObj = nil;
    [super dealloc];
}

@end

@interface IDPStorageMemoryInner()

@property (nonatomic,copy) NSString* nameSpace;
@property (nonatomic,retain)NSCache* memoryCache;
@property (nonatomic,assign) NSUInteger time_count;

@end
@implementation IDPStorageMemoryInner

//+(void)initialize
//{
//    dispatch_queue_t gcdTimerQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0);
//    dispatch_source_t gcdTimer;
//    gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, gcdTimerQueue);
//    if (gcdTimer) {
//        uint64_t seconds = 30ull;
//        uint64_t interval = seconds * NSEC_PER_SEC;
//        uint64_t leeway = 1ull *NSEC_PER_SEC;
//        dispatch_source_set_timer(gcdTimer, dispatch_walltime(NULL, 0), interval, leeway);
//        dispatch_source_set_event_handler(gcdTimer, ^{
//            IDPLogDebug(@"IDPStorage gcdTimerQueue begin");
//            for (IDPStorageMemoryInner* memory in [get_memory_namespace_dict() allValues])
//            {
//                if (memory.timeoutInterval != 0 && memory.time_count* 30 >= memory.timeoutInterval)
//                {
//                    [memory.memoryCache removeAllObjects];
//                     memory.time_count = 0;
//                }
//                else
//                {
//                    memory.time_count ++;
//                }
//            }
//            IDPLogDebug(@"IDPStorage gcdTimerQueue end");
//        });
//        dispatch_resume(gcdTimer);
//    }
//}

+(void)cleanAllMemory
{
    for (IDPStorageMemoryInner* memory in [get_memory_namespace_dict() allValues])
    {
        [memory.memoryCache removeAllObjects];
    }
}
static NSMutableDictionary* get_memory_namespace_dict()
{
    static NSMutableDictionary *idpShareMemDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        idpShareMemDict = [NSMutableDictionary new];
    });
    return idpShareMemDict;
}


-(id)initWithNameSpace:(NSString*)nameSpace
{
    self = [super init];
    if (self)
    {
        self.nameSpace = nameSpace;
        self.memoryCache = [[NSCache new] autorelease];
        [get_memory_namespace_dict() setObject:self forKey:nameSpace];
    }
    return self;
}
-(void)setMemoryCapacity:(NSUInteger)memoryCapacity
{
    [self.memoryCache setCountLimit:memoryCapacity];
}
-(NSUInteger)getMemoryCapacity
{
    return self.memoryCache.countLimit;
}
-(BOOL)existObjectForKey:(NSString*)key
{
    id obj = [self.memoryCache objectForKey:key];
    if (obj) {
        return YES;
    }
    return NO;
}

-(id)loadObjectForKey:(NSString*)key
{
     IDPStorageMemoryItem* item = [self.memoryCache objectForKey:key];
    return item.cacheObj;
}
-(void)saveObject:(id)obj forKey:(NSString*)key
{
    IDPStorageMemoryItem* item = [[IDPStorageMemoryItem alloc] init];
    item.cacheObj = obj;
    
    if ([self existObjectForKey:key]) {
        [self removeObjectForKey:key];
    }
    [self.memoryCache setObject:item forKey:key];
    [item release];
}

-(void)saveObject:(id)obj forKey:(NSString *)key cost:(NSUInteger)g
{
    IDPStorageMemoryItem* item = [[IDPStorageMemoryItem alloc] init];
    item.cacheObj = obj;
    [self.memoryCache setObject:item forKey:key cost:g];
    [item release];
}
//- (void)saveObject:(id)obj forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
//    IDPStorageMemoryItem* item = [[IDPStorageMemoryItem alloc] init];
//    item.cacheObj = obj;
//	[self.memoryCache setObject:item forKey:key];
//    [item release];
//	
//}

-(void)removeObjectForKey:(NSString*)key
{
    [self.memoryCache removeObjectForKey:key];
}

-(void)removeAll
{
    [self.memoryCache removeAllObjects];
}

@end
