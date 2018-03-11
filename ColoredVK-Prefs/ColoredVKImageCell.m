//
//  ColoredVKImageCell.m
//  ColoredVK
//
//  Created by Даниил on 25.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKImageCell.h"
#import "PrefixHeader.h"
#import <Preferences/PSSpecifier.h>
#import "ColoredVKHUD.h"
#import "ColoredVKAlertController.h"

@interface ColoredVKImageCell ()

@property (strong, nonatomic, readonly) NSString *prefsPath;
@property (strong, nonatomic, readonly) NSString *cvkFolder;
@property (strong, nonatomic, readonly) NSString *key;

@property (strong, nonatomic) UIImageView *previewImageView;
@property (strong, nonatomic) UISwitch *switchView;
@property (weak, nonatomic) ColoredVKHUD *hud;

@end

@implementation ColoredVKImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {        
        _prefsPath = CVK_PREFS_PATH;
        _cvkFolder = CVK_FOLDER_PATH;
        
        NSString *specifierIdentifier = specifier.identifier;
        if ([specifierIdentifier isEqualToString:@"barImage"]) _key = @"enabledBarImage"; 
        if ([specifierIdentifier isEqualToString:@"menuBackgroundImage"]) _key = @"enabledMenuImage"; 
        if ([specifierIdentifier isEqualToString:@"messagesBackgroundImage"]) _key = @"enabledMessagesImage"; 
        if ([specifierIdentifier isEqualToString:@"messagesListBackgroundImage"]) _key = @"enabledMessagesListImage";
        if ([specifierIdentifier isEqualToString:@"groupsListBackgroundImage"]) _key = @"enabledGroupsListImage";
        if ([specifierIdentifier isEqualToString:@"audioBackgroundImage"]) _key = @"enabledAudioImage";
        if ([specifierIdentifier isEqualToString:@"audioCoverImage"]) _key = @"enabledAudioCustomCover";
        if ([specifierIdentifier isEqualToString:@"friendsBackgroundImage"]) _key = @"enabledFriendsImage";
        if ([specifierIdentifier isEqualToString:@"videosBackgroundImage"]) _key = @"enabledVideosImage";
        if ([specifierIdentifier isEqualToString:@"settingsBackgroundImage"]) _key = @"enabledSettingsImage";
        if ([specifierIdentifier isEqualToString:@"settingsExtraBackgroundImage"]) _key = @"enabledSettingsExtraImage";
        
        CGFloat imageViewSize = 30.0f;
        _previewImageView = [UIImageView new];
        _previewImageView.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width/1.3f - imageViewSize, (self.contentView.frame.size.height - imageViewSize)/2.0f, imageViewSize, imageViewSize);
        _previewImageView.backgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f];
        _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        _previewImageView.userInteractionEnabled = YES;
        _previewImageView.layer.masksToBounds = YES;
        _previewImageView.layer.cornerRadius = CGRectGetHeight(_previewImageView.frame) / 4;
        [self.contentView addSubview:_previewImageView];
        
        _previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *metrics = @{@"width":@(imageViewSize)};
        NSDictionary *views = @{@"view":_previewImageView};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(width)]-|"   options:0 metrics:metrics views:views]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_previewImageView attribute:NSLayoutAttributeCenterY 
                                                                     relatedBy:0 toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_previewImageView attribute:NSLayoutAttributeHeight 
                                                                     relatedBy:0 toItem:nil attribute:0 multiplier:1.0f constant:imageViewSize]];
        
        
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:_prefsPath];
        _switchView = [UISwitch new];
        [_switchView addTarget:self action:@selector(switchTriggerred:) forControlEvents:UIControlEventValueChanged];
        _switchView.on = prefs?[prefs[_key] boolValue]:NO;
        _switchView.enabled = NO;
        self.accessoryView = _switchView;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showActionsController:)];
        longPress.minimumPressDuration = 1.0;
        longPress.accessibilityElements = @[specifierIdentifier];
        [self addGestureRecognizer:longPress];
        
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateImage:) name:@"com.daniilpashin.coloredvk2.image.update" object:nil];
        [self updateImageForIdentifier:specifierIdentifier];
    }
    return self;
}

