//
//  ColoredVKImageCell.m
//  ColoredVK
//
//  Created by Даниил on 25.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKImageCell.h"
#import "PrefixHeader.h"
#import "PSSpecifier.h"
#import "ColoredVKHUD.h"
#import "ColoredVKAlertController.h"

@interface ColoredVKImageCell ()

@property (strong, nonatomic) NSString *prefsPath;
@property (strong, nonatomic) NSString *cvkFolder;
@property (strong, nonatomic) NSString *key;

@property (strong, nonatomic) UIImageView *previewImageView;
@property (strong, nonatomic) UISwitch *switchView;
@property (weak, nonatomic) ColoredVKHUD *hud;

@end

@implementation ColoredVKImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {        
        self.prefsPath = CVK_PREFS_PATH;
        self.cvkFolder = CVK_FOLDER_PATH;
        
        NSString *identifier = specifier.identifier;
        if ([identifier isEqualToString:@"barImage"]) self.key = @"enabledBarImage"; 
        if ([identifier isEqualToString:@"menuBackgroundImage"]) self.key = @"enabledMenuImage"; 
        if ([identifier isEqualToString:@"messagesBackgroundImage"]) self.key = @"enabledMessagesImage"; 
        if ([identifier isEqualToString:@"messagesListBackgroundImage"]) self.key = @"enabledMessagesListImage";
        if ([identifier isEqualToString:@"groupsListBackgroundImage"]) self.key = @"enabledGroupsListImage";
        if ([identifier isEqualToString:@"audioBackgroundImage"]) self.key = @"enabledAudioImage";
        if ([identifier isEqualToString:@"audioCoverImage"]) self.key = @"enabledAudioCustomCover";
        if ([identifier isEqualToString:@"friendsBackgroundImage"]) self.key = @"enabledFriendsImage";
        if ([identifier isEqualToString:@"videosBackgroundImage"]) self.key = @"enabledVideosImage";
        if ([identifier isEqualToString:@"settingsBackgroundImage"]) self.key = @"enabledSettingsImage";
        if ([identifier isEqualToString:@"settingsExtraBackgroundImage"]) self.key = @"enabledSettingsExtraImage";
        
        int imageViewSize = 30;
        self.previewImageView = [UIImageView new];
        self.previewImageView.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width/1.3 - imageViewSize, (self.contentView.frame.size.height - imageViewSize)/2, imageViewSize, imageViewSize);
        self.previewImageView.backgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f];
        self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.previewImageView.userInteractionEnabled = YES;
        self.previewImageView.layer.masksToBounds = YES;
        self.previewImageView.layer.cornerRadius = CGRectGetHeight(self.previewImageView.frame) / 4;
        [self.contentView addSubview:self.previewImageView];
        
        self.previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *metrics = @{@"width":@(imageViewSize)};
        NSDictionary *views = @{@"view":self.previewImageView};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view(width)]-|" options:0 metrics:metrics views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(width)]-|"   options:0 metrics:metrics views:views]];
        
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
        self.switchView = [UISwitch new];
        [self.switchView addTarget:self action:@selector(switchTriggerred:) forControlEvents:UIControlEventValueChanged];
        self.switchView.on = prefs?[prefs[self.key] boolValue]:NO;
        self.switchView.enabled = NO;
        self.accessoryView = self.switchView;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showActionsController:)];
        longPress.minimumPressDuration = 1.0;
        longPress.accessibilityElements = @[identifier];
        [self addGestureRecognizer:longPress];
        
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateImage:) name:@"com.daniilpashin.coloredvk2.image.update" object:nil];
        [self updateImageForIdentifier:identifier];
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
            [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
            [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Delete") style:UIAlertActionStyleDestructive  handler:^(UIAlertAction *action) { 
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
        [alertController addAction:saveAction image:@"SaveIconAlt"];
        [alertController addAction:shareAction image:@"ShareIcon"];
        [alertController addAction:removeAction image:@"RemoveIcon"];
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
