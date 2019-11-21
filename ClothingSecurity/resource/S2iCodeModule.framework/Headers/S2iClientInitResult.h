//
//  S2iClientInitResult.h
//  S2iCodeModule
//
//  Created by Pai Peng on 2018/12/26.
//  Copyright © 2018 zzc_copy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "S2iParam.h"
#import "S2iClientInitBase.h"
NS_ASSUME_NONNULL_BEGIN

@interface S2iClientInitResult : S2iClientInitBase
/**
 * 返回初始化的参数数据
 */
@property(nonatomic, strong) S2iParam* s2iParam;
@end

NS_ASSUME_NONNULL_END
