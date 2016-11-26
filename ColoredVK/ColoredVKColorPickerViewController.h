//
//  ColorPicker.h
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ColoredVKColorPickerViewController : UIViewController
- (instancetype)initWithIdentifier:(NSString *)identifier;
@property (strong, nonatomic) UIWindow *pickerWindow;
@end
