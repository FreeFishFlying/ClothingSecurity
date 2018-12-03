//
//  S2iCodeModule.h
//  S2iCodeModule
//
//  Created by Pai Peng on 14.09.17.
//  Copyright © 2017 zzc_copy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "S2iCodeResult.h"
//#import "S2iCodeResultBase.h"
//! Project version number for S2iFrameWorkApp.
FOUNDATION_EXPORT double S2iFrameWorkAppVersionNumber;

//! Project version string for S2iFrameWorkApp.
FOUNDATION_EXPORT const unsigned char S2iFrameWorkAppVersionString[];

@protocol S2iCodeResultDelegate <NSObject>;

- (void) onS2iCodeResult:(S2iCodeResult *)result;
- (void) onS2iCodeError: (S2iCodeResultBase*) errorResult;

@end

@interface S2iCodeModule : NSObject

//单例
single_interface(S2iCodeModule)

@property (nonatomic, strong) id <S2iCodeResultDelegate> delegate;

- (void)initS2iCodeModule;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)s2iCodeResultInterface:(S2iCodeResult *)result;
- (void)onS2iCodeResultInterface:(S2iCodeResultBase*) errorResult;
- (void)startWithin: (UIWindow*) window  UINavigationController:(UINavigationController*) navigationController;
@end
