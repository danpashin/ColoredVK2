//
//  ColoredVKGeneralPrefs.m
//  ColoredVK
//
//  Created by Даниил on 14.04.17.
//
//

#import "ColoredVKGeneralPrefs.h"

#import "ColoredVKAlertController.h"
#import "ColoredVKColorPickerController.h"
#import "VKPhotoPicker.h"

#import "ColoredVKHUD.h"
#import "UIColor+ColoredVK.h"

#import "ColoredVKBackupsModel.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKImageProcessor.h"
#import <objc/runtime.h>

@interface ColoredVKGeneralPrefs () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, ColoredVKColorPickerControllerDelegate, ColoredVKColorPickerControllerDataSource>
@property (strong, nonatomic) NSString *lastImageIdentifier;
@end


@implementation ColoredVKGeneralPrefs

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSArray *specifiersArray = super.specifiers;
        
        ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
        
        BOOL shouldDisable = YES;
        if (newInstaller.user.authenticated)
            shouldDisable = (newInstaller.user.accountStatus != ColoredVKUserAccountStatusPaid);
        else if (__deviceIsJailed)
            shouldDisable = !installerShouldOpenPrefs;
        
        for (PSSpecifier *specifier in specifiersArray) {
            @autoreleasepool {
                if (shouldDisable && ![[self.specifier propertyForKey:@"enabled"] boolValue]) {
                    [specifier setProperty:@NO forKey:@"enabled"];
                } else {
                    [specifier setProperty:@YES forKey:@"enabled"];
                }
            }
        }
        
        _specifiers = specifiersArray;
    }
    return _specifiers;
}

- (void)showColorPicker:(PSSpecifier *)specifier
{
    ColoredVKColorPickerController *picker = [[ColoredVKColorPickerController alloc] initWithIdentifier:specifier.identifier];
    picker.delegate = self;
    picker.dataSource = self;
    picker.statusBarNeedsHidden = NO;
    picker.backgroundStyle = ColoredVKWindowBackgroundStyleCustom;
    [picker show];
}

- (void)chooseImage:(PSSpecifier*)specifier
{
    self.lastImageIdentifier = specifier.identifier;
    
    Class vkPhotoPickerClass = objc_getClass("VKPhotoPicker");
    if (!vkPhotoPickerClass) {
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentPopover:picker];
        return;
    }
    
    VKPPService *ppService = [objc_getClass("VKPPService") standartService];
    VKPhotoPicker *photoPicker = [vkPhotoPickerClass photoPickerWithService:ppService mediaTypes:2];
    photoPicker.selector.selectSingle = YES;
    photoPicker.selector.disableEdits = YES;
    
    photoPicker.handler = ^(VKPhotoPicker *picker, NSArray <VKPPAssetData *> *assetDataArray) {
        
        [picker.currentGroupController dismissViewControllerAnimated:YES completion:nil];
        
        if (assetDataArray.count != 1) {
            [picker dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        ColoredVKHUD *hud = [ColoredVKHUD showHUDForView:picker.view];
        hud.didHiddenBlock = ^{
            [picker dismissViewControllerAnimated:YES completion:nil];
        };
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PHFetchOptions *options = [PHFetchOptions new];
            PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetDataArray.firstObject.assetId] options:options];
            if (fetchResult.count != 1) {
                [hud showFailureWithStatus:@"Could not find asset with vk asset identifier or found multiple assets.\n(Code -1001)"];
                return;
            }
            
            PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
            requestOptions.networkAccessAllowed = YES;
            
            PHImageManager *imageManager = [PHImageManager defaultManager];
            [imageManager requestImageDataForAsset:fetchResult.firstObject options:requestOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                UIImage *image = [UIImage imageWithData:imageData];
                if (image) {
                    [self processImage:image handler:^(BOOL success, NSError *error) {
                        success ? [hud showSuccess] : [hud showFailureWithStatus:error.localizedDescription];
                    }];
                } else {
                    [hud showFailureWithStatus:@"Cannot decrypt image data.\n(Code -1000)"];
                }
            }];
        });
    };
    [self.navigationController presentViewController:photoPicker animated:YES completion:nil];
}

- (void)processImage:(UIImage *)image handler:( void(^)(BOOL success, NSError *error) )handler
{
    ColoredVKImageProcessor *processor = [ColoredVKImageProcessor new];
    NSString *stringPath = [CVK_FOLDER_PATH stringByAppendingString:[NSString stringWithFormat:@"/%@.png", self.lastImageIdentifier]];
    [processor processImage:image identifier:self.lastImageIdentifier saveTo:[NSURL fileURLWithPath:stringPath] completion:^(BOOL success, NSError *error) {
        if (handler) {
            handler(success, error);
        }
        
        [self updateSpecifierWithKey:self.lastImageIdentifier];
        
        if ([self.lastImageIdentifier isEqualToString:@"menuBackgroundImage"])
            POST_CORE_NOTIFICATION(kPackageNotificationReloadMenu);
    }];
}

- (void)resetSettings
{
    [[ColoredVKBackupsModel new] resetSettings];
}

- (void)backupSettings
{
    [[ColoredVKBackupsModel new] createBackup];
}

- (void)showPurchaseAlert
{
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:kPackageName message:CVKLocalizedString(@"AVAILABLE_IN_FULL_VERSION")];
    [alertController addCancelActionWithTitle:CVKLocalizedString(@"THINK_LATER")];
    [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"OF_COURSE") style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[ColoredVKNewInstaller sharedInstaller].user actionPurchase];
                                                      }]];
    [alertController presentFromController:self];
}

#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
    
    if (![[specifier propertyForKey:@"enabled"] boolValue]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [self showPurchaseAlert];
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}


#pragma mark - 
#pragma mark ColoredVKColorPickerControllerDelegate, ColoredVKColorPickerControllerDataSource
#pragma mark - 

- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker willDismissWithColor:(UIColor *)color
{
    [self setPreferenceValue:color ? color.cvk_stringValue : nil forKey:colorPicker.identifier];
}

- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker didSaveColor:(NSString *)hexColor
{
    NSMutableArray <NSString *> *savedColors = self.cachedPrefs[@"savedColors"] ? [self.cachedPrefs[@"savedColors"] mutableCopy] : [NSMutableArray array];
    
    if (![savedColors containsObject:hexColor])
        [savedColors addObject:hexColor];
    
    self.cachedPrefs[@"savedColors"] = savedColors;
    [self writePrefsWithCompetion:nil];
}

- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker didDeleteColor:(NSString *)hexColor
{
    NSMutableArray <NSString *> *savedColors = self.cachedPrefs[@"savedColors"] ? [self.cachedPrefs[@"savedColors"] mutableCopy] : [NSMutableArray array];
    
    if ([savedColors containsObject:hexColor])
        [savedColors removeObject:hexColor];
    
    self.cachedPrefs[@"savedColors"] = savedColors;
    [self writePrefsWithCompetion:nil];
}

- (NSArray <NSString *> *)savedColorsForColorPicker:(ColoredVKColorPickerController *)colorPicker
{
    return self.cachedPrefs[@"savedColors"] ? self.cachedPrefs[@"savedColors"] : @[];
}


#pragma mark - 
#pragma mark UIImagePickerControllerDelegate
#pragma mark - 

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    ColoredVKHUD *hud = [ColoredVKHUD showHUDForView:picker.view];
    hud.didHiddenBlock = ^{
        [picker dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self processImage:info[UIImagePickerControllerOriginalImage] handler:^(BOOL success, NSError *error) {
        success ? [hud showSuccess] : [hud showFailureWithStatus:error.localizedDescription];
    }];
}

@end
