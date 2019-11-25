//
//  S2iParam.h
//  S2iCodeModule
//
//  Created by Pai Peng on 2018/12/26.
//  Copyright © 2018 zzc_copy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface S2iParam : NSObject
/*
 设置用户图形界面对焦框的款（像素）
 对焦框的中心点与视频流图片的中心点一致
 */
@property (nonatomic) float  focusFrameWidth;
/*
 设置用户图形界面对焦框的高（像素）
 对焦框的中心点与视频流图片的中心点一致
 */
@property (nonatomic) float  focusFrameHeight;
/*
 设置视频的宽（像素）
 */
@property (nonatomic) int  previewImageWidth;
/*
 设置视频的高（像素）
 */
@property (nonatomic) int  previewImageHeight;
/*
 设置照相机变焦倍率
 */
@property (nonatomic) float  zoom;

@end

NS_ASSUME_NONNULL_END
