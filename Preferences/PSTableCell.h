@class PSSpecifier;

typedef NS_ENUM(NSInteger, PSCellType) {
    PSStaticTextCell =  -1,
	PSGroupCell,
	PSLinkCell =        1 << 0,
	PSLinkListCell =    1 << 1,
	PSListItemCell =    3,
	PSTitleValueCell =  1 << 2,
	PSSliderCell =      5,
	PSSwitchCell =      6,
	PSEditTextCell =    1 << 3,
	PSSegmentCell =     9,
	PSGiantIconCell =   10,
	PSGiantCell =       11,
	PSSecureEditTextCell = 12,
	PSButtonCell =      13,
	PSEditTextViewCell = 14
};

@interface PSTableCell : UITableViewCell

+ (PSCellType)cellTypeFromString:(NSString *)cellType;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier;

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)style;

@property (nonatomic, retain) PSSpecifier *specifier;
@property (nonatomic) PSCellType type;
@property (nonatomic, retain) id cellTarget;
@property (nonatomic) SEL cellAction;

@property (nonatomic) BOOL cellEnabled;

@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, getter=getLazyIcon, readonly, strong) UIImage *lazyIcon;
@property (nonatomic, retain, readonly) UIImage *blankIcon;
@property (nonatomic, retain, readonly) NSString *lazyIconAppID;

@property (nonatomic, retain, readonly) UILabel *titleLabel;

@end
