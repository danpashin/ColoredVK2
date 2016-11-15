//
//  ColoredVKSelectCell.h
//  test
//
//  Created by Даниил on 22/10/16.
//  Copyright © 2016 Даниил. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTableCell.h"

@protocol ColoredVKSelectCellDelegate;

@interface ColoredVKSelectCell : UITableViewCell
@property (strong, nonatomic) NSString *value;
@property (assign, nonatomic) BOOL select;
@property (assign, nonatomic) BOOL shouldHighlight;
@property (nonatomic, weak) id <ColoredVKSelectCellDelegate> delegate;
@end


@protocol ColoredVKSelectCellDelegate <NSObject>
@optional
- (void)didTapCell:(ColoredVKSelectCell*)cell;
@end
