//
//  ColoredVKSelectCell.m
//  test
//
//  Created by Даниил on 22/10/16.
//  Copyright © 2016 Даниил. All rights reserved.
//

#import "ColoredVKSelectCell.h"
#import "BEMCheckBox.h"

@interface ColoredVKSelectCell ()
@property (strong, nonatomic) BEMCheckBox *checkBox;
@end

@implementation ColoredVKSelectCell

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.checkBox = [[BEMCheckBox alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        self.checkBox.hideBox = YES;
        self.checkBox.onCheckColor = [UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:1.0];
        self.checkBox.animationDuration = 0.3;
        self.checkBox.userInteractionEnabled = NO;
        self.accessoryView = self.checkBox;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellRecognizedTap:)]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {}
- (void)setChecked:(id)sender {}

- (void)cellRecognizedTap:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        self.select = !self.select;
        if ([self.delegate respondsToSelector:@selector(didTapCell:)]) [self.delegate didTapCell:self];
    }
}

- (void)setSelect:(BOOL)select
{
    _select = select;
    [self.checkBox setOn:select animated:YES];
}
@end