- (void)updateImageForIdentifier:(NSString *)identifier
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:[self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", identifier]]];
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.switchView.enabled = YES;
                self.previewImageView.image = image;
            });
        }
    });
}

- (void)switchTriggerred:(UISwitch *)switchView
{
    if (self.key.length == 0)
        return;
    
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:self.prefsPath];
    if (!prefs) prefs = [NSMutableDictionary new];
    
    prefs[self.key] = @(switchView.on);
    [prefs writeToFile:self.prefsPath atomically:YES];
    
    [self sendNotifications];
}

- (void)updateImage:(NSNotification *)notification
{
    NSString *identifier = notification.userInfo[@"identifier"];
    if ([self.specifier.identifier isEqualToString:identifier])
        [self updateImageForIdentifier:identifier];
}

- (void)showActionsController:(UILongPressGestureRecognizer *)recognizer
{
    NSString *identifier = recognizer.accessibilityElements.lastObject;
    
    if ([self.specifier propertyForKey:@"enabled"] && ![[self.specifier propertyForKey:@"enabled"] boolValue]) {
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSString *imagePath = [self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", identifier]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            return;
        }
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:UIKitLocalizedString(@"Save to Camera Roll") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.hud = [ColoredVKHUD showHUD];
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }];
        
        UIAlertAction *shareAction = [UIAlertAction actionWithTitle:UIKitLocalizedString(@"Share...") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIImage *image = [UIImage imageWithContentsOfFile:[self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", identifier]]];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
            if (IS_IPAD) {
                activityVC.popoverPresentationController.permittedArrowDirections = 0;
                activityVC.popoverPresentationController.sourceView = rootViewController.view;
                activityVC.popoverPresentationController.sourceRect = rootViewController.view.bounds;
            }
            [rootViewController presentViewController:activityVC animated:YES completion:nil];
        }];
        
        UIAlertAction *removeAction = [UIAlertAction actionWithTitle:UIKitLocalizedString(@"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            ColoredVKAlertController *warningAlert = [ColoredVKAlertController alertControllerWithTitle:CVKLocalizedString(@"WARNING")  
                                                                                                message:CVKLocalizedString(@"REMOVE_IMAGE_WARNING")
                                                                                         preferredStyle:UIAlertControllerStyleAlert];
            [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") 
                                                             style:UIAlertActionStyleCancel handler:^(UIAlertAction *warningAction) {}]];
            [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Delete") 
                                                             style:UIAlertActionStyleDestructive  handler:^(UIAlertAction *warningAction) { 
                NSString *previewPath = [self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", identifier]];
                
                NSError *error = nil;
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                if ([fileManager fileExistsAtPath:previewPath]) [fileManager removeItemAtPath:previewPath error:&error];
                if ([fileManager fileExistsAtPath:imagePath]) [fileManager removeItemAtPath:imagePath error:&error];
                
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.previewImageView.image = nil;
                        [self.switchView setOn:NO animated:YES];
                        self.switchView.enabled = NO;
                    });
                    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:self.prefsPath];
                    prefs[self.key] = @NO;
                    [prefs writeToFile:self.prefsPath atomically:YES];
                    [self sendNotifications];
                }
            }]];
            [warningAlert present];
        }];
        
        ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:saveAction image:@"prefs/SaveIconAlt"];
        [alertController addAction:shareAction image:@"prefs/ShareIcon"];
        [alertController addAction:removeAction image:@"prefs/RemoveIcon"];
        [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
        [alertController present];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error)
        [self.hud showSuccess];
    else
        [self.hud showFailureWithStatus:error.localizedFailureReason];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}


- (void)sendNotifications
{
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, NULL, YES);
    
    if ([self.key isEqualToString:@"enabledMenuImage"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
    }

}

@end
