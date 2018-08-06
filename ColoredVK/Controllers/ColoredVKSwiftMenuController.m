//
//  ColoredVKSwiftMenuController.m
//  ColoredVK2
//
//  Created by Даниил on 03/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "ColoredVKSwiftMenuController.h"
#import <objc/runtime.h>
#import "ColoredVKDragDownAnimator.h"

#import "ColoredVKChevronView.h"
#import "ColoredVKSwiftMenuCell.h"
#import "ColoredVKSwiftMenuButton.h"
#import "ColoredVKSwiftMenuFooterView.h"
#import "ColoredVKSwiftMenuCollectionView.h"


@interface ColoredVKSwiftMenuController () <UIViewControllerPreviewingDelegate, ColoredVKDragDownAnimatorDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (strong, nonatomic) ColoredVKDragDownAnimator *dragDownAnimator;

@property (weak, nonatomic) UIVisualEffectView *blurView;
@property (weak, nonatomic) UIVisualEffectView *headerVibrancyView;
@property (weak, nonatomic) ColoredVKChevronView *chevron;
@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) UILabel *headerLabel;

@property (assign, nonatomic) BOOL headerLabelAnimating;
@property (assign, nonatomic) BOOL presented;

@property (weak, nonatomic) UIViewController *parentController;
@end

@implementation ColoredVKSwiftMenuController

+ (nullable instancetype)menuControllerForController:(UIViewController *)viewController
{
    id menuController = objc_getAssociatedObject(viewController, "cvk_swiftMenu");
    return [menuController isKindOfClass:[ColoredVKSwiftMenuController class]] ? menuController : nil;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (instancetype)initWithViewController:(UIViewController *)viewController andView:(UIView *)view
{
    return [self initWithParentViewController:nil];
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithParentViewController:nil];
}
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithParentViewController:nil];
}

- (instancetype)initWithParentViewController:(UIViewController * _Nullable)parentViewController
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.parentController = parentViewController;
        self.itemsGroups = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.dragDownAnimator = [[ColoredVKDragDownAnimator alloc] initWithViewController:self];
    self.dragDownAnimator.delegate = self;
    self.dragDownAnimator.maxPercentThreshold = 0.2f;
    [self.view addGestureRecognizer:self.dragDownAnimator.dragDownGestureRecognizer];
    
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
    blurView.frame = [UIScreen mainScreen].bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:blurView atIndex:0];
    self.blurView = blurView;
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [blurView.contentView addSubview:vibrancyView];
    self.headerVibrancyView = vibrancyView;
    
    ColoredVKChevronView *chevron = [ColoredVKChevronView new];
    chevron.state = ColoredVKChevronViewStateClosed;
    chevron.tintColor = [UIColor lightGrayColor];
    [self.headerVibrancyView.contentView addSubview:chevron];
    self.chevron = chevron;
    
    
    UILabel *headerLabel = [UILabel new];
    headerLabel.alpha = 0.0f;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [self.blurView.contentView addSubview:headerLabel];
    self.headerLabel = headerLabel;
    
    ColoredVKSwiftMenuCollectionView *collectionView = [[ColoredVKSwiftMenuCollectionView alloc] init];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    collectionViewLayout.footerReferenceSize = CGSizeMake(CGRectGetWidth(self.view.frame), 44.0f);
    
    [self invertView:collectionView];
    [self.blurView.contentView addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView registerClass:[ColoredVKSwiftMenuCell class] forCellWithReuseIdentifier:@"Cell"];
    [collectionView registerClass:[ColoredVKSwiftMenuFooterView class] 
       forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    [self setupConstraints];
}

- (void)setupConstraints
{
    self.headerVibrancyView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerVibrancyView.leadingAnchor constraintEqualToAnchor:self.headerVibrancyView.superview.leadingAnchor].active = YES;
    [self.headerVibrancyView.trailingAnchor constraintEqualToAnchor:self.headerVibrancyView.superview.trailingAnchor].active = YES;
    [self.headerVibrancyView.topAnchor constraintEqualToAnchor:self.headerVibrancyView.superview.topAnchor constant:28.0f].active = YES;
    [self.headerVibrancyView.heightAnchor constraintEqualToConstant:44.0f].active = YES;
    
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerLabel.leadingAnchor constraintEqualToAnchor:self.headerLabel.superview.leadingAnchor].active = YES;
    [self.headerLabel.trailingAnchor constraintEqualToAnchor:self.headerLabel.superview.trailingAnchor].active = YES;
    [self.headerLabel.topAnchor constraintEqualToAnchor:self.headerLabel.superview.topAnchor constant:28.0f].active = YES;
    [self.headerLabel.heightAnchor constraintEqualToConstant:44.0f].active = YES;
    
    self.chevron.translatesAutoresizingMaskIntoConstraints = NO;
    [self.chevron.centerXAnchor constraintEqualToAnchor:self.chevron.superview.centerXAnchor].active = YES;
    [self.chevron.centerYAnchor constraintEqualToAnchor:self.chevron.superview.centerYAnchor].active = YES;
    [self.chevron.widthAnchor constraintEqualToConstant:CGRectGetWidth(self.chevron.frame)].active = YES;
    [self.chevron.heightAnchor constraintEqualToConstant:CGRectGetHeight(self.chevron.frame)].active = YES;
    
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.collectionView.topAnchor constraintEqualToAnchor:self.collectionView.superview.topAnchor].active = YES;
    [self.collectionView.bottomAnchor constraintEqualToAnchor:self.collectionView.superview.bottomAnchor].active = YES;
    [self.collectionView.leadingAnchor constraintEqualToAnchor:self.collectionView.superview.leadingAnchor].active = YES;
    [self.collectionView.trailingAnchor constraintEqualToAnchor:self.collectionView.superview.trailingAnchor].active = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.chevron setState:ColoredVKChevronViewStateOpened animated:YES];
}


