//
//  VKPhotoPicker.h
//  ColoredVK2
//
//  Created by Даниил on 27.11.17.
//

#import <Photos/Photos.h>

@interface VKPPService : NSObject

+ (id)standartService;

@end

@interface VKPPSelector : NSObject

@property (assign, nonatomic) BOOL forceCrop;
@property (assign, nonatomic) BOOL disableEdits;
@property (assign, nonatomic) BOOL selectSingle; 
@property (assign, nonatomic) NSUInteger selectLimit;

@end

@interface VKPPAssetData : NSObject <NSCopying>

@property (strong, nonatomic) NSString *assetFilename;
@property (strong, nonatomic) NSURL *assetURL;
@property (strong, nonatomic) NSString *assetId;

@end

@interface VKPhotoPicker : UINavigationController

+ (VKPhotoPicker *)photoPickerWithService:(VKPPService *)service mediaTypes:(NSInteger)arg2;

@property (copy, nonatomic) void (^handler)(VKPhotoPicker *picker, NSArray <VKPPAssetData *> *assetData);
@property (strong, nonatomic) VKPPSelector *selector;
@property (nonatomic, readonly, strong) UIViewController *currentGroupController;

@end
