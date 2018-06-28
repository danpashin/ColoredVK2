//
//  PSTableCellHook.m
//  ColoredVK2
//
//  Created by Даниил on 28.06.18.
//

#import <Foundation/Foundation.h>
#import "CaptainHook/CaptainHook.h"

#import "ColoredVKPrefs.h"
#import "ColoredVKGeneralPrefs.h"

#import "ColoredVKSwitchPrefsCell.h"
#import "ColoredVKSegmentPrefsCell.h"
#import "ColoredVKStepperPrefsCell.h"


CHDeclareClass(PSTableCell);
CHDeclareClassMethod(1, Class, PSTableCell, cellClassForSpecifier, PSSpecifier *, specifier)
{
    if ([specifier.target isKindOfClass:[ColoredVKPrefs class]]) {
        NSString *cellType = [specifier propertyForKey:@"cellType"];
        
        if ([cellType isEqualToString:@"Switch"]) {
            return [ColoredVKSwitchPrefsCell class];
        } else if ([cellType isEqualToString:@"Link"]) {
            specifier.cellType = PSLinkCell;
            if (!specifier.detailControllerClass)
                specifier.detailControllerClass = [ColoredVKGeneralPrefs class];
        } else if ([cellType isEqualToString:@"Segment"]) {
            return [ColoredVKSegmentPrefsCell class];
        } else if ([cellType isEqualToString:@"Stepper"]) {
            return [ColoredVKStepperPrefsCell class];
        } else if ([cellType isEqualToString:@"ColorWheel"]) {
            return [ColoredVKStepperPrefsCell class];
        }
        
        if (![specifier propertyForKey:@"cellClass"]) {
            return [ColoredVKPrefsCell class];
        }
    }
    
    return CHSuper(1, PSTableCell, cellClassForSpecifier, specifier);
}
