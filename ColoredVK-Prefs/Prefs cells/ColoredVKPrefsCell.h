//
//  ColoredVKPrefsCell.h
//  ColoredVK2
//
//  Created by Даниил on 27.06.18.
//

@import Foundation;
@import UIKit;

#import <PSSpecifier.h>
#import <objc/message.h>

#import "ColoredVKCellBackgroundView.h"
#import "ColoredVKNightScheme.h"

@interface ColoredVKPrefsCell : PSTableCell

@property (assign, nonatomic, readonly) SEL defaultPrefsGetter;
@property (weak, nonatomic, readonly) id currentPrefsValue;

@property (strong, nonatomic) ColoredVKCellBackgroundView *customBackgroundView;

/**
 *  Делает рендер кастомного бекграунда с заданными цветами.
 *
 *  @param backgroundColor Цвет фона.
 *  @param separatorColor Цвет сепаратора (-ов, если ячейка не одна).
 *  @param tableView Таблица, для которой необходимо делать рендер.
 *  @param indexPath Индекс ячейки. Нужен для расчета закругления.
 */

- (void)renderBackgroundWithColor:(UIColor *)backgroundColor separatorColor:(UIColor *)separatorColor 
                     forTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;


@end
