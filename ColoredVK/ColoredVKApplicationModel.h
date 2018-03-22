//
//  ColoredVKApplicationModel.h
//  ColoredVK2
//
//  Created by Даниил on 09.03.18.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ColoredVKVersionCompare)
{
    ColoredVKVersionCompareLess = -1,
    ColoredVKVersionCompareEqual = 0,
    ColoredVKVersionCompareMore = 1
};


@interface ColoredVKApplicationModel : NSObject

@property (assign, nonatomic, readonly) BOOL isVKApp;
@property (copy, nonatomic, readonly) NSString *version;
@property (copy, nonatomic, readonly) NSString *detailedVersion;

@property (copy, nonatomic, readonly) NSString *sellerName;
@property (copy, nonatomic, readonly) NSString *teamIdentifier;
@property (copy, nonatomic, readonly) NSString *teamName;

- (ColoredVKVersionCompare)compareAppVersionWithVersion:(NSString *)second_version;
- (ColoredVKVersionCompare)compareVersion:(NSString *)first_version withVersion:(NSString *)second_version;

@end
