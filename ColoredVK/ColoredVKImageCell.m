//
//  ColoredVKImageCell.m
//  ColoredVK
//
//  Created by Даниил on 25.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKImageCell.h"
#import "PrefixHeader.h"
#import "ColoredVKJailCheck.h"

@implementation ColoredVKImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        
        BOOL injected = [ColoredVKJailCheck isInjected];
        prefsPath = injected?CVK_NON_JAIL_PREFS_PATH:CVK_JAIL_PREFS_PATH;
        cvkFolder = injected?CVK_NON_JAIL_FOLDER_PATH:CVK_JAIL_FOLDER_PATH;   
        
        NSString *identifier = specifier.identifier;
        
        if ([identifier isEqualToString:@"barImage"]) { self.key = @"enabledBarImage"; }
        if ([identifier isEqualToString:@"menuBackgroundImage"]) { self.key = @"enabledMenuImage"; }
        if ([identifier isEqualToString:@"messagesBackgroundImage"]) { self.key = @"enabledMessagesImage"; }
		
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImageCell:) name:@"com.daniilpashin.coloredvk.image.update" object:nil];
        
        int imageViewSize = 28;
        self.myImageView = [UIImageView new];
        self.myImageView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/1.3 - imageViewSize, 
                                            (self.contentView.frame.size.height - imageViewSize)/2,
                                            imageViewSize, imageViewSize);
        self.myImageView.backgroundColor = [UIColor colorWithRed:239/255.0f green:239/255.0f blue:244/255.0f alpha:1.0f];
        self.myImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.myImageView.layer.masksToBounds = YES;
        self.myImageView.layer.cornerRadius = 6;
        self.myImageView.tag = 20;
        
        self.myImageView.userInteractionEnabled = YES;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(removeImage:)];
        longPress.minimumPressDuration = 1.0;
        longPress.accessibilityElements = @[identifier];
        [self.myImageView addGestureRecognizer:longPress];
        
        self.opaque = YES;
        self.contentView.opaque = YES;
        self.myImageView.opaque = YES;
        
        if (![self.subviews containsObject: [self viewWithTag:20] ]) { [self addSubview:self.myImageView]; }

        [self updateCellForIdentifier:identifier];
    }
    return self;
}

- (void)updateCellForIdentifier:(NSString *)identifier
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    
    UISwitch *switchView = [UISwitch new];
    [switchView addTarget:self action:@selector(writeSwtchState:) forControlEvents:UIControlEventValueChanged];
    switchView.on = [prefs[self.key] boolValue];
    switchView.enabled = NO;
    switchView.opaque = YES;
    self.accessoryView = switchView;
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", identifier]]]];
        if (image != nil) {
            dispatch_async (dispatch_get_main_queue(), ^{
                self.myImageView.image = image;
                switchView.enabled = YES; 
            });
        }
    }];
    [operation start];
    
}

- (void)writeSwtchState:(UISwitch *)switchView
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    
    [prefs setValue:@(switchView.on) forKey:self.key];
    [prefs writeToFile:prefsPath atomically:YES];
    
    [self sendNotifications];
}

- (void)updateImageCell:(NSNotification *)notification
{
    NSString *identifier = notification.userInfo[@"identifier"];
    if ([(self.specifier).identifier isEqualToString:identifier]) { [self updateCellForIdentifier:identifier]; }
	[self sendNotifications];
}

- (void)removeImage:(UILongPressGestureRecognizer *)recognizer
{
    NSString *identifier = recognizer.accessibilityElements.lastObject;
    
    if ([identifier isEqualToString:(self.specifier).identifier]) {
        NSString *previewPath = [cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", identifier]];
        NSString *fullImagePath = [cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", identifier]];
        
        
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:previewPath]) [fileManager removeItemAtPath:previewPath error:&error];
        if ([fileManager fileExistsAtPath:fullImagePath]) [fileManager removeItemAtPath:fullImagePath error:&error];
        
        if (!error) {
            self.myImageView.image = nil;
            
            UISwitch *switchView = (UISwitch *)self.accessoryView;
            switchView.on = NO;
            switchView.enabled = NO;
            
            NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
            [prefs setValue:@NO forKey:self.key];
            [prefs writeToFile:prefsPath atomically:YES];
            
            [self sendNotifications];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];;
}


- (void)sendNotifications
{
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
    
    if ([self.key isEqualToString:@"enabledMenuImage"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
    }
    
    if ([self.key isEqualToString:@"enabledMessagesImage"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.messages"), NULL, NULL, YES);
    }

}

@end
