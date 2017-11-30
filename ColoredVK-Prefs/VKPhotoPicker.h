//
//  VKPhotoPicker.h
//  ColoredVK2
//
//  Created by Даниил on 27.11.17.
//


@interface VKPPService : NSObject
+ (id)standartService;
@end

@interface VKPPSelector : NSObject
@property (nonatomic) BOOL forceCrop;
@property (nonatomic) BOOL disableEdits;
@property (nonatomic) BOOL selectSingle; 
@property (nonatomic) unsigned long long selectLimit;
@end

@interface VKPPAssetData : NSObject <NSCopying>
@property (retain, nonatomic) NSString *assetFilename;
@property (retain, nonatomic) NSURL *assetURL;
@property (retain, nonatomic) NSString *assetId;
@end

@interface VKPhotoPicker : UINavigationController
+ (VKPhotoPicker *)photoPickerWithService:(VKPPService *)service mediaTypes:(NSInteger)arg2;
@property (copy, nonatomic) void (^handler)(VKPhotoPicker *picker, NSArray <VKPPAssetData *> *assetData);
@property (retain, nonatomic) VKPPSelector *selector;
@property (nonatomic, readonly, strong) UIViewController *currentGroupController;
@end
