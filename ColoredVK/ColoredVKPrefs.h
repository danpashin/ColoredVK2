//
//  ColoredVKPrefs.h
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Preferences.h"

@interface ColoredVKPrefs : PSListController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    NSString *prefsPath;
    NSString *cvkFolder;
    NSBundle *cvkBunlde;
}

@property (strong, nonatomic) NSString *imageID;
@end