- (void)present
{
    if (self.presented)
        return;
    
    self.presented = YES;
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (viewController.presentedViewController)
        viewController = viewController.presentedViewController;
    
    [viewController presentViewController:self animated:YES completion:nil];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)registerForceTouchForView:(UIView *)sourceView
{
    if (self.parentController.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self.parentController registerForPreviewingWithDelegate:self sourceView:sourceView];
    }
    
    objc_setAssociatedObject(self.parentController, "cvk_swiftMenu", self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)registerLongPressForView:(UIView *)view
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(present)];
    longPress.minimumPressDuration = 0.2f;
    longPress.numberOfTapsRequired = 1;
    longPress.delaysTouchesEnded = NO;
    [view addGestureRecognizer:longPress];
    
    objc_setAssociatedObject(self.parentController, "cvk_swiftMenu", self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateRecognized) {
        [self present];
    }
}

- (void)setItemsGroups:(NSMutableArray<ColoredVKSwiftMenuItemsGroup *> *)itemsGroups
{
    if (!itemsGroups)
        itemsGroups = [NSMutableArray array];
    
    _itemsGroups = itemsGroups;
}

- (void)invertView:(UIView *)view
{
    view.transform = CGAffineTransformScale(view.transform, 1, -1);
}

- (void)handleSelectForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ColoredVKSwiftMenuItemsGroup *group = self.itemsGroups[indexPath.section];
    ColoredVKSwiftMenuButton *button = group.buttons[indexPath.row];
    button.selected = !button.selected;
    
    self.headerLabel.text = button.selected ? button.selectedTitle : button.unselectedTitle;
    if (self.headerLabel.text.length > 0 && !self.headerLabelAnimating) {
        self.headerLabelAnimating = YES;
        [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.chevron.hidden = YES;
            self.headerLabel.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.6f delay:2.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.headerLabel.alpha = 0.0f;
            } completion:^(BOOL finishedTwo) {
                self.chevron.hidden = NO;
                self.headerLabelAnimating = NO;
            }];
        }];
    }
    
    
    if (button.selectHandler) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            button.selectHandler(button);
        });
    }
}


#pragma mark - ColoredVKDragDownAnimatorDelegate

- (void)animator:(ColoredVKDragDownAnimator *)animator didRecognizeDragGesture:(UIPanGestureRecognizer *)panGesture
{
    const CGFloat progress = [animator progressForPanGesture:panGesture];
    [self.chevron setState:(progress > animator.maxPercentThreshold) animated:YES];
}

- (void)animatorFinishedAnimatingDismiss:(ColoredVKDragDownAnimator *)animator
{
    self.view = nil;
    self.presented = NO;
}


#pragma mark - UIViewControllerPreviewingDelegate

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    return self;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self present];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.itemsGroups.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ColoredVKSwiftMenuItemsGroup *group = self.itemsGroups[section];
    return group.buttons.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ColoredVKSwiftMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [self invertView:cell];
    
    ColoredVKSwiftMenuItemsGroup *group = self.itemsGroups[indexPath.section];
    cell.buttonModel = group.buttons[indexPath.row];
    cell.collectionView = collectionView;
    
    if (cell.buttonModel.selected) {
        [cell setSelected:YES animated:NO];
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind 
                                 atIndexPath:(NSIndexPath *)indexPath
{
    ColoredVKSwiftMenuFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                  withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
    [self invertView:footerView];
    
    ColoredVKSwiftMenuItemsGroup *group = self.itemsGroups[indexPath.section];
    footerView.titleLabel.text = group.name;
    
    return footerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self handleSelectForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self handleSelectForItemAtIndexPath:indexPath];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewFlowLayout *)collectionViewLayout 
        insetForSectionAtIndex:(NSInteger)section
{
    ColoredVKSwiftMenuItemsGroup *group = self.itemsGroups[section];
    CGFloat totalCellWidth = group.buttons.count * collectionViewLayout.itemSize.width;
    CGFloat totalSpacingWidth = 20.0f * (group.buttons.count - 1);
    
    CGFloat inset = (CGRectGetWidth(collectionView.frame) - totalCellWidth - totalSpacingWidth) - 30.0f;
    
    return UIEdgeInsetsMake(30.0f, 30.0f, 5.0f, MAX(30.0f, inset));
}

@end
