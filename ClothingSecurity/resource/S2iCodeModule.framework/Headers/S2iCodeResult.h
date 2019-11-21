//
//  S2iCodeResult.h
//  S2iCodeModule
//
//  Created by zzc_copy on 2017/12/11.
//  Copyright © 2017年 zzc_copy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "S2iCodeResultBase.h"

@interface S2iCodeResult : S2iCodeResultBase

/**
 * 加密数据
 */
@property (nonatomic, strong) NSString *data;
/**
 * 序列号
 */
@property (nonatomic, strong) NSString *serialNumber;
/**
 * 商品详细URL
 */
@property (nonatomic, strong) NSString *marketingUrl;
/**
 * 编码生成时间(毫秒)
 */
@property (nonatomic) long timestamp;

/**
 * 产品名称
 */
@property (nonatomic,strong) NSString *productName;


/**
 * 公司名称
 */
@property (nonatomic,strong) NSString *companyName;


@end
