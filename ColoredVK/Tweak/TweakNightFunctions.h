//
//  TweakNightFunctions.h
//  ColoredVK2
//
//  Created by Даниил on 18.07.18.
//

@class NewDialogCell;

extern void setupNewDialogCellForNightTheme(NewDialogCell *dialogCell);
extern void setupNightSeparatorForView(UIView *view);
extern void setupNightTextField(UITextField *textField);

extern NSAttributedString *attributedStringForNightTheme(NSAttributedString *text);
