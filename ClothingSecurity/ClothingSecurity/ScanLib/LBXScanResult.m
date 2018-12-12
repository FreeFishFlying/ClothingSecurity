//
//  LBXScanResult.m
//  gongjiaolaila
//
//  Created by handong on 17/8/11.
//  Copyright © 2017年 gongjiaolaila. All rights reserved.
//

#import "LBXScanResult.h"

@implementation LBXScanResult
- (instancetype)initWithScanString:(NSString*)str imgScan:(UIImage*)img barCodeType:(NSString*)type
{
    if (self = [super init]) {
        
        self.strScanned = str;
        self.imgScanned = img;
        self.strBarCodeType = type;
    }
    
    return self;
}
@end
