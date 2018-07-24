//
//  ColoredVKImagePreviewController.h
//  ColoredVK2
//
//  Created by Даниил on 24/07/2018.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColoredVKImagePreviewController : UIViewController

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithImageAtPath:(NSString *)path;
- (instancetype)initWithImageAtPath:(NSString *)path previewActions:(nullable NSArray <id <UIPreviewActionItem>> *)previewActions;

@end

NS_ASSUME_NONNULL_END
