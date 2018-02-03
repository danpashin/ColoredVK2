//
//  ColoredVKTextField.h
//  ColoredVK2
//
//  Created by Даниил on 06/01/2018.
//

#import <UIKit/UIKit.h>

@class ColoredVKTextField;
@protocol ColoredVKTextFieldDelegate <UITextFieldDelegate>

@optional
/*
 *  Вызывается, когда текст уже был заменен
 */
- (void)textField:(ColoredVKTextField *)textField didChangeText:(NSString *)text;
- (BOOL)textFieldShouldRemoveWhiteSpaces:(ColoredVKTextField *)textField;

@end


@interface ColoredVKTextField : UITextField

@property (assign, nonatomic) BOOL error;
@property (weak, nonatomic) id <ColoredVKTextFieldDelegate> delegate;


- (void)shake;
- (void)clear;

@end
