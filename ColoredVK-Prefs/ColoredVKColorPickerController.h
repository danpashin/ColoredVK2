//
//  ColorPicker.h
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ColoredVKWindowController.h"

typedef NS_ENUM(NSUInteger, ColoredVKColorPickerState) {
    ColoredVKColorPickerStateDismiss = 1,
    ColoredVKColorPickerStateReset
};


@class ColoredVKColorPickerController;
@protocol ColoredVKColorPickerControllerDelegate <NSObject>

@optional
- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker willDismissWithColor:(UIColor *)color;
- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker didSaveColor:(NSString *)hexColor;
- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker didDeleteColor:(NSString *)hexColor;

@end

@protocol ColoredVKColorPickerControllerDataSource <NSObject>

@optional
- (NSArray <NSString *> *)savedColorsForColorPicker:(ColoredVKColorPickerController *)colorPicker;

@end


@interface ColoredVKColorPickerController : ColoredVKWindowController

+ (instancetype)pickerWithIdentifier:(NSString *)identifier;
- (instancetype)initWithIdentifier:(NSString *)identifier;

@property (strong, nonatomic, readonly) NSString *identifier;

@property (nonatomic) id <ColoredVKColorPickerControllerDelegate> delegate;
@property (nonatomic) id <ColoredVKColorPickerControllerDataSource> dataSource;

@end
