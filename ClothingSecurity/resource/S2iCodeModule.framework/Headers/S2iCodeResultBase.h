//
//  S2iCodeResultBase.h
//  S2iCodeModule
//
//  Created by Pai Peng on 09.04.18.
//  Copyright © 2018 zzc_copy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface S2iCodeResultBase : NSObject
/**
 * 国家
 */
@property (nonatomic, strong) NSString *country;
/**
 * 省市
 */
@property (nonatomic, strong) NSString *province;
/**
 * 城市
 */
@property (nonatomic, strong) NSString *city;
/**
 * 地址
 */
@property (nonatomic, strong) NSString *address;
/**
 * 纬度
 */
@property (nonatomic) float  latitude;
/**
 * 经度
 */
@property (nonatomic) float  longitude;
/**
 * 状态码
 */
@property (nonatomic) NSInteger statusCode;



@end
