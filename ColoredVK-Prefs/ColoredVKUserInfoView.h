//
//  ColoredVKUserInfoView.h
//  ColoredVK2
//
//  Created by Даниил on 03/02/2018.
//

#import <UIKit/UIKit.h>

@class ColoredVKUserInfoView;
@protocol ColoredVKUserInfoViewDelegate <NSObject>
@optional
- (void)infoView:(ColoredVKUserInfoView *)infoView didUpdateHeight:(CGFloat)height;
@end

@interface ColoredVKUserInfoView : UIView

@property (strong, nonatomic) UIImage *avatar;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *email;
@property (assign, nonatomic, readonly) CGFloat preferredHeight;

@property (weak, nonatomic) id <ColoredVKUserInfoViewDelegate> delegate;

@end
