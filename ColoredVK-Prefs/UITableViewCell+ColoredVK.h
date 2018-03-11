//
//  UITableViewCell+ColoredVK.h
//  ColoredVK2
//
//  Created by Даниил on 04/02/2018.
//

#import <UIKit/UIKit.h>
#import "ColoredVKCellBackgroundView.h"

@interface UITableViewCell (ColoredVK)

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
