#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
    
UIColor *MKAccentColor();
UIColor *MKColorWithHex(int hex);
UIColor *MKColorWithHexAndAlpha(int hex, CGFloat alpha);

#ifdef __cplusplus
}
#endif
