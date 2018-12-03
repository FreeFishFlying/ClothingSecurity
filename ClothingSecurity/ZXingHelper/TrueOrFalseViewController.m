//
//  TrueOrFalseViewController.m
//  TrueOrFalse
//
//  Created by hdkj002 on 2018/1/26.
//  Copyright © 2018年 mark. All rights reserved.
//

#import "TrueOrFalseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIButton+SSEdgeInsets.h"
#import "LBXScanResult.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SnapKit/SnapKit-Swift.h>
#import "LBXAlertAction.h"
#import "UIColor+hexStringToColor.h"
#import <Masonry/Masonry.h>
#import "SVProgressHUD.h"
#define Scale_Width(value)   (((value)/375.0/1) * SCREEN_WIDTH)
#define Scale_Height(value)  (((value)/667.0/1) * SCREEN_HEIGHT)
#define SCREEN_WIDTH     [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT    [[UIScreen mainScreen] bounds].size.height
#define ftpPath @"http://180.76.106.211/pifujiance/"

@interface TrueOrFalseViewController ()
@property (nonatomic,strong) UIView *backView;//提示框背景蒙版

@property (nonatomic,weak) UIButton *cancelBtn;

@end

@implementation TrueOrFalseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    [self drawScanView];
    //不延时，可能会导致界面黑屏并卡住一会
    [self performSelector:@selector(startScan) withObject:nil afterDelay:0.2];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self stopScan];
    _zxingObj.capture=nil;
    _zxingObj=nil;
    [_zxingObj.capture.layer removeFromSuperlayer];
    //    _zxingObj.capture.layer = nil;
    
    [_qRScanView stopScanAnimation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
}
    
