//
//  ColoredVKBarDownloadButton.h
//  ColoredVK
//
//  Created by Даниил on 02/12/16.
//
//

#import <UIKit/UIKit.h>

@interface ColoredVKBarDownloadButton : UIBarButtonItem

+ (instancetype)buttonWithURL:(NSString *)url rootController:(UIViewController *)controller;
+ (instancetype)button;

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString*(^urlBlock)();
@property (weak, nonatomic) UIViewController *rootViewController;

@end
