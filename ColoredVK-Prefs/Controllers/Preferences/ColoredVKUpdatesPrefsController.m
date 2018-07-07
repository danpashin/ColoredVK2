//
//  ColoredVKUpdatesPrefsController.m
//  ColoredVK2
//
//  Created by Даниил on 04.08.17.
//
//

#import "ColoredVKUpdatesPrefsController.h"
#import "ColoredVKUpdatesModel.h"

@interface ColoredVKUpdatesPrefsController ()
@property (nonatomic, getter=getLastCheckForUpdates, copy) NSString *lastCheckForUpdates;
@property (strong, nonatomic) ColoredVKUpdatesModel *updatesModel;
@end

@implementation ColoredVKUpdatesPrefsController

- (void)loadView
{
    [super loadView];
    self.updatesModel = [ColoredVKUpdatesModel new];
    self.lastCheckForUpdates = self.updatesModel.localizedLastCheckForUpdates;
}

- (void)checkForUpdates
{
    __weak typeof(self) weakSelf = self;
    self.updatesModel.checkCompletionHandler = ^(ColoredVKUpdatesModel *model) {
        weakSelf.lastCheckForUpdates = model.localizedLastCheckForUpdates;
        [weakSelf reloadSpecifiers];
    };
    [self.updatesModel checkUpdates];
}

@end
