#import "MKImageUtils.h"
#import "LegacyComponentsInternal.h"

static bool retinaInitialized = false;

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
    CGFloat fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

UIImage *TGScaleImageToPixelSize(UIImage *image, CGSize size)
{
    UIGraphicsBeginImageContextWithOptions(size, true, 1.0f);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

UIImage *TGImageNamed(NSString *name)
{
    if (iosMajorVersion() >= 8)
        return [UIImage imageNamed:name inBundle:nil compatibleWithTraitCollection:nil];
    else
        return [UIImage imageNamed:name];
}

UIImage *TGTintedImage(UIImage *image, UIColor *color)
{
    if (image == nil)
        return nil;
    
    UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    CGContextSetBlendMode (context, kCGBlendModeSourceAtop);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

@implementation UIImage (Preloading)

- (CGSize)screenSize
{
    float scale = TGIsRetina() ? 2.0f : 1.0f;
    if (ABS(self.scale - 1.0) < FLT_EPSILON)
        return CGSizeMake(self.size.width / scale, self.size.height / scale);
    return self.size;
}

@end

CGSize TGFitSize(CGSize size, CGSize maxSize)
{
    if (size.width < 1)
        size.width = 1;
    if (size.height < 1)
        size.height = 1;
        
    if (size.width > maxSize.width)
    {
        size.height = CGFloor((size.height * maxSize.width / size.width));
        size.width = maxSize.width;
    }
    if (size.height > maxSize.height)
    {
        size.width = CGFloor((size.width * maxSize.height / size.height));
        size.height = maxSize.height;
    }
    return size;
}

CGSize TGFitSizeF(CGSize size, CGSize maxSize)
{
    if (size.width < 1)
        size.width = 1;
    if (size.height < 1)
        size.height = 1;
    
    if (size.width > maxSize.width)
    {
        size.height = (size.height * maxSize.width / size.width);
        size.width = maxSize.width;
    }
    if (size.height > maxSize.height)
    {
        size.width = (size.width * maxSize.height / size.height);
        size.height = maxSize.height;
    }
    return size;
}

CGSize TGScaleToFill(CGSize size, CGSize boundsSize)
{
    if (size.width < 1.0f || size.height < 1.0f)
        return CGSizeMake(1.0f, 1.0f);
    
    CGFloat scale = MAX(boundsSize.width / size.width, boundsSize.height / size.height);
    return CGSizeMake(CGRound(size.width * scale), CGRound(size.height * scale));
}

CGFloat TGRetinaPixel = 0.5f;
CGFloat TGScreenPixel = 0.5f;

CGFloat TGRetinaFloor(CGFloat value)
{
    return TGIsRetina() ? (CGFloor(value * 2.0f)) / 2.0f : CGFloor(value);
}

bool TGIsRetina()
{
    static bool value = true;
    static bool initialized = false;
    if (!initialized)
    {
        value = [[UIScreen mainScreen] scale] > 1.5f;
        initialized = true;
        
        TGRetinaPixel = value ? 0.5f : 0.0f;
        TGScreenPixel = 1.0f / [[UIScreen mainScreen] scale];
    }
    return value;
}

CGFloat TGScreenScaling()
{
    static CGFloat value = 2.0f;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        value = [UIScreen mainScreen].scale;
    });
    
    return value;
}

bool TGIsPad()
{
    static bool value = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        value = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    });
    
    return value;
}

CGSize TGScreenSize()
{
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIScreen *screen = [UIScreen mainScreen];
        
        if ([screen respondsToSelector:@selector(fixedCoordinateSpace)])
            size = [screen.coordinateSpace convertRect:screen.bounds toCoordinateSpace:screen.fixedCoordinateSpace].size;
        else
            size = screen.bounds.size;
    });
    
    return size;
}

CGSize TGNativeScreenSize()
{
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        UIScreen *screen = [UIScreen mainScreen];
        
        if ([screen respondsToSelector:@selector(nativeBounds)])
            size = [screen.coordinateSpace convertRect:screen.nativeBounds toCoordinateSpace:screen.fixedCoordinateSpace].size;
        else
            size = TGScreenSize();
    });
    
    return size;
}

static bool readCGFloat(NSString *string, int &position, CGFloat &result) {
    int start = position;
    bool seenDot = false;
    int length = (int)string.length;
    while (position < length) {
        unichar c = [string characterAtIndex:position];
        position++;
        
        if (c == '.') {
            if (seenDot) {
                return false;
            } else {
                seenDot = true;
            }
        } else if ((c < '0' || c > '9') && c != '-') {
            if (position == start) {
                result = 0.0f;
                return true;
            } else {
                result = [[string substringWithRange:NSMakeRange(start, position - start)] floatValue];
                return true;
            }
        }
    }
    if (position == start) {
        result = 0.0f;
        return true;
    } else {
        result = [[string substringWithRange:NSMakeRange(start, position - start)] floatValue];
        return true;
    }
    return true;
}

void TGDrawSvgPath(CGContextRef context, NSString *path) {
    int position = 0;
    int length = (int)path.length;
    
    while (position < length) {
        unichar c = [path characterAtIndex:position];
        position++;
        
        if (c == ' ') {
            continue;
        }
        
        if (c == 'M') { // M
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            readCGFloat(path, position, x);
            readCGFloat(path, position, y);
            CGContextMoveToPoint(context, x, y);
        } else if (c == 'L') { // L
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            readCGFloat(path, position, x);
            readCGFloat(path, position, y);
            CGContextAddLineToPoint(context, x, y);
        } else if (c == 'C') { // C
            CGFloat x1 = 0.0f;
            CGFloat y1 = 0.0f;
            CGFloat x2 = 0.0f;
            CGFloat y2 = 0.0f;
            CGFloat x = 0.0f;
            CGFloat y = 0.0f;
            readCGFloat(path, position, x1);
            readCGFloat(path, position, y1);
            readCGFloat(path, position, x2);
            readCGFloat(path, position, y2);
            readCGFloat(path, position, x);
            readCGFloat(path, position, y);
            
            CGContextAddCurveToPoint(context, x1, y1, x2, y2, x, y);
        } else if (c == 'Z') { // Z
            CGContextClosePath(context);
            CGContextFillPath(context);
            CGContextBeginPath(context);
        } else if (c == 'S') { // Z
            CGContextClosePath(context);
            CGContextStrokePath(context);
            CGContextBeginPath(context);
        } else if (c == 'U') { // Z
            CGContextStrokePath(context);
            CGContextBeginPath(context);
        }
    }
}
