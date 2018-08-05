//
//  ColoredVKSwiftMenuCollectionView.m
//  ColoredVK2
//
//  Created by Даниил on 04/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "ColoredVKSwiftMenuCollectionView.h"

@implementation ColoredVKSwiftMenuCollectionView\

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(76.0f, 76.0f);
    layout.sectionInset = UIEdgeInsetsMake(30.0f, 30.0f, 5.0f, 30.0f);
    layout.minimumLineSpacing = 20.0f;
    
    self = [super initWithFrame:CGRectZero collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.panGestureRecognizer.enabled = NO;
        self.scrollEnabled = NO;
        self.allowsMultipleSelection = YES;
    }
    
    return self;
}

- (void)_selectAllSelectedItems
{
    return;
}

@end