#pragma mark UI
- (void)setNav{
   
    
}
- (void)setUI{
    self.view.backgroundColor = [UIColor blackColor];
    
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 40;
    style.xScanRetangleOffset = Scale_Width(50);
    
    if ([UIScreen mainScreen].bounds.size.height <= 480 )
    {
        //3.5inch 显示的扫码缩小
        style.centerUpOffset = 40;
        style.xScanRetangleOffset = 20;
    }
    
    style.notRecoginitonArea = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Inner;
    style.photoframeLineW = 2.0;
    style.photoframeAngleW = 16;
    style.photoframeAngleH = 16;
    style.colorAngle = [UIColor colorWithHexString:@"#1680f5"];
    
    style.isNeedShowRetangle = YES;
    style.colorRetangleLine = [UIColor colorWithHexString:@"#1680f5"];
    style.anmiationStyle = LBXScanViewAnimationStyle_NetGrid;
    
    //使用的支付宝里面网格图片
    UIImage *imgFullNet = [UIImage imageNamed:@"Group"];//[UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_full_net"];
    style.animationImage = imgFullNet;
    self.style = style;
    self.isOpenInterestRect = YES;
    
}
#pragma mark - ResponeMethod
- (void)tapLeftButton{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    [self stopScan];

//    _zxingObj.capture=nil;
//    _zxingObj=nil;
    [_zxingObj.capture.layer removeFromSuperlayer];
//     _zxingObj.capture.layer = nil;

    [_qRScanView stopScanAnimation];
    
    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark - PrivateMethod
- (void)stopScan
{
    [_zxingObj stop];
    
}
//绘制扫描区域
- (void)drawScanView
{
    if (!_qRScanView)
    {
        CGRect rect = self.view.frame;
        rect.origin = CGPointMake(0, 0);
        
        self.qRScanView = [[LBXScanView alloc]initWithFrame:rect style:_style];
        
        [self.view addSubview:_qRScanView];
        //
        //        //
        //        UIButton* flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        CGFloat flashBtnW = 110;
        //        CGFloat flashBtnH = 51;
        //        CGFloat flashBtnX = (SCREEN_WIDTH - flashBtnW)*0.5;
        //        int XRetangleLeft = _style.xScanRetangleOffset;
        //        CGSize sizeRetangle = CGSizeMake(self.qRScanView.frame.size.width - XRetangleLeft*2, self.qRScanView.frame.size.width - XRetangleLeft*2);
        //        CGFloat flashBtnY = (self.qRScanView.frame.size.height / 2.0 - sizeRetangle.height/2.0 - _style.centerUpOffset + sizeRetangle.height) + 15;
        //        flashButton.frame = CGRectMake(flashBtnX, flashBtnY, flashBtnW, flashBtnH);
        //        [flashButton setImage:[UIImage imageNamed:@"icon_deng"] forState:UIControlStateSelected];
        //        //        [flashButton setTitle:@"关闭闪光" forState:UIControlStateSelected];
        //        [flashButton setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateSelected];
        //        [flashButton setImage:[UIImage imageNamed:@"icon_deng"] forState:UIControlStateNormal];
        //        //        [flashButton setTitle:@"打开闪光" forState:UIControlStateNormal];
        //        [flashButton setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
        //        flashButton.titleLabel.font = [UIFont systemFontOfSize:14];
        //        flashButton.backgroundColor = [UIColor clearColor];
        //        [flashButton setImagePositionWithType:SSImagePositionTypeLeft spacing:10];
        //        [flashButton addTarget:self action:@selector(didTapFlashButton:) forControlEvents:UIControlEventTouchUpInside];
        //        [self.view addSubview:flashButton];
        
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(15,20, 30, 30);
        [leftButton setImage:[UIImage imageNamed:@"fanhui"] forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(tapLeftButton) forControlEvents:UIControlEventTouchUpInside];
        //    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        [self.view addSubview:leftButton];
        
        CGFloat alterBtnW = 250;
        CGFloat alterBtnH = 40;
        CGFloat alterBtnX = (SCREEN_WIDTH - alterBtnW)*0.5;
        int XRetangleLeft = _style.xScanRetangleOffset;
        CGSize sizeRetangle = CGSizeMake(self.qRScanView.frame.size.width - XRetangleLeft*2, self.qRScanView.frame.size.width - XRetangleLeft*2);
        CGFloat alterBtnY = (self.qRScanView.frame.size.height / 2.0 + sizeRetangle.height/2.0 + _style.centerUpOffset - sizeRetangle.height) + Scale_Width(120);
        
        UILabel *titleLab = [UILabel new];
        
        titleLab.text = @"揭开防伪表层，对准二维码，即可自动扫描";
        
        titleLab.textColor = [UIColor whiteColor];
        
        titleLab.font = [UIFont systemFontOfSize:14];
        
        titleLab.textAlignment = NSTextAlignmentCenter;
        
        titleLab.numberOfLines = 0;
        
        [self.view addSubview:titleLab];
        
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
           
//            make.centerX.mas_equalTo(0);
            
            make.top.mas_equalTo(Scale_Width(110));
            
            make.right.mas_equalTo(-10);
            
            make.left.mas_equalTo(10);
        }];
        
        
    }
    [_qRScanView startDeviceReadyingWithText:@"相机启动中"];//
}
- (void)didTapFlashButton:(UIButton *)sender{
    sender.selected = !sender.selected;
    [self openOrCloseFlash];
}
- (void)reStartDevice{
    
    [_zxingObj start];
}
//启动设备
- (void)startScan
{
    if ( ![LBXScanPermissions cameraPemission] )
    {
        [_qRScanView stopDeviceReadying];
        
        [self showError:@"请到设置隐私中开启相机"];
        return;
    }
    
    UIView *videoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    videoView.backgroundColor = [UIColor clearColor];
    [self.view insertSubview:videoView atIndex:0];
    __weak __typeof(self) weakSelf = self;
    
    if (!_zxingObj) {
        
        self.zxingObj = [[ZXingWrapper alloc]initWithPreView:videoView block:^(ZXBarcodeFormat barcodeFormat, NSString *str, UIImage *scanImg) {
            
            LBXScanResult *result = [[LBXScanResult alloc]init];
            result.strScanned = str;
            result.imgScanned = scanImg;
            result.strBarCodeType = [weakSelf convertZXBarcodeFormat:barcodeFormat];
            [weakSelf scanResultWithArray:@[result]];
            
        }];
        
        if (_isOpenInterestRect) {
            //设置只识别框内区域
            CGRect cropRect = [LBXScanView getZXingScanRectWithPreView:videoView style:_style];
            
            [_zxingObj setScanRect:cropRect];
        }
    }
    
    [_zxingObj start];
    [_qRScanView stopDeviceReadying];
    [_qRScanView startScanAnimation];
    self.view.backgroundColor = [UIColor clearColor];
}
#pragma mark -实现类继承该方法，作出对应处理

- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    if (!array ||  array.count < 1)
    {
        [self popAlertMsgWithScanResult:nil];
        
        return;
    }
    
    //经测试，可以同时识别2个二维码，不能同时识别二维码和条形码
    //    for (LBXScanResult *result in array) {
    //
    //        NSLog(@"scanResult:%@",result.strScanned);
    //    }
    
    LBXScanResult *scanResult = array[0];
    
    NSString*strResult = scanResult.strScanned;
    
    self.scanImage = scanResult.imgScanned;
    
    if (!strResult) {
        
        [self popAlertMsgWithScanResult:nil];
        
        return;
    }
    
    //震动提醒
    // [LBXScanWrapper systemVibrate];
    //声音提醒
    //[LBXScanWrapper systemSound];
    
    [self showNextVCWithScanResult:scanResult];
    
}
- (void)popAlertMsgWithScanResult:(NSString*)strResult
{
    if (!strResult) {
        
        strResult = @"识别失败";
    }
    
    __weak __typeof(self) weakSelf = self;
    [LBXAlertAction showAlertWithTitle:@"扫码内容" msg:strResult buttonsStatement:@[@"知道了"] chooseBlock:^(NSInteger buttonIdx) {
        
        [weakSelf reStartDevice];
    }];
}
- (void)showNextVCWithScanResult:(LBXScanResult*)strResult
{
    [self requestDataByRcode:strResult.strScanned];
}


#pragma mark -- 通过编码获取所信息
- (void)requestDataByRcode:(NSString *)recodeStr{
        
    
    __weak __typeof(self) weakSelf = self;
//    if (![NSString getDefaultToken]) {
//
//        LoginViewController *vc = [[LoginViewController alloc]init];
//
//        [self.navigationController pushViewController:vc animated:YES];
//
////        });
//
//        return;
//
//    }
    
    //[SVProgressHUD setStatus:@""];

    NSString *urlStr = [NSString stringWithFormat:@"%@%@",ftpPath,@"pdcSer/auth/getPdcS.html"];
    NSMutableDictionary *diction = [NSMutableDictionary dictionary];
    if (recodeStr.length >0) {
        diction[@"sercontext"] = recodeStr;
    }else{
        [SVProgressHUD showInfoWithStatus: @"您扫描的二维码不正确"];
        return;
    }
//    diction[@"token"] = [NSString getDefaultToken];
//    diction[@"recaddress"] = [[NSUserDefaults standardUserDefaults]objectForKey:@"userAddress"];
//    [SPHttpWithYYCache postRequestUrlStr:urlStr withDic:diction success:^(NSDictionary *requestDic, NSString *msg) {
//        [SVProgressHUD dismiss];
//        if ([requestDic [@"status"] intValue] == 1) {
//
//            NSString *str = [NSString stringWithFormat:@"%@",requestDic [@"content"]];
//
//            ProduceModel *model = [ProduceModel mj_objectWithKeyValues:requestDic[@"data"]];
//
//            if ([str isEqualToString:@"true"]) {
//
//                [NSObject cancelPreviousPerformRequestsWithTarget:self];
//
//                [self stopScan];
//
//                //    _zxingObj.capture=nil;
//                //    _zxingObj=nil;
//                [_zxingObj.capture.layer removeFromSuperlayer];
//                //    _zxingObj.capture.layer = nil;
//
//                [_qRScanView stopScanAnimation];
//                TrueViewController *vc = [[TrueViewController alloc]init];
//
//                vc.picStr = model.pdcpic;
//
//                vc.resultStr = model.pdctitle;
//
//                vc.nameStr = model.pdctitle;
//
//                [self.navigationController pushViewController:vc animated:YES];
//
//            }else{
//
//                [NSObject cancelPreviousPerformRequestsWithTarget:self];
//
//                [self stopScan];
//
//                //    _zxingObj.capture=nil;
//                //    _zxingObj=nil;
//                [_zxingObj.capture.layer removeFromSuperlayer];
//                //    _zxingObj.capture.layer = nil;
//
//                [_qRScanView stopScanAnimation];
//                FalseViewController *vc = [[FalseViewController alloc]init];
//
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//
//        }else{
//
//            [NSObject cancelPreviousPerformRequestsWithTarget:self];
//
//            [self stopScan];
//
//            //    _zxingObj.capture=nil;
//            //    _zxingObj=nil;
//            [_zxingObj.capture.layer removeFromSuperlayer];
//            //    _zxingObj.capture.layer = nil;
//
//            [_qRScanView stopScanAnimation];
//            FalseViewController *vc = [[FalseViewController alloc]init];
//
//            [self.navigationController pushViewController:vc animated:YES];
//
//            [SVProgressHUD showErrorWithStatus:msg];
//        }
//    } failure:^(NSString *errorInfo) {
//        [SVProgressHUD dismiss];
//        [SVProgressHUD showErrorWithStatus:errorInfo];
//    }];
    
    
}


