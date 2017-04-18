//
//  UIImage+Scale.m
//  MahimaApp
//
//  Created by Ashley Mills on 11/08/2009.

//

#import "UIImage+Scale.h"


@implementation UIImage (Scale)

- (UIImage *)scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
