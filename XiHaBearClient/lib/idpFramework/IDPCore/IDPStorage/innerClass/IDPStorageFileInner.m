//
//  IDPStorageFileInner.m
//  IDP
//
//  Created by douj on 17-3-12.
//
//

#import "IDPStorageFileInner.h"
#import "IDPStorageConst.h"
#import "IDPLog.h"
#import "NSString+IDPExtension.h"
#import "NSDictionary+IDPExtension.h"

@interface IDPStorageFileInner ()
@property (nonatomic,copy) NSString* nameSpace;
@property (nonatomic,copy,getter = getStoragePath) NSString* storagePath;
@end
@implementation IDPStorageFileInner


static NSFileManager* get_file_manager()
{
    static NSFileManager *idpShareFileManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        idpShareFileManager = [NSFileManager new];
    });
    return idpShareFileManager;
}


-(id)initWithNameSpace:(NSString*)nameSpace
{
    self = [super init];
    if (self)
    {
        self.nameSpace = nameSpace;
        //新建namesapce目录
        [get_file_manager() createDirectoryAtPath:self.storagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return self;
}
- (void)dealloc
{
    self.nameSpace = nil;
    [_storagePath release];
    _storagePath = nil;
    [super dealloc];
}
-(NSError*)createError:(NSString*)description errorCode:(NSInteger)code
{
    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:@"com.baidu.idp" code:code userInfo:userInfo];
}
-(BOOL)existObjectForKey:(NSString*)key
{
    NSFileManager* manager = get_file_manager();
    NSString* fullPath = [self getFullPathForKey:key];
    if ([manager fileExistsAtPath:fullPath]) {
        return YES;
    }
    return NO;
}
//同步方法
-(NSData*)loadObjectForKey:(NSString*)key error:(NSError**)error
{
    NSString* fullPath = [self getFullPathForKey:key];
    NSData* data= [NSData dataWithContentsOfFile:fullPath];
    // 更新文件修改时间，以便不被清除
    NSFileManager* manager = get_file_manager();
    [manager setAttributes: @{NSFileModificationDate: [NSDate date]} ofItemAtPath:fullPath error:nil];
    return data;
}
-(BOOL)saveObject:(NSData*)obj forKey:(NSString*)key error:(NSError**)error
{
    if ([obj isEqual:[NSNull null]]) {
        *error = [self createError:@"not support Null value" errorCode:-1];
        return FALSE;
    }
    NSString* fullPath = [self getFullPathForKey:key];
    //新建namesapce目录
    if(![get_file_manager() fileExistsAtPath:self.storagePath])
    {
        [get_file_manager() createDirectoryAtPath:self.storagePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [get_file_manager() createFileAtPath:fullPath contents:obj attributes:nil];
}

-(BOOL)removeObjectForKey:(NSString*)key error:(NSError **)error
{
    if ([self existObjectForKey:key]) {
        NSString* fullPath = [self getFullPathForKey:key];
        NSFileManager* manager = get_file_manager();
        return [manager removeItemAtPath:fullPath error:error];
    }
    return YES;
}

+(void)cleanExpiredFiles:(NSString *)nameSpace expire:(NSNumber *)expireNumber
{
    NSFileManager *manager = get_file_manager();
    NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:[IDPStorageFileInner getStoragePath:nameSpace]];
    NSString *filePath = nil;
    while (filePath = [enumerator nextObject]) {
        NSDictionary *attributes = [enumerator fileAttributes];
        double createDate = [(NSDate *)[attributes objectAtPath:NSFileCreationDate] timeIntervalSince1970];
        double modifyDate = [(NSDate *)[attributes objectAtPath:NSFileModificationDate] timeIntervalSince1970];
        double expireDate = createDate + [expireNumber doubleValue];
        if (expireDate < modifyDate) {
            IDPLogDebug(@"Delete cached file: %@", filePath);
            [manager removeItemAtPath:filePath error:nil];
        }
    }
    
}

//清空整个命名空间
+(BOOL)cleanNameSpace:(NSString*)nameSpace error:(NSError **)error
{
    NSString* fullPath  =  [IDPStorageFileInner getStoragePath:nameSpace];
    NSFileManager* manager = get_file_manager();
    return [manager removeItemAtPath:fullPath error:error];
}

//获取整个命名空间的大小
+(long long)getNameSpaceSize:(NSString*)nameSpace
{
    NSString* fullPath  =  [IDPStorageFileInner getStoragePath:nameSpace];
    NSFileManager* manager = get_file_manager();
    if (![manager fileExistsAtPath:fullPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:fullPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [fullPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}

+ (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = get_file_manager();
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

-(NSString*)getStoragePath
{
    if(!_storagePath)
    {
        _storagePath = [[IDPStorageFileInner getStoragePath:self.nameSpace] copy];
    }
    return _storagePath;
}

-(NSString*)getFullPathForKey:(NSString*)key
{
    NSString* md5 = [key MD5];
    NSString* fullPath = [self.storagePath stringByAppendingPathComponent:md5];
    return fullPath;
}

+(NSString*)getStoragePath:(NSString*)nameSpace
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* fullFileName = [NSString stringWithFormat:@"%@",nameSpace];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:fullFileName];
    return path;
}

@end
