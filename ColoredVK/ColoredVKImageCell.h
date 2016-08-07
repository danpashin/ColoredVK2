//
//  ColoredVKImageCell.h
//  ColoredVK
//
//  Created by Даниил on 25.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Preferences.h"

@interface ColoredVKImageCell : PSTableCell {
    NSString *prefsPath;
    NSString *cvkFolder;
}

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) UIImageView *myImageView;
@end
