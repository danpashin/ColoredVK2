//
//  ColoredVKPasswordCell.h
//  ColoredVK
//
//  Created by Даниил on 16.04.17.
//
//

#import <UIKit/UIKit.h>


@class ColoredVKPasswordCell;
@protocol ColoredVKPasswordCellDelegate <NSObject>

- (void)passwordCellChangedText:(ColoredVKPasswordCell *)cell;

@end


@interface ColoredVKPasswordCell : UITableViewCell <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) id <ColoredVKPasswordCellDelegate> delegate;

@end
