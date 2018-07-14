//
//  ColoredVKPasscodeController.m
//  ColoredVK2
//
//  Created by Даниил on 28.03.18.
//

#import "ColoredVKPasscodeController.h"

#import "ColoredVKNightThemeColorScheme.h"
#import "_UIBackdropView.h"
#import "PrefixHeader.h"

@interface ColoredVKPasscodeController ()

@end

@implementation ColoredVKPasscodeController
@dynamic contentView;

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (IS_IPAD)
        return UIInterfaceOrientationMaskAll;
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if ([ColoredVKNightThemeColorScheme sharedScheme].enabled)
        return UIStatusBarStyleLightContent;
    
    return UIStatusBarStyleDefault;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        self.backgroundStyle = ColoredVKWindowBackgroundStyleCustom;
        self.statusBarNeedsHidden = NO;
        self.hideByTouch = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL nightSchemeEnabled = [ColoredVKNightThemeColorScheme sharedScheme].enabled;
    
    _UIBackdropViewStyle backgroundStyle = nightSchemeEnabled ? _UIBackdropViewStyleDark : _UIBackdropViewSettingsUltraLight;
    _UIBackdropView *backgroundView = [[_UIBackdropView alloc] initWithStyle:backgroundStyle];
    self.backgroundView = backgroundView;
    
    self.contentView = [ColoredVKPasscodeView viewForOwner:self];
    self.contentView.titleLabel.text = CVKLocalizedStringInBundle(@"ENTER_PASSCODE", self.cvkBundle);
    self.contentView.delegate = self;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.contentView.bottomRightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView.bottomRightButton setTitle:UIKitLocalizedString(@"Cancel") forState:UIControlStateNormal];
    [self.contentView.bottomRightButton setTitle:@"" forState:UIControlStateSelected];
    [self.contentView.bottomRightButton setTitleColor:CVKAltColor forState:UIControlStateNormal];
    
    UIImage *backspace = CVKImageInBundle(@"BackspaceIcon", self.cvkBundle);
    backspace = [backspace imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.contentView.bottomRightButton.imageView.tintColor = CVKAltColor;
    [self.contentView.bottomRightButton setImage:backspace forState:UIControlStateSelected];
    
    
    if (nightSchemeEnabled) {
        self.contentView.tintColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
    } else {
        backgroundView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
        self.contentView.tintColor = [UIColor colorWithRed:84/255.0f green:85/255.0f blue:85/255.0f alpha:1.0f];
    }
    
    [self setupConstraints];
}

- (void)setupConstraints
{
    UILayoutGuide *guide = self.view.layoutMarginsGuide;
    if (@available(iOS 11.0, *)) {
        guide = self.view.safeAreaLayoutGuide;
    }
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
    [self.contentView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor].active = YES;
    [self.contentView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor].active = YES; 
}

@end
