//
//  ColoredVKCollectionCardCell.h
//  ColoredVK2
//
//  Created by Даниил on 13.02.18.
//

#import <UIKit/UIKit.h>

@interface ColoredVKCollectionCardCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) IBOutlet UILabel *headerDetailLabel;
@property (strong, nonatomic) IBOutlet UITextView *bodyTextView;
@property (strong, nonatomic) IBOutlet UIButton *bottomButton;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
