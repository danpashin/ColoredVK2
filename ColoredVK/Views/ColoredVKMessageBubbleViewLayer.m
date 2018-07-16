//
//  ColoredVKMessageBubbleViewLayer.m
//  ColoredVK2
//
//  Created by Даниил on 16.07.18.
//

#import "ColoredVKMessageBubbleViewLayer.h"
#import "ColoredVKMainController.h"

extern BOOL enabled;
extern BOOL enableNightTheme;
extern BOOL useMessageBubbleTintColor;
extern UIColor *messageBubbleTintColor;
extern UIColor *messageBubbleSentTintColor;

@implementation ColoredVKMessageBubbleViewLayer

- (void)setFillColor:(CGColorRef)fillColor
{
    if (enabled && (useMessageBubbleTintColor || enableNightTheme)) {
        UIColor *incomingColor = enableNightTheme ? cvkMainController.nightThemeScheme.incomingBackgroundColor : messageBubbleTintColor;
        UIColor *outgoingColor = enableNightTheme ? cvkMainController.nightThemeScheme.outgoingBackgroundColor : messageBubbleSentTintColor;
        
        const CGFloat *components = CGColorGetComponents(fillColor);
        if (components[0] >= 0.9f) { // входящее
            fillColor = incomingColor.CGColor;
        } else { // исходящее
            fillColor = outgoingColor.CGColor;
        }
    }
    
    super.fillColor = fillColor;
}

@end
