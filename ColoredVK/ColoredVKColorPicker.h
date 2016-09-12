//
//  ColorPicker.h
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "NKOColorPickerView.h"
#import "KLCPopup.h"

@interface ColoredVKColorPicker : UIViewController <UITextFieldDelegate> {
    NSString *prefsPath;
    NSBundle *cvkBunlde;
}

@property (strong, nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) UIColor *customColor;
@property (strong, nonatomic) KLCPopup *popup;
@property (strong, nonatomic) NKOColorPickerView *colorPickerView;

@property (strong, nonatomic) NSMutableDictionary *prefs;
@end
