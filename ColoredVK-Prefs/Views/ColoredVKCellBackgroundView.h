//
//  ColoredVKCellBackgroundView.h
//  ColoredVK-Prefs
//
//  Created by Даниил on 11.03.18.
//

#import <UIKit/UIKit.h>

@interface ColoredVKCellBackgroundView : UIView

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UITableViewCell *tableViewCell;
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *selectedBackgroundColor;
@property (strong, nonatomic) UIColor *separatorColor;

@end