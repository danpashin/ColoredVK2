//
//  ColoredVKGeneralPrefs.m
//  ColoredVK
//
//  Created by Даниил on 14.04.17.
//
//

#import "ColoredVKGeneralPrefs.h"


@implementation ColoredVKGeneralPrefs


- (void)showColorPicker:(PSSpecifier*)specifier
{
    ColoredVKColorPickerViewController *picker = [[ColoredVKColorPickerViewController alloc] initWithIdentifier:specifier.identifier];
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.definesPresentationContext = NO;
    picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    picker.view.backgroundColor = [UIColor clearColor];
    
    UIViewController *controller = [UIViewController new];
    picker.pickerWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    picker.pickerWindow.rootViewController = controller;
    [picker.pickerWindow makeKeyAndVisible];
    [controller presentViewController:picker animated:YES completion:nil];
    
}

- (void)chooseImage:(PSSpecifier*)specifier
{
    self.lastImageIdentifier = specifier.identifier;
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentPopover:picker];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self saveImage:image fromPickerViewController:picker]; 
}


- (void)saveImage:(UIImage *)image fromPickerViewController:(UIViewController *)picker
{
    ColoredVKHUD *hud = [ColoredVKHUD showAddedToView:picker.view];
    hud.backgroundView.blurStyle = LHBlurEffectStyleDark;
    hud.centerBackgroundView.blurStyle = LHBlurEffectStyleNone;
    hud.centerBackgroundView.backgroundColor = [UIColor clearColor];
    hud.didHiddenBlock = ^{ [picker dismissViewControllerAnimated:YES completion:nil]; };
    
    hud.executionBlock = ^(ColoredVKHUD *parentHud) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSString *imagePath = [self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", self.lastImageIdentifier]];
            NSString *prevImagePath = [self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", self.lastImageIdentifier]];
            
            NSError *error = nil;
            [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath options:NSDataWritingAtomic error:&error];
            if (!error) {
                UIImage *imageToResize = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
                UIImage *preview = [imageToResize resizedImageByMagick:@"40x40#"];
                [UIImageJPEGRepresentation(preview, 1.0) writeToFile:prevImagePath options:NSDataWritingAtomic error:&error];
                
                CGSize screenSize = [UIScreen mainScreen].bounds.size;
                if ([self.lastImageIdentifier isEqualToString:@"barImage"]) screenSize.height = 64;
                UIImage *recizedImage = [imageToResize resizedImageByMagick:[NSString stringWithFormat:@"%fx%f#", screenSize.width, screenSize.height]];
                [UIImageJPEGRepresentation(recizedImage, 1.0) writeToFile:imagePath options:NSDataWritingAtomic error:&error];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.image.update" object:nil userInfo:@{ @"identifier" : self.lastImageIdentifier }];
                if ([self.lastImageIdentifier isEqualToString:@"menuBackgroundImage"]) {
                    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
                }
                error?[parentHud showFailureWithStatus:error.localizedDescription]:[parentHud showSuccess];
            });
        });
    };
    
    hud.executionBlock(hud);
}


- (void)clearCoversCache
{
    ColoredVKHUD *hud = [ColoredVKHUD showHUD];
    hud.operation = [NSBlockOperation blockOperationWithBlock:^{
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:CVK_CACHE_PATH error:&error];
        if (success && !error) [hud showSuccess];
        else [hud showFailureWithStatus:[NSString stringWithFormat:@"%@\n%@", error.localizedDescription, error.localizedFailureReason]];
        [self reloadSpecifiers];
    }];
}

- (NSString *)cacheSize
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float size = 0;
    for (NSString *fileName in [fileManager subpathsOfDirectoryAtPath:CVK_CACHE_PATH error:nil]) {
        size += [[fileManager attributesOfItemAtPath:[CVK_CACHE_PATH stringByAppendingPathComponent:fileName] error:nil][NSFileSize] floatValue];
    }
    size = size / 1024.0f / 1024.0f;
    return [NSString stringWithFormat:@"%.1f MB", size];
}

- (void)resetSettings
{
    [[ColoredVKSettingsController alloc] actionReset];
}

- (void)backupSettings
{
    [[ColoredVKSettingsController alloc] actionBackup];
}
@end
