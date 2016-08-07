#import "PSControlTableCell.h"

@class UIActivityIndicatorView;

@interface PSSwitchTableCell : PSControlTableCell  {
    UIActivityIndicatorView *_activityIndicator;
}

@property BOOL loading;

- (BOOL)loading;
- (void)setLoading:(BOOL)loading;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) id controlValue;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) id newControl;
- (void)setCellEnabled:(BOOL)enabled;
- (void)refreshCellContentsWithSpecifier:(id)specifier;
- (instancetype)initWithStyle:(int)style reuseIdentifier:(id)identifier specifier:(id)specifier;
- (void)reloadWithSpecifier:(id)specifier animated:(BOOL)animated;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL canReload;
- (void)prepareForReuse;
- (void)layoutSubviews;
- (void)setValue:(id)value;

@end
