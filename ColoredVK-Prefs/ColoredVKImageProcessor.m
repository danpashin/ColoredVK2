//
//  ColoredVKImageProcessor.m
//  ColoredVK2
//
//  Created by Даниил on 23.09.17.
//

#import "ColoredVKImageProcessor.h"
#import "ColoredVKNewInstaller.h"

@implementation ColoredVKImageProcessor

- (void)processImageFromURL:(NSURL *)url identifier:(NSString *)identifier andSaveToURL:(NSURL *)urlToSave 
            completionBlock:( void (^)(BOOL success, NSError *error) )completionBlock
{
    if (!url.isFileURL) {
        ColoredVKNetworkController *networkController = [ColoredVKNewInstaller sharedInstaller].networkController;
        [networkController downloadDataFromURL:url.absoluteString
                                            success:^(NSHTTPURLResponse *response, NSData *rawData) {
                                                UIImage *image = [UIImage imageWithData:rawData];
                                                [self processImage:image identifier:identifier andSaveToURL:urlToSave completionBlock:completionBlock];
                                            }
                                            failure:^(NSHTTPURLResponse *response, NSError *error) {
                                                completionBlock(NO, error);
                                            }];
        
    } else {
        NSError *catchingError = nil;
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&catchingError];
        if (!catchingError)
            [self processImage:[UIImage imageWithData:data] identifier:identifier andSaveToURL:urlToSave completionBlock:completionBlock];
        else
            completionBlock(NO, catchingError);
    }
}

- (void)processImage:(UIImage *)image identifier:(NSString *)identifier andSaveToURL:(NSURL *)urlToSave 
     completionBlock:( void (^)(BOOL success, NSError *error) )completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSURL *previewURL = urlToSave.URLByDeletingLastPathComponent;
        previewURL = [previewURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@_preview", 
                                                              urlToSave.lastPathComponent.stringByDeletingPathExtension]];
        previewURL = [previewURL URLByAppendingPathExtension:urlToSave.pathExtension];
        
        NSError *writingError = nil;
        UIImage *preview = [self resizeImage:image toSize:CGSizeMake(40.0f, 40.0f)];
        [UIImageJPEGRepresentation(preview, 1.0f) writeToURL:previewURL options:NSDataWritingAtomic error:&writingError];
        
        if (!writingError) {
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            screenSize.width += 30.0f;
            screenSize.height += 30.0f;
            if ([identifier isEqualToString:@"barImage"])
                screenSize.height = 64;
            
            UIImage *newImage = [self resizeImage:image toSize:screenSize];
            
            NSError *writingFullImageError = nil;
            BOOL success = [UIImageJPEGRepresentation(newImage, 1.0f) writeToURL:urlToSave options:NSDataWritingAtomic error:&writingFullImageError];
            
            completionBlock(success, writingFullImageError);
                   
        } else {
            completionBlock(NO, writingError);
        }
    });
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size
{
    @autoreleasepool {
        UIImage *resizedImage = [image copy];
        size.width = ceilf((float)size.width);
        size.height = ceilf((float)size.height);
        
            //  переворачиваем
        UIGraphicsBeginImageContextWithOptions(resizedImage.size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (resizedImage.imageOrientation == UIImageOrientationRight) {
            CGContextRotateCTM (context, (CGFloat)(90 * M_PI/180.0f));
        } else if (resizedImage.imageOrientation == UIImageOrientationLeft) {
            CGContextRotateCTM (context, (CGFloat)(-90 * M_PI/180.0f));
        } else if (resizedImage.imageOrientation == UIImageOrientationUp) {
            CGContextRotateCTM (context, (CGFloat)(180 * M_PI/180.0f));
        }
        [resizedImage drawAtPoint:CGPointZero];
        
        CGImageRef imgRef = CGBitmapContextCreateImage(context);
        UIGraphicsEndImageContext();
        
            //  вычисляем данные
        CGFloat original_width  = CGImageGetWidth(imgRef);
        CGFloat original_height = CGImageGetHeight(imgRef);
        CGImageRelease(imgRef);
        
        CGFloat width_ratio = size.width / original_width;
        CGFloat height_ratio = size.height / original_height;
        CGFloat scale_ratio = width_ratio > height_ratio ? width_ratio : height_ratio;
        
            //  вписываем в заданный размер
        CGRect bounds =  CGRectMake(0.0f, 0.0f, (CGFloat)round(original_width * scale_ratio), (CGFloat)round(original_height * scale_ratio));
        UIGraphicsBeginImageContextWithOptions(bounds.size, NO, [UIScreen mainScreen].scale);
        [resizedImage drawInRect:bounds];
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
            //  обрезаем
        CGRect cropRect = CGRectMake ((resizedImage.size.width - size.width) / 2, (resizedImage.size.height - size.height) / 2, size.width, size.height);
        UIGraphicsBeginImageContextWithOptions(cropRect.size, NO, [UIScreen mainScreen].scale);
        CGContextClipToRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, cropRect.size.width, cropRect.size.height));
        [resizedImage drawInRect:CGRectMake(-cropRect.origin.x, -cropRect.origin.y, resizedImage.size.width, resizedImage.size.height)];
        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return resizedImage;
    }
}

@end
