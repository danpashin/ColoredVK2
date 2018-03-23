//
//  ColoredVKColorCollectionViewCell.h
//  ColoredVK2
//
//  Created by Даниил on 20.06.17.
//
//

#import "ColoredVKColorPreview.h"

@class ColoredVKColorCollectionViewCell;
@protocol ColoredVKColorCollectionViewCellDelegate <NSObject>

@optional
- (void)colorCell:(ColoredVKColorCollectionViewCell *)cell deleteColor:(NSString *)hexColor;

@end


@interface ColoredVKColorCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) NSString *hexColor;
@property (weak, nonatomic) id <ColoredVKColorCollectionViewCellDelegate> delegate;

@end
