//
//  ColoredVKBarDownloadButton.h
//  ColoredVK
//
//  Created by Даниил on 02/12/16.
//
//

#import <UIKit/UIKit.h>

@interface ColoredVKBarDownloadButton : UIBarButtonItem

+ (instancetype)button;
+ (instancetype)buttonWithURL:(NSString *)url rootController:(UIViewController *)controller;

@property (strong, nonatomic) NSString *(^urlBlock)(void);
@property (weak, nonatomic) UIViewController *rootViewController;

- (instancetype)initWithURL:(NSString *)url rootController:(UIViewController *)controller;

@end
