//
//  ColoredVKSwiftMenuCell.h
//  ColoredVK2
//
//  Created by Даниил on 04/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColoredVKSwiftMenuButton;

NS_ASSUME_NONNULL_BEGIN

@interface ColoredVKSwiftMenuCell : UICollectionViewCell

@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) ColoredVKSwiftMenuButton *buttonModel;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