//开关闪光灯
- (void)openOrCloseFlash
{
    [_zxingObj openOrCloseTorch];
    self.isOpenFlash =!self.isOpenFlash;
}
#pragma mark --打开相册并识别图片

/*!
 *  打开本地照片，选择图片识别
 */
- (void)openLocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.delegate = self;
    
    //部分机型有问题
    //    picker.allowsEditing = YES;
    
    
    [self presentViewController:picker animated:YES completion:nil];
}



//当选择一张图片后进入这里

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    __weak __typeof(self) weakSelf = self;
    
    [ZXingWrapper recognizeImage:image block:^(ZXBarcodeFormat barcodeFormat, NSString *str) {
        
        LBXScanResult *result = [[LBXScanResult alloc]init];
        result.strScanned = str;
        result.imgScanned = image;
        result.strBarCodeType = [weakSelf convertZXBarcodeFormat:barcodeFormat];
        
        [weakSelf scanResultWithArray:@[result]];
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"cancel");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//子类继承必须实现的提示
- (void)showError:(NSString*)str
{
    [LBXAlertAction showAlertWithTitle:@"提示" msg:str buttonsStatement:@[@"知道了"] chooseBlock:nil];
}
- (NSString*)convertZXBarcodeFormat:(ZXBarcodeFormat)barCodeFormat
{
    NSString *strAVMetadataObjectType = nil;
    
    switch (barCodeFormat) {
        case kBarcodeFormatQRCode:
            strAVMetadataObjectType = AVMetadataObjectTypeQRCode;
            break;
        case kBarcodeFormatEan13:
            strAVMetadataObjectType = AVMetadataObjectTypeEAN13Code;
            break;
        case kBarcodeFormatEan8:
            strAVMetadataObjectType = AVMetadataObjectTypeEAN8Code;
            break;
        case kBarcodeFormatPDF417:
            strAVMetadataObjectType = AVMetadataObjectTypePDF417Code;
            break;
        case kBarcodeFormatAztec:
            strAVMetadataObjectType = AVMetadataObjectTypeAztecCode;
            break;
        case kBarcodeFormatCode39:
            strAVMetadataObjectType = AVMetadataObjectTypeCode39Code;
            break;
        case kBarcodeFormatCode93:
            strAVMetadataObjectType = AVMetadataObjectTypeCode93Code;
            break;
        case kBarcodeFormatCode128:
            strAVMetadataObjectType = AVMetadataObjectTypeCode128Code;
            break;
        case kBarcodeFormatDataMatrix:
            strAVMetadataObjectType = AVMetadataObjectTypeDataMatrixCode;
            break;
        case kBarcodeFormatITF:
            strAVMetadataObjectType = AVMetadataObjectTypeITF14Code;
            break;
        case kBarcodeFormatRSS14:
            break;
        case kBarcodeFormatRSSExpanded:
            break;
        case kBarcodeFormatUPCA:
            break;
        case kBarcodeFormatUPCE:
            strAVMetadataObjectType = AVMetadataObjectTypeUPCECode;
            break;
        default:
            break;
    }
    
    
    return strAVMetadataObjectType;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
