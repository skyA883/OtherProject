//
//  TBImageService.h
//  FTShareView
//
//  Created by liu zhibin on 13-3-5.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface UIImage (IDPExtension)


#pragma mark rotation

/*
 图片旋转
 */
- (UIImage *)rotate:(UIImageOrientation)orient;

/*
 图片旋转并且根据maxSize 进行等比缩放
 */
- (UIImage *)rotateAndScaleFromCameraWithMaxSize:(CGFloat)maxSize;

/*
 图片根据maxSize 进行等比缩放
 */
- (UIImage *)scaleWithMaxSize:(CGFloat)maxSize;

/*
 图片根据maxSize和quality进行等比缩放
 */
- (UIImage*)scaleWithMaxSize:(CGFloat)maxSize
                    quality:(CGInterpolationQuality)quality;

// 自由翻转图片根据给出的degress, if degrees > 0 then rotation is ClockWise
- (UIImage *)rotateImage:(CGFloat) degrees;


#pragma mark resize

/*
 *根据bounds 截取图片
 *The bounds will be adjusted using CGRectIntegral.
 *This method ignores the image's imageOrientation setting.
 */
- (UIImage *)croppedImage:(CGRect)bounds;

/*
 *根据给出的thumbnailSize 、borderSize、cornerRadius、quality 进行等比压缩图片
 *thumbnailSize 最大的宽或高
 *borderSize    图片边框大小
 *cornerRadius  圆角大小
 *quality       缩放质量
 */
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;

/*
 *根据质量和size 压缩图片
 */
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

/*
 *根据质量和size、UIViewContentMode 压缩图片
 */
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
interpolationQuality:(CGInterpolationQuality)quality;


/*
 *根据质量和size、transform 压缩图片
 *transform  变换方式
 *transpose  是否进行变换
 */
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;

/*
 *根据cornerSize、borderSize 创建图片圆角效果
 *cornerSize  圆角大小
 *borderSize  边框大小
 */
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;


// Returns a copy of the given image, adding an alpha channel if it doesn't already have one
- (UIImage *)imageWithAlpha;


// Returns a copy of the image with a transparent border of the given size added around its edges.
// If the image has no alpha layer, one will be added to it.
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;


#pragma mark conversion/detection

// 把图片转换成灰度色用8位/像素 --converts UIImage to grayscale with 8bpp
+ (UIImage *)convertTo8bppGrayscaleFromImage:(UIImage *)uimage;

// 把图片转换成灰度色用8位/像素并且根据maxSize进行等比缩放 maxSize = -1 when you don't want to scale the image
+ (UIImage *)convertTo8bppGrayscaleFromImage:(UIImage *)image scaleToMaximumSize:(NSInteger) maxSize;


@end
