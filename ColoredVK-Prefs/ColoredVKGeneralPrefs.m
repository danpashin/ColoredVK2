//
//  ColoredVKGeneralPrefs.m
//  ColoredVK
//
//  Created by Даниил on 14.04.17.
//
//

#import "ColoredVKGeneralPrefs.h"

#import "ColoredVKColorPickerController.h"
#import "ColoredVKHUD.h"
#import "ColoredVKSettingsController.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKImageProcessor.h"
#import "VKPhotoPicker.h"
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
        else if (newInstaller.jailed)
            shouldDisable = !newInstaller.shouldOpenPrefs;
        
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


- (void)showColorPicker:(PSSpecifier*)specifier
{
    ColoredVKColorPickerController *picker = [[ColoredVKColorPickerController alloc] initWithIdentifier:specifier.identifier];
    picker.delegate = self;
    picker.dataSource = self;
    picker.statusBarNeedsHidden = NO;
    picker.backgroundStyle = ColoredVKWindowBackgroundStyleCustom;
    picker.app_is_vk = self.app_is_vk;
    picker.enableNightTheme = self.nightThemeColorScheme.enabled;
    picker.nightThemeColorScheme = self.nightThemeColorScheme;
    [picker show];
}


#pragma mark - 
#pragma mark ColoredVKColorPickerControllerDelegate
#pragma mark - 

- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker willDismissWithColor:(UIColor *)color
{
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    
    if (color) {
        prefs[colorPicker.identifier] = color.stringValue;
    } else {
        if (prefs[colorPicker.identifier]) [prefs removeObjectForKey:colorPicker.identifier];
    }
    
    [prefs writeToFile:CVK_PREFS_PATH atomically:YES];
    
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, NULL, YES);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.prefs.colorUpdate" object:nil userInfo:@{@"identifier":colorPicker.identifier}];
    
    NSArray *identificsToReloadMenu = @[@"MenuSeparatorColor", @"switchesTintColor", @"switchesOnTintColor", @"menuTextColor"];
    if ([identificsToReloadMenu containsObject:colorPicker.identifier])
        CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
    
    if (self.app_is_vk) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UINavigationBar *navBar = self.navigationController.navigationBar;
            navBar.barTintColor = navBar.barTintColor;
            navBar.tintColor = navBar.tintColor;
            navBar.titleTextAttributes = navBar.titleTextAttributes;
        });
    }
}

- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker didSaveColor:(NSString *)hexColor
{
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    NSMutableArray <NSString *> *savedColors = prefs[@"savedColors"] ? prefs[@"savedColors"] : [NSMutableArray new];
    
    if (![savedColors containsObject:hexColor])
        [savedColors addObject:hexColor];
    
    prefs[@"savedColors"] = savedColors;
    [prefs writeToFile:CVK_PREFS_PATH atomically:YES];
}

- (void)colorPicker:(ColoredVKColorPickerController *)colorPicker didDeleteColor:(NSString *)hexColor
{
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    NSMutableArray <NSString *> *savedColors = prefs[@"savedColors"] ? prefs[@"savedColors"] : [NSMutableArray new];
    
    if ([savedColors containsObject:hexColor])
        [savedColors removeObject:hexColor];
    
    prefs[@"savedColors"] = savedColors;
    [prefs writeToFile:CVK_PREFS_PATH atomically:YES];
}


#pragma mark - 
#pragma mark ColoredVKColorPickerControllerDataSource
#pragma mark - 

- (NSArray <NSString *> *)savedColorsForColorPicker:(ColoredVKColorPickerController *)colorPicker
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    NSArray <NSString *> *savedColors = prefs[@"savedColors"] ? prefs[@"savedColors"] : [NSArray new];
    
    return savedColors;
}


#pragma mark - 
#pragma mark UIImagePickerControllerDelegate
#pragma mark - 

- (void)chooseImage:(PSSpecifier*)specifier
{
    self.lastImageIdentifier = specifier.identifier;
    
    Class photoPickerClass = objc_getClass("VKPhotoPicker");
    if (photoPickerClass) {
        VKPPService *ppService = [objc_getClass("VKPPService") standartService];
        VKPhotoPicker *photoPicker = [objc_getClass("VKPhotoPicker") photoPickerWithService:ppService mediaTypes:2];
        
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
                if (fetchResult.count == 1) {
                    PHImageRequestOptions *requestOptions = [PHImageRequestOptions new];
                    requestOptions.networkAccessAllowed = YES;
                    
                    PHImageManager *imageManager = [PHImageManager defaultManager];
                    [imageManager requestImageDataForAsset:fetchResult.firstObject options:requestOptions 
                                             resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                                                 UIImage *image = [UIImage imageWithData:imageData];
                                                 if (image) {
                                                     [self processImage:image handler:^(BOOL success, NSError *error) {
                                                         success ? [hud showSuccess] : [hud showFailureWithStatus:error.localizedDescription];
                                                     }];
                                                 } else {
                                                     [hud showFailureWithStatus:@"Cannot decrypt image data.\n(Code -1000)"];
                                                 }
                                             }];
                } else {
                    [hud showFailureWithStatus:@"Could not find asset with vk asset identifier or found multiple assets.\n(Code -1001)"];
                }
            });
        };
        [self.navigationController presentViewController:photoPicker animated:YES completion:nil];
    } else {
        UIImagePickerController *picker = [UIImagePickerController new];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentPopover:picker];
    }
}

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

- (void)processImage:(UIImage *)image handler:( void(^)(BOOL success, NSError *error) )handler
{
    ColoredVKImageProcessor *processor = [ColoredVKImageProcessor new];
    NSString *stringPath = [CVK_FOLDER_PATH stringByAppendingString:[NSString stringWithFormat:@"/%@.png", self.lastImageIdentifier]];
    [processor processImage:image identifier:self.lastImageIdentifier andSaveToURL:[NSURL fileURLWithPath:stringPath] 
            completionBlock:^(BOOL success, NSError *error) {
                if (handler) {
                    handler(success, error);
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.image.update" object:nil userInfo:@{@"identifier" : self.lastImageIdentifier}];
                
                if ([self.lastImageIdentifier isEqualToString:@"menuBackgroundImage"]) {
                    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
                }
            }];
}


#pragma mark -
- (void)clearCoversCache
{
    ColoredVKHUD *hud = [ColoredVKHUD showHUD];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:CVK_CACHE_PATH])
            [[NSFileManager defaultManager] removeItemAtPath:CVK_CACHE_PATH error:nil];
        [hud showSuccess];
        [self reloadSpecifiers];
    });
}

- (NSString *)cacheSize
{
    @autoreleasepool {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        float size = 0;
        for (NSString *fileName in [fileManager subpathsOfDirectoryAtPath:CVK_CACHE_PATH error:nil]) {
            size += [[fileManager attributesOfItemAtPath:[CVK_CACHE_PATH stringByAppendingPathComponent:fileName] error:nil][NSFileSize] floatValue];
        }
        size = size / 1024.0f / 1024.0f;
        return [NSString stringWithFormat:@"%.1f MB", size];
    }
}

- (void)resetSettings
{
    [[ColoredVKSettingsController new] actionReset];
}

- (void)backupSettings
{
    [[ColoredVKSettingsController new] actionBackup];
}

@end
