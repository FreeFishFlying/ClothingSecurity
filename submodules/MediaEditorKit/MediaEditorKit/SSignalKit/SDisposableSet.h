#import "SDisposable.h"
#import <Foundation/Foundation.h>

@class SSignal;

@interface SDisposableSet : NSObject <SDisposable>

- (void)add:(id<SDisposable>)disposable;
- (void)remove:(id<SDisposable>)disposable;

@end
