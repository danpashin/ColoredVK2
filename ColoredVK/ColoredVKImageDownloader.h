//
//  ColoredVKImageDownloader.h
//  ColoredVK
//
//  Created by Даниил on 05/09/16.
//
//

#import <UIKit/UIKit.h>

@interface ColoredVKImageDownloader : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) NSArray *sources;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSString *imageIdentifier;
- (instancetype)initWithFrame:(CGRect)frame imageIdentifier:(NSString *)identifier andSources:(NSArray *)sources;
@end
