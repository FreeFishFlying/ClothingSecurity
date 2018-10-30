#import "TGModernCache.h"
#import "LegacyComponentsInternal.h"
#import "TGStringUtils.h"
#import "SSignalKit.h"
#import "SQueue.h"
#import "SSignal.h"

typedef enum {
    TGModernCacheKeyspaceGlobalProperties = 1,
    TGModernCacheKeyspaceLastUsageByPath = 2,
    TGModernCacheKeyspacePathAndSizeByLastUsage = 3,
    TGModernCacheKeyspaceLastUsageSortingValue = 4
} TGModernCacheKeyspace;

typedef enum {
    TGModernCacheGlobalPropertySize = 1
} TGModernCacheGlobalProperty;

@interface TGModernCache ()
{
    NSString *_path;
    SQueue *_queue;
    NSUInteger _maxSize;
    bool _recalculatedCurrentSize;
}

@end

@implementation TGModernCache

- (instancetype)initWithPath:(NSString *)path size:(NSUInteger)size
{
    self = [super init];
    if (self != nil)
    {
        _path = path;
        [[NSFileManager defaultManager] createDirectoryAtPath:[_path stringByAppendingPathComponent:@"store"] withIntermediateDirectories:true attributes:nil error:nil];
        _maxSize = size;
        _queue = [[SQueue alloc] init];
    }
    return self;
}

- (NSString *)_filePathForKey:(NSData *)key
{
    return [[_path stringByAppendingPathComponent:@"store"] stringByAppendingPathComponent:[TGStringUtils md5ForData:key]];
}

- (void)setValue:(NSData *)value forKey:(NSData *)key
{
    [_queue dispatch:^
    {
    }];
}

- (void)getValueForKey:(NSData *)key completion:(void (^)(NSData *))completion
{
    [_queue dispatch:^
    {

    }];
}

- (void)getValuePathForKey:(NSData *)key completion:(void (^)(NSString *))completion {
    [_queue dispatch:^
    {
       
    }];
}

- (NSData *)getValueForKey:(NSData *)key
{
    __block NSData *result = nil;
    [_queue dispatch:^
    {
        [self getValueForKey:key completion:^(NSData *data)
        {
            result = data;
        }];
    } synchronous:true];
    
    return result;
}

- (NSString *)getValuePathForKey:(NSData *)key {
    __block NSString *result = nil;
    [_queue dispatch:^ {
        [self getValuePathForKey:key completion:^(NSString *path) {
            result = path;
        }];
    } synchronous:true];
    
    return result;
}

- (bool)containsValueForKey:(NSData *)key
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self _filePathForKey:key]];
}

- (SSignal *)cachedItemForKey:(NSData *)key
{
    return [[SSignal alloc] initWithGenerator:^id<SDisposable> (SSubscriber *subscriber)
    {
        [self getValueForKey:key completion:^(NSData *data)
        {
            [subscriber putNext:data];
            [subscriber putCompletion];
        }];
        
        return nil;
    }];
}

@end
