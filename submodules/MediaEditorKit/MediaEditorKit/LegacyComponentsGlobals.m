#import <Foundation/Foundation.h>
#import "LegacyComponentsInternal.h"

static id<LegacyComponentsGlobalsProvider> _provider;

@implementation LegacyComponentsGlobals

+ (void)setProvider:(id<LegacyComponentsGlobalsProvider>)provider {
    _provider = provider;
}

+ (id<LegacyComponentsGlobalsProvider>)provider {
    return _provider;
}

@end
