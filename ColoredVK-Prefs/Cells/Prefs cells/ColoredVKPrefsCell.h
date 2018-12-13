//
//  ColoredVKPrefsCell.h
//  ColoredVK2
//
//  Created by Даниил on 27.06.18.
//

@import Foundation;
@import UIKit;

#import <Preferences/PSSpecifier.h>

@interface ColoredVKPrefsCell : PSTableCell

@property (assign, nonatomic, readonly) SEL defaultPrefsGetter;
@property (weak, nonatomic, readonly) id currentPrefsValue;
@property (strong, nonatomic, readonly) UIViewController *forceTouchPreviewController;

@end
