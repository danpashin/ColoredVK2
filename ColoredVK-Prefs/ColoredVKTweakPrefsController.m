//
//  ColoredVKTweakPrefsController.m
//  ColoredVK2
//
//  Created by Даниил on 04.08.17.
//
//

#import "ColoredVKTweakPrefsController.h"
#import "ColoredVKUpdatesController.h"

@interface ColoredVKTweakPrefsController ()

@property (strong, nonatomic) ColoredVKUpdatesController *updatesController;
@property (nonatomic, getter=getLastCheckForUpdates, copy) NSString *lastCheckForUpdates;

@end

@implementation ColoredVKTweakPrefsController

- (void)loadView
{
    [super loadView];
    
    self.updatesController = [ColoredVKUpdatesController new];
    self.lastCheckForUpdates = self.updatesController.localizedLastCheckForUpdates;
}

- (void)checkForUpdates
{
    __weak typeof(self) weakSelf = self;
    self.updatesController.checkCompletionHandler = ^(ColoredVKUpdatesController *controller) {
        weakSelf.lastCheckForUpdates = controller.localizedLastCheckForUpdates;
        [weakSelf reloadSpecifiers];
    };
    self.updatesController.showErrorAlert = YES;
    [self.updatesController checkUpdates];
}

@end
