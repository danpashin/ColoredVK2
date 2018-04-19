//
//  ColoredVKImageProcessor.h
//  ColoredVK2
//
//  Created by Даниил on 23.09.17.
//

#import <Foundation/NSObject.h>
#import <UIKit/UIImage.h>

typedef  void (^ImageProcessorCompletion)(BOOL success, NSError *error);

@interface ColoredVKImageProcessor : NSObject

- (void)processImageFromURL:(NSURL *)url identifier:(NSString *)identifier saveTo:(NSURL *)urlToSave completion:(ImageProcessorCompletion)completion;
- (void)processImage:(UIImage *)image identifier:(NSString *)identifier saveTo:(NSURL *)urlToSave completion:(ImageProcessorCompletion)completion;

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;

@end
