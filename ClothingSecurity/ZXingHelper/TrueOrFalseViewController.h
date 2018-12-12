//
//  TrueOrFalseViewController.h
//  TrueOrFalse
//
//  Created by hdkj002 on 2018/1/26.
//  Copyright © 2018年 mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Global.h"
#import "LBXScanPermissions.h"
//UI
#import "LBXScanView.h"
#import "ZXingWrapper.h" //ZXing扫码封装
//#import "ZNMSSModel.h"

@interface TrueOrFalseViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
/**
 @brief 是否需要扫码图像
 */
@property (nonatomic, assign) BOOL isNeedScanImage;
/**
 ZXing扫码对象
 */
@property (nonatomic, strong) ZXingWrapper *zxingObj;
#pragma mark - 扫码界面效果及提示等
/**
 @brief  扫码区域视图,二维码一般都是框
 */
@property (nonatomic,strong) LBXScanView* qRScanView;


/**
 *  界面效果参数
 */
@property (nonatomic, strong) LBXScanViewStyle *style;
/**
 @brief  扫码存储的当前图片
 */
@property(nonatomic,strong)UIImage* scanImage;



/**
 @brief  启动区域识别功能
 */
@property(nonatomic,assign)BOOL isOpenInterestRect;


/**
 @brief  闪关灯开启状态
 */
@property(nonatomic,assign)BOOL isOpenFlash;

//打开相册
- (void)openLocalPhoto;
//开关闪光灯
- (void)openOrCloseFlash;


//子类继承必须实现的提示
/**
 *  继承者实现的alert提示功能
 *
 *  @param str 提示语
 */
- (void)showError:(NSString*)str;


- (void)reStartDevice;

//@property (nonatomic , copy) void (^passValue)(ZNMSSModel *model, NSString *phoneStr);

@end
