//
//  ColoredVKImageCell.m
//  ColoredVK
//
//  Created by Даниил on 25.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKImageCell.h"
#import "PrefixHeader.h"
#import "LHProgressHUD.h"
#import "PSSpecifier.h"
#import "ColoredVKHUD.h"

@interface ColoredVKImageCell ()
@property (strong, nonatomic) NSString *prefsPath;
@property (strong, nonatomic) NSString *cvkFolder;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) UIImageView *previewImageView;
@property (retain, nonatomic) ColoredVKHUD *hud;
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
        UISwitch *switchView = [UISwitch new];
        [switchView addTarget:self action:@selector(switchTriggerred:) forControlEvents:UIControlEventValueChanged];
        switchView.on = prefs?[prefs[self.key] boolValue]:NO;
        switchView.enabled = NO;
        self.accessoryView = switchView;
        
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
    [[NSBlockOperation blockOperationWithBlock:^{
        UIImage *image = [UIImage imageWithContentsOfFile:[self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", identifier]]];
        if (image) {
            ((UISwitch *)self.accessoryView).enabled = YES;
            self.previewImageView.image = image;
        }
    }] start];
}

- (void)switchTriggerred:(UISwitch *)switchView
{
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:self.prefsPath];
    if (!prefs) prefs = [NSMutableDictionary new];
    
    prefs[self.key] = @(switchView.on);
    [prefs writeToFile:self.prefsPath atomically:YES];
    
    [self sendNotifications];
}

- (void)updateImage:(NSNotification *)notification
{
    NSString *identifier = notification.userInfo[@"identifier"];
    if ([self.specifier.identifier isEqualToString:identifier]) [self updateImageForIdentifier:identifier];
	[self sendNotifications];
}

- (void)showActionsController:(UILongPressGestureRecognizer *)recognizer
{
    NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    NSString *identifier = recognizer.accessibilityElements.lastObject;
    if (recognizer.state == UIGestureRecognizerStateBegan && [identifier isEqualToString:self.specifier.identifier]) {
        UIViewController *viewControllerToShowIn = UIApplication.sharedApplication.keyWindow.rootViewController;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:
         [UIAlertAction actionWithTitle:UIKitLocalizedString(@"Save to Camera Roll") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.hud = [ColoredVKHUD showHUD];
            UIImage *image = [UIImage imageWithContentsOfFile:[self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", identifier]]];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }]];
        
        [alertController addAction:
         [UIAlertAction actionWithTitle:UIKitLocalizedString(@"Share...") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIImage *image = [UIImage imageWithContentsOfFile:[self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", identifier]]];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[image] applicationActivities:nil];
            if (IS_IPAD) {
                activityVC.popoverPresentationController.permittedArrowDirections = 0;
                activityVC.popoverPresentationController.sourceView = viewControllerToShowIn.view;
                activityVC.popoverPresentationController.sourceRect = viewControllerToShowIn.view.bounds;
            }
            [viewControllerToShowIn presentViewController:activityVC animated:YES completion:nil];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            UIAlertController *warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"WARNING", nil, cvkBundle, nil)  
                                                                                  message:NSLocalizedStringFromTableInBundle(@"THIS_ACTION_CAN_NOT_BE_UNDONE", nil, cvkBundle, nil) 
                                                                           preferredStyle:UIAlertControllerStyleAlert];
            [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
            [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Delete") style:UIAlertActionStyleDestructive  handler:^(UIAlertAction *action) { 
                NSString *previewPath = [self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", identifier]];
                NSString *fullImagePath = [self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", identifier]];
                
                NSError *error = nil;
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                if ([fileManager fileExistsAtPath:previewPath]) [fileManager removeItemAtPath:previewPath error:&error];
                if ([fileManager fileExistsAtPath:fullImagePath]) [fileManager removeItemAtPath:fullImagePath error:&error];
                
                if (!error) {
                    self.previewImageView.image = nil;
                    UISwitch *switchView = (UISwitch *)self.accessoryView;
                    [switchView setOn:NO animated:YES];
                    switchView.enabled = NO;
                    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:self.prefsPath];
                    prefs[self.key] = @NO;
                    [prefs writeToFile:self.prefsPath atomically:YES];
                    [self sendNotifications];
                }
            }]];
            [viewControllerToShowIn presentViewController:warningAlert animated:YES completion:nil];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];        
        
        if (IS_IPAD) {
            alertController.popoverPresentationController.permittedArrowDirections = 0;
            alertController.popoverPresentationController.sourceView = viewControllerToShowIn.view;
            alertController.popoverPresentationController.sourceRect = viewControllerToShowIn.view.bounds;
        }
        
        if ([NSFileManager.defaultManager fileExistsAtPath:[self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", identifier]]]) 
            [viewControllerToShowIn presentViewController:alertController animated:YES completion:nil];
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
