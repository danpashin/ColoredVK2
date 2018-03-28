//
//  ColorPicker.h
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKWindowController.h"

@class ColoredVKColorPickerController;
@protocol ColoredVKColorPickerControllerDelegate <NSObject>

@optional
- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker willDismissWithColor:(UIColor *)color;
- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker didSaveColor:(NSString *)hexColor;
- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker didDeleteColor:(NSString *)hexColor;

@end

@protocol ColoredVKColorPickerControllerDataSource <NSObject>

@required
- (NSArray <NSString *> *)savedColorsForColorPicker:(ColoredVKColorPickerController *)colorPicker;

@end


@interface ColoredVKColorPickerController : ColoredVKWindowController

- (instancetype)initWithIdentifier:(NSString *)identifier NS_DESIGNATED_INITIALIZER;

@property (strong, nonatomic, readonly) NSString *identifier;
@property (weak, nonatomic) id <ColoredVKColorPickerControllerDelegate> delegate;
@property (weak, nonatomic) id <ColoredVKColorPickerControllerDataSource> dataSource;

@end
