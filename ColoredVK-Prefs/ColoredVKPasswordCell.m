//
//  ColoredVKPasswordCell.m
//  ColoredVK
//
//  Created by Даниил on 16.04.17.
//
//

#import "ColoredVKPasswordCell.h"
#import "PrefixHeader.h"

@implementation ColoredVKPasswordCell

+ (ColoredVKPasswordCell *)cellForViewController:(UIViewController *)viewController
{
    return [[NSBundle bundleWithPath:CVK_BUNDLE_PATH] loadNibNamed:NSStringFromClass([ColoredVKPasswordCell class]) owner:viewController options:nil].firstObject;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textField.delegate = self;
    [self.textField addTarget:self action:@selector(textDidChange) forControlEvents:UIControlEventEditingChanged];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self textDidChange];
    return YES;
}


- (void)textDidChange
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(passwordCellChangedText:)]) [self.delegate passwordCellChangedText:self];
    });
}


@end
