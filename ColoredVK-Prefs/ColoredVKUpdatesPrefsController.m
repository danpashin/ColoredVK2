//
//  ColoredVKUpdatesPrefsController.m
//  ColoredVK2
//
//  Created by Даниил on 04.08.17.
//
//

#import "ColoredVKUpdatesPrefsController.h"
#import "ColoredVKUpdatesController.h"

@interface ColoredVKUpdatesPrefsController ()
@property (nonatomic, getter=getLastCheckForUpdates, copy) NSString *lastCheckForUpdates;
@property (strong, nonatomic) ColoredVKUpdatesController *updatesController;
@end

@implementation ColoredVKUpdatesPrefsController

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
    [self.updatesController checkUpdates];
}

@end
