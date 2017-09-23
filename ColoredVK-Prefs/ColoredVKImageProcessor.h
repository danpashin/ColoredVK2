//
//  ColoredVKImageProcessor.h
//  ColoredVK2
//
//  Created by Даниил on 23.09.17.
//

@import Foundation;
@import UIKit;

@interface ColoredVKImageProcessor : NSObject

- (void)processImageFromURL:(NSURL *)url identifier:(NSString *)identifier andSaveToURL:(NSURL *)urlToSave 
            completionBlock:( void (^)(BOOL success, NSError *error) )completionBlock;

- (void)processImage:(UIImage *)image identifier:(NSString *)identifier andSaveToURL:(NSURL *)urlToSave 
     completionBlock:( void (^)(BOOL success, NSError *error) )completionBlock;

@end
