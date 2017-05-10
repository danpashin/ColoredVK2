//
//  ColorPicker.h
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import <UIKit/UIKit.h>

@class ColoredVKColorPickerController;
@protocol ColoredVKColorPickerControllerDelegate <NSObject>

@optional
- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker didChangeColor:(UIColor *)color;
- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker didResetColorForIdentifier:(NSString *)identifier;
- (void)colorPickerWillDismiss:(ColoredVKColorPickerController *)colorPicker;

@end


@interface ColoredVKColorPickerController : UIViewController

- (instancetype)initWithIdentifier:(NSString *)identifier;
- (void)showPicker;

@property (strong, nonatomic, readonly) NSString *identifier;
@property (nonatomic) id <ColoredVKColorPickerControllerDelegate> delegate;

@end
