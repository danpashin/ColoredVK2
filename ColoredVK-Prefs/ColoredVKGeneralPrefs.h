//
//  ColoredVKGeneralPrefs.h
//  ColoredVK
//
//  Created by Даниил on 14.04.17.
//
//

#import "ColoredVKPrefs.h"
#import "ColoredVKColorPickerController.h"


@interface ColoredVKGeneralPrefs : ColoredVKPrefs  <UIImagePickerControllerDelegate, UINavigationControllerDelegate, ColoredVKColorPickerControllerDelegate>

@property (strong, nonatomic) NSString *lastImageIdentifier;

@end
