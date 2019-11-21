//
//  S2iCodeModule.h
//  S2iCodeModule
//
//  Created by Pai Peng on 14.09.17.
//  Copyright © 2017 zzc_copy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>
#import "Singleton.h"
#import "S2iCodeResult.h"
#import "S2iParam.h"
#import "S2iClientInitResult.h"

//! Project version number for S2iFrameWorkApp.
FOUNDATION_EXPORT double S2iFrameWorkAppVersionNumber;

//! Project version string for S2iFrameWorkApp.
FOUNDATION_EXPORT const unsigned char S2iFrameWorkAppVersionString[];

typedef enum
{
    ENUM_DETECTE_FAILURE = -1,       //失败
    ENUM_DETECTE_NOTALLOW = 0,      //此软件不允许使用此函数
    ENUM_DETECTE_SUCCESS = 1,       //成功
    ENUM_DETECTE_NETWORKING = 2,    //上传解码中
    ENUM_DETECTE_UNINIT = 3,         //未正确完成初始化
    ENUM_DETECTE_NONEGPS               //未能获取gps信息

}ENUM_DETECTE_RESULT;
typedef  enum {
    ENUM_S2iSCAN_STATE_MACRO = 0,      // 防伪拍摄
    ENUM_S2iSCAN_STATE_LUPE,           // 棱镜模式
    ENUM_S2iSCAN_STATE_QRCODE,         // 二维码模式
    ENUM_S2iSCAN_STATE_OTG,            // Android UVC OTG 摄像头
    ENUM_S2iSCAN_STATE_DOC,            // 证件码
    ENUM_S2iSCAN_STATE_HIDDENQRCODE,    // 隐形Qrcode
    ENUM_S2iSCAN_STATE_S2IQRCODE,      // 防伪二维码
} EnumS2iScanState;

@protocol S2iCodeResultDelegate <NSObject>;
/*
 解码成功后，返回给Application解码结果数据
*/
- (void) onS2iCodeResult:(S2iCodeResult *_Nullable)result;
/*
 当解码失败时，返回给Application解码失败数据
*/
- (void) onS2iCodeError: (S2iCodeResultBase *_Nullable) errorResult;
/*
 当初始化成功时，返回给Application后台初始化数据
*/
- (void) onS2iClientInitResult:(S2iClientInitResult *_Nullable)result;
/*
 当初始化失败时，返回给Application错误信息
*/
- (void) onS2iClientInitError: (S2iClientInitBase*_Nullable) error;

@end

@interface S2iCodeModule : NSObject

single_interface(S2iCodeModule)

@property (nonatomic, weak) _Nullable id <S2iCodeResultDelegate> delegate;

/**
 * 对SDK模块进行初始化处理，如果不是第一次初始化，返回1；如果是第一次初始化，返回0
 */
- (NSInteger)initS2iCodeModuleWtihDelegate:(_Nonnull id) delegate;
/**
 * 如果程序已经进入后台，调用此函数让SDK进行有效处理
 */
- (void)applicationDidEnterBackground:(UIApplication *_Nonnull)application;
/**
 * 如果程序即将进入后台，调用此函数让SDK进行有效处理
 */
- (void)applicationWillEnterForeground:(UIApplication *_Nonnull)application;
- (BOOL)application:(UIApplication *_Nonnull)app openURL:(NSURL *_Nullable)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *_Nullable)options;
- (void)s2iCodeResultInterface:(S2iCodeResult *_Nullable)result;
- (void)onS2iCodeResultInterface:(S2iCodeResultBase*_Nullable) errorResult;
- (void)startWithin: (UIWindow*_Nullable) window  UINavigationController:(UINavigationController*_Nonnull) navigationController showResult:(BOOL)showResult;

/**
 启动sdk  传递拍摄模式

 @param window 根window
 @param navigationController 导航控制器
 @param scanModeState 拍摄模式
 */
- (void)startWithin: (UIWindow*_Nullable) window  UINavigationController:(UINavigationController* _Nullable) navigationController scanMode:(EnumS2iScanState)scanModeState showResult:(BOOL)showResul;

/**
 * 对给入的图片进行s2i识别
 * - sampleBuffer 给入的图片对象
 * - previewWidth 图片宽度
 * - previewHeight 图片高度
 * - imageType 图片类型 当前版本 传0即可
 * - isRotate 是否图片需要旋转 （如果不旋转，那么给入的图片要与拍摄的图片相同；如果旋转，那么图片会顺时针旋转90度
 */
- (ENUM_DETECTE_RESULT) s2idetect:(CMSampleBufferRef  _Nonnull) sampleBuffer previewWidth:(NSInteger)previewWidth previewHeight:(NSInteger)previewHeight imageType:(NSInteger)imageType  withRotate: (BOOL) isRotate;




+ (NSString *_Nullable)getSDKVersion;
+ (void)setSDKLanguage:(S2iLanguage)language;
/**
 * 获取后台拍摄参数信息
 */
- (S2iParam*_Nullable) getParam;

@end
