//
//  ColoredVKCardController.m
//  ColoredVK2
//
//  Created by Даниил on 13.02.18.
//

#import "ColoredVKCardController.h"
#import "PrefixHeader.h"
#import "ColoredVKCollectionCardCell.h"

@interface ColoredVKCardController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UICollectionViewFlowLayout *collectionLayout;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray <ColoredVKCard *> *cards;

@end

@implementation ColoredVKCardController

+ (id)new
{
    NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ColoredVKMain" bundle:cvkBundle];
    ColoredVKCardController *cardController = [storyboard instantiateViewControllerWithIdentifier:@"cardController"];
    
    return cardController;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.collectionLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    self.collectionLayout.minimumLineSpacing = 20.0f;
    objc_setAssociatedObject(self.collectionView, "shouldDisableBackgroundColor", @1, OBJC_ASSOCIATION_ASSIGN);
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (NSArray <ColoredVKCard *> *)cards
{
    if (!_cards) {
        _cards = [NSMutableArray array];
    }
    return _cards;
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addCard:(ColoredVKCard *)card
{
    [self.cards addObject:card];
    [self.collectionView reloadData];
}

- (void)addCards:(NSArray <ColoredVKCard *> *)cards
{
    [self.cards addObjectsFromArray:cards];
    [self.collectionView reloadData];
}


#pragma mark -
#pragma mark UIGestureRecognizerDelegate
#pragma mark -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isEqual:self.collectionView] || [touch.view isEqual:self.view])
        return YES;
    
    return NO;
}

#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout
#pragma mark -

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (self.cards.count == 1) {
        CGFloat inset = (CGRectGetWidth(self.collectionView.frame) - self.collectionLayout.itemSize.width) / 2.0f;
        return UIEdgeInsetsMake(0.0f, inset, 0.0f, inset);
    }
    
    return self.collectionLayout.sectionInset;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cardSize = CGSizeMake(320.0f, 455.0f);
    if (self.cards.count == 1) {
        cardSize.width += 10.0f;
    }
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;    
    if (screenSize.width == 320.0f) {
        cardSize.width = 280.0f;
    }
    
    if (screenSize.height == 480.0f) {
        cardSize.height = 400.0f;
    }
    
    return cardSize;
}


#pragma mark -
#pragma mark UICollectionViewDataSource
#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.cards.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ColoredVKCollectionCardCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cardCell" forIndexPath:indexPath];
    objc_setAssociatedObject(cell, "shouldDisableBackgroundColor", @1, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(cell.headerLabel, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(cell.headerDetailLabel, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(cell.bodyTextView, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(cell.bottomButton, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
    
    ColoredVKCard *card = self.cards[indexPath.row];
    cell.headerLabel.text = card.title;
    cell.headerLabel.textColor = card.titleColor;
    cell.headerDetailLabel.text = card.detailTitle;
    cell.headerDetailLabel.tintColor = card.detailTitleColor;
    cell.bodyTextView.attributedText = card.attributedBody;
    
    cell.bottomButton.layer.borderColor = card.buttonTintColor.CGColor;
    [cell.bottomButton setTitle:card.buttonText forState:UIControlStateNormal];
    [cell.bottomButton setTitleColor:card.buttonTintColor forState:UIControlStateNormal];
    [cell.bottomButton addTarget:card.buttonTarget action:card.buttonAction forControlEvents:UIControlEventTouchUpInside];
    
    cell.backgroundImageView.image = card.backgroundImage;
    cell.backgroundImageView.alpha = card.backgroundImageAlpha;
    cell.backgroundColor = card.backgroundColor;
    
    
    return cell;
}

@end
