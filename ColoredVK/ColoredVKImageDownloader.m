//
//  ColoredVKImageDownloader.m
//  ColoredVK
//
//  Created by Даниил on 05/09/16.
//
//

#import "ColoredVKImageDownloader.h"
#import "UIImage+ResizeMagick.h"
#import "PrefixHeader.h"

@interface ColoredVKImageDownloader ()
@property (strong, nonatomic) NSString *cvkFolder;
@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@implementation ColoredVKImageDownloader


- (instancetype)init
{
    NSLog(@"ColoredVKImageDownloader must be initialized with initWithFrame:imageIdentifier:andSources:");
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame imageIdentifier:(NSString *)identifier andSources:(NSArray *)sources
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        self.sources = sources;
        self.imageIdentifier = identifier;
        
        self.images = [NSMutableArray array];
        
        if (self.sources.count == 1){
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self saveImage:[self downloadImageWithSource:self.sources[0][@"max"] andData:nil][@"image"] withImageIdentifier:self.imageIdentifier];
        } else {
            for (NSDictionary *sizes in self.sources) {
                [self.images addObject:[self downloadImageWithSource:sizes[@"min"] andData:@{
                                                                                             @"maxURL" : sizes[@"max"]
                                                                                             }]];
            }
            
            [self.collectionView reloadData];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.cvkFolder = CVK_FOLDER_PATH;
    self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width / 2, self.view.frame.size.width / 2);
    flowLayout.scrollDirection =  UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 
                                                                             self.view.frame.origin.y + self.navigationController.navigationBar.frame.size.height, 
                                                                             self.view.frame.size.width, 
                                                                             self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height - self.view.frame.origin.x) 
                                             collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor colorWithRed:237.0/255.0f green:238.0/255.0f blue:240.0/255.0f alpha:1];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    self.collectionView.scrollEnabled = YES;
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.view addSubview:self.collectionView];
}
- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil]; 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    UIImageView *imageView = [UIImageView new];
    imageView.frame = cell.frame;
    imageView.tag = 23;
    imageView.image = self.images[indexPath.row][@"image"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = [UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0];
    
    [cell.contentView addSubview:imageView];
    
    imageView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UIImage *cellImage = self.images[indexPath.row];
//    NSString *url = cellImage.accessibilityIdentifier;
//    UIImage *image = [self downloadImageWithSource:url andData:nil];
//    [self saveImage:image withImageIdentifier:self.imageIdentifier];
    
    CVKLog(self.images[indexPath.row][@"maxURL"]);
    [self saveImage:[self downloadImageWithSource:self.images[indexPath.row][@"maxURL"] andData:nil][@"image"] withImageIdentifier:self.imageIdentifier];
}



- (NSDictionary *)downloadImageWithSource:(NSString *)url andData:(NSDictionary *)data
{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    UIImage *image = [UIImage imageWithData:[NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil]];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"image"] = image;
    if (data) {
        dict[@"maxURL"] =  data[@"maxURL"];
    }
    return dict;
    
}

- (void)saveImage:(UIImage *)image withImageIdentifier:(NSString *)imageID
{
    NSString *imagePath = [self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", imageID]];
    NSString *prevImagePath = [self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", imageID]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.cvkFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.cvkFolder withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    
    UIImage *newImage = image;
    newImage = [newImage resizedImageByMagick: [NSString stringWithFormat:@"%fx%f#", [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height]];
    
    BOOL success = [UIImagePNGRepresentation(newImage) writeToFile:imagePath atomically:YES];
    if (success) {
        UIGraphicsBeginImageContext(CGSizeMake(40, 40));
        UIImage *preview = image;
        [preview drawInRect:CGRectMake(0, 0, 40, 40)];
        preview = UIGraphicsGetImageFromCurrentImageContext();
        [UIImagePNGRepresentation(preview) writeToFile:prevImagePath atomically:YES];
        UIGraphicsEndImageContext();
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"ERROR", nil, self.cvkBundle, nil)
                                                        message:NSLocalizedStringFromTableInBundle(@"CAN_NOT_SAVE_IMAGE_TRY_AGAIN", nil, self.cvkBundle, nil)
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk.image.update" object:nil userInfo:@{@"identifier" : imageID}];
    
    if ([imageID isEqualToString:@"menuBackgroundImage"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
    }
    
    if ([imageID isEqualToString:@"messagesBackgroundImage"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.messages"), NULL, NULL, YES);
    }
    
    [self dismiss];

}

@end



//__block NSMutableArray *sources = [NSMutableArray array];
//dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{                                                                               
//    
//    for (VKPhotoSized *photoSized in self.photos) {
//        int maxType = 1;
//        NSString *maxImageURL;
//        NSString *minImageURL;
//        for (VKImageVariant *variant in photoSized.variants.allValues) {
//            if (variant.type > maxType) {
//                maxImageURL = variant.src;
//            }
//            if (variant.type == 3) {
//                minImageURL = variant.src;
//            }
//        }
//        [sources addObject:@{
//                             @"max" : maxImageURL,
//                             @"min" : minImageURL
//                             }];
//    }
//});

