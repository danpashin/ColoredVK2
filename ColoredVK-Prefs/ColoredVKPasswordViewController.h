//
//  ColoredVKPasswordViewController.h
//  ColoredVK
//
//  Created by Даниил on 16.04.17.
//
//

#import <UIKit/UIKit.h>
#import "ColoredVKPasswordCell.h"
#import "ColoredVKHUD.h"

@interface ColoredVKPasswordViewController : UIViewController

@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *cells;
@property (strong, nonatomic) ColoredVKPasswordCell *currentPassCell;
@property (strong, nonatomic) ColoredVKPasswordCell *passNewCell;
@property (strong, nonatomic) ColoredVKPasswordCell *confirmCell;
@property (strong, nonatomic) ColoredVKHUD *hud;

@end
