//
//  ColoredVKGeneralPrefs.h
//  ColoredVK
//
//  Created by Даниил on 14.04.17.
//
//

#import "ColoredVKPrefs.h"
#import "ColoredVKColorPickerViewController.h"
#import "UIImage+ResizeMagick.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ColoredVKHUD.h"
#import "UIImage+ResizeMagick.h"
#import "ColoredVKSettingsController.h"
//#import "YMSPhotoPickerViewController.h"


@interface ColoredVKGeneralPrefs : ColoredVKPrefs  <UIImagePickerControllerDelegate, UINavigationControllerDelegate> // YMSPhotoPickerViewControllerDelegate

@property (strong, nonatomic) NSString *lastImageIdentifier;

@end
