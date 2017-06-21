//
//  ColoredVKColorCollectionViewCell.h
//  ColoredVK2
//
//  Created by Даниил on 20.06.17.
//
//

#import <UIKit/UIKit.h>

@class ColoredVKColorCollectionViewCell;
@protocol ColoredVKColorCollectionViewCellDelegate <NSObject>

@optional
- (void)colorCell:(ColoredVKColorCollectionViewCell *)cell deleteColor:(NSString *)hexColor;

@end



@interface ColoredVKColorCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) NSString *hexColor;
@property (nonatomic) id <ColoredVKColorCollectionViewCellDelegate> delegate;

@end
