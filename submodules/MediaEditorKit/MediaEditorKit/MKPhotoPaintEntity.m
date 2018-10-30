#import "MKPhotoPaintEntity.h"

@implementation MKPhotoPaintEntity

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        arc4random_buf(&_uuid, sizeof(NSInteger));
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)__unused zone
{
    return nil;
}

- (instancetype)duplicate
{
    MKPhotoPaintEntity *entity = [self copy];
    arc4random_buf(&entity->_uuid, sizeof(NSInteger));
    return entity;
}

@end
