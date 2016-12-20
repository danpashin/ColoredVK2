//
//  ColoredVKBarDownloadButton.h
//  ColoredVK
//
//  Created by Даниил on 02/12/16.
//
//

#import <UIKit/UIKit.h>

@interface ColoredVKBarDownloadButton : UIBarButtonItem
@property (strong, nonatomic) NSString *url;
@property (nonatomic, copy) NSString*(^urlBlock)();
@property (strong, nonatomic) UIViewController *rootViewController;
+ (instancetype)buttonWithURL:(NSString *)url;
+ (instancetype)buttonWithURL:(NSString *)url rootController:(UIViewController *)controller;
+ (instancetype)button;
@end
