//
//  ColoredVKPrefsCell.h
//  ColoredVK2
//
//  Created by Даниил on 27.06.18.
//

@import Foundation;
@import UIKit;

#import <Preferences/PSSpecifier.h>
@class ColoredVKCellBackgroundView;

@interface ColoredVKPrefsCell : PSTableCell

@property (assign, nonatomic, readonly) SEL defaultPrefsGetter;
@property (weak, nonatomic, readonly) id currentPrefsValue;
@property (strong, nonatomic, readonly) UIViewController *forceTouchPreviewController;

@property (strong, nonatomic) ColoredVKCellBackgroundView *customBackgroundView;

/**
 *  Делает рендер кастомного бекграунда с заданными цветами.
 *
 *  @param backgroundColor Цвет фона.
 *  @param tableView Таблица, для которой необходимо делать рендер.
 *  @param indexPath Индекс ячейки. Нужен для расчета закругления.
 */

- (void)renderBackgroundWithColor:(UIColor *)backgroundColor forTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;


@end
