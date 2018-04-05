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

@end

@implementation ColoredVKUpdatesPrefsController

- (void)loadView
{
    [super loadView];
    
    ColoredVKUpdatesController *updatesController = [ColoredVKUpdatesController new];
    self.lastCheckForUpdates = updatesController.localizedLastCheckForUpdates;
}

- (void)checkForUpdates
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ColoredVKUpdatesController *updatesController = [ColoredVKUpdatesController new];
        updatesController.showErrorAlert = YES;
        updatesController.checkCompletionHandler = ^(ColoredVKUpdatesController *controller) {
            self.lastCheckForUpdates = controller.localizedLastCheckForUpdates;
            [self reloadSpecifiers];
        };
        [updatesController checkUpdates];
    });
}

@end
