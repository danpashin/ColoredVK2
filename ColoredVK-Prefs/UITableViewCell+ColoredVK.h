//
//  UITableViewCell+ColoredVK.h
//  ColoredVK2
//
//  Created by Даниил on 04/02/2018.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (ColoredVK)

@property (strong, nonatomic) UIColor *renderedBackroundColor;
@property (strong, nonatomic) UIColor *renderedSeparatorColor;
@property (strong, nonatomic) UIColor *renderedHighlightedColor;

/**
 *  Делает рендер кастомного бекграунда с дефолтными цветами.
 *  
 *  По умолчанию цвет фона белый, разделителей в RGB - 232, 233, 234.
 *
 *  @param tableView Таблица, для которой необходимо делать рендер.
 *  @param indexPath Индекс ячейки. Нужен для расчета закругления.
 */

- (void)renderBackgroundForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

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

/**
 *  Принудительно обновляет цвета у ячейки.
 *
 *  @param backgroundColor Цвет фона.
 *  @param separatorColor Цвет сепаратора.
 */

- (void)updateRenderedBackgroundWithBackgroundColor:(UIColor *)backgroundColor separatorColor:(UIColor *)separatorColor;

@end
