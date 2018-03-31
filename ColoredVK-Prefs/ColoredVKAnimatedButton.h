//
//  ColoredVKAnimatedButton.h
//  test
//
//  Created by Даниил on 10.03.18.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <UIKit/UIButton.h>

@interface ColoredVKAnimatedButton : UIButton

@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) void (^selectHandler)(void);

@end
