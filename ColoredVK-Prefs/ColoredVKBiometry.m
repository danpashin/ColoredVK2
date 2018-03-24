//
//  ColoredVKBiometry.m
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import "ColoredVKBiometry.h"

#import "_UIBackdropView.h"
#import "PrefixHeader.h"
#import "ColoredVKPasscodeView.h"
#import "ColoredVKWallpaperView.h"

#import <dlfcn.h>
#import <LocalAuthentication/LocalAuthentication.h>

@interface ColoredVKBiometry () <ColoredVKPasscodeViewDelegate>

@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic) LAContext *authContext;
@property (nonatomic, copy) void (^successBlock)(void);
@property (nonatomic, copy) void (^failureBlock)(void);

@property (strong, nonatomic) ColoredVKPasscodeView *contentView;

@property (assign, nonatomic) BOOL supportsTouchID;
@property (assign, nonatomic) BOOL supportsFaceID;

@end


@implementation ColoredVKBiometry

@dynamic contentView;

+ (void)authenticateWithSuccess:( void(^)(void) )successBlock failure:( void(^)(void) )failureBlock
{
    ColoredVKBiometry *biometry = [ColoredVKBiometry new];
    biometry.successBlock = [successBlock copy];
    biometry.failureBlock = [failureBlock copy];
    [biometry show];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{    
    return UIInterfaceOrientationMaskPortrait;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        self.authContext = [LAContext new];
        self.backgroundStyle = ColoredVKWindowBackgroundStyleCustom;
        self.statusBarNeedsHidden = NO;
        self.hideByTouch = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ColoredVKWallpaperView *wallpaper = [[ColoredVKWallpaperView alloc] initWithFrame:self.view.frame imageName:@"menuBackgroundImage"
                                                                             blackout:0.2f enableParallax:NO blurBackground:YES];
    wallpaper.backgroundColor = [UIColor clearColor];
    wallpaper.imageView.backgroundColor = [UIColor clearColor];
    [wallpaper setupConstraints];
    self.backgroundView = wallpaper;
    
    NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    NSArray *nibViews = [cvkBundle loadNibNamed:NSStringFromClass([ColoredVKPasscodeView class]) owner:self options:nil];
    self.contentView = nibViews.firstObject;
    self.contentView.delegate = self;
    
    
    self.supportsTouchID = [self.authContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
    if (@available(iOS 11.0, *)) {
        self.supportsFaceID = (self.authContext.biometryType == LABiometryTypeFaceID);
        self.supportsTouchID = (self.supportsTouchID && (self.authContext.biometryType == LABiometryTypeTouchID));
    }
    self.contentView.supportsTouchID = self.supportsTouchID;
    self.contentView.supportsFaceID = self.supportsFaceID;
    
    
    [self setupConstrains];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self actionAuthenticate];
    });
}

- (void)setupConstrains
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


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)actionAuthenticate
{
    if (!self.supportsTouchID && !self.supportsFaceID)
        return;
    
    NSString *reson = CVKLocalizedStringInBundle(@"ACCESS_TO_ACCOUNT_SETTINGS", self.cvkBundle);
    [self.authContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reson reply:^(BOOL success, NSError * _Nullable error) {
        if (!success) 
            return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.successBlock)
                self.successBlock();
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self hide];
            });
        });
    }];
}


#pragma mark -
#pragma mark ColoredVKPasscodeViewDelegate
#pragma mark -

- (void)passcodeViewRequestedDismiss:(ColoredVKPasscodeView *)passcodeView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.failureBlock)
            self.failureBlock();
    });
    
    [self hide];
}

- (void)passcodeViewRequestedBiometric:(ColoredVKPasscodeView *)passcodeView
{
    [self actionAuthenticate];
}

@end
