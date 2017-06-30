//
//  ColoredVKResponsiveButton.h
//  ColoredVK2
//
//  Created by Даниил on 30.06.17.
//
//

#import <UIKit/UIKit.h>

@interface ColoredVKResponsiveButton : UIButton

@property (strong, nonatomic, readonly) NSString *cachedTitle;
@property (assign, nonatomic) UIEdgeInsets cachedTitleEdgeInsets;

@end
