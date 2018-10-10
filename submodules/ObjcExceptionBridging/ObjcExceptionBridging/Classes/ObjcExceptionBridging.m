//
//  ObjcExceptionBridging.m
//  ObjcExceptionBridging
//
//  Created by 徐涛 on 2018/4/7.
//

#import "ObjcExceptionBridging.h"

void _try_objc(void(^_Nonnull tryBlock)(void), void(^_Nonnull catchBlock)(NSException* _Nonnull exception), void(^_Nonnull finallyBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException* exception) {
        catchBlock(exception);
    }
    @finally {
        finallyBlock();
    }
}

void _throw_objc(NSException* _Nonnull exception)
{
    @throw exception;
}

@implementation ObjcExceptionBridging

- (void)bridge {
}

@end
