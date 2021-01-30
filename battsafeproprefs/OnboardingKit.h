@interface OBBulletedListItem : UIView
@property (nonatomic,retain) UIView * imageContainer;
@property (nonatomic,retain) UIImageView * imageView;
@property (nonatomic,retain) UIStackView * stackView;
@property (nonatomic,retain) UILabel * titleLabel;
@property (nonatomic,retain) UILabel * descriptionLabel;
@property (nonatomic,retain) NSLayoutConstraint * stackViewLeadingConstraintVertical;
@property (nonatomic,retain) NSLayoutConstraint * stackViewLeadingConstraintHorizontal;
-(id)_textStyle;
-(UILabel *)titleLabel;
-(void)traitCollectionDidChange:(id)arg1 ;
-(UIImageView *)imageView;
-(UIStackView *)stackView;
-(void)setTitleLabel:(UILabel *)arg1 ;
-(void)setDescriptionLabel:(UILabel *)arg1 ;
-(UILabel *)descriptionLabel;
-(void)setImageView:(UIImageView *)arg1 ;
-(void)setStackView:(UIStackView *)arg1 ;
-(id)initWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3 ;
-(double)imageSizeForImage:(id)arg1 ;
-(BOOL)shouldLayoutVertically;
-(double)leadingMargins;
-(double)trailingMargins;
-(UIView *)imageContainer;
-(void)_updateImageViewLayout;
-(double)_horizontalMargins;
-(NSLayoutConstraint *)stackViewLeadingConstraintVertical;
-(void)setStackViewLeadingConstraintVertical:(NSLayoutConstraint *)arg1 ;
-(NSLayoutConstraint *)stackViewLeadingConstraintHorizontal;
-(void)setStackViewLeadingConstraintHorizontal:(NSLayoutConstraint *)arg1 ;
-(void)setImageContainer:(UIView *)arg1 ;
@end

@interface OBBulletedList : UIView
@property (nonatomic,retain) NSMutableArray <OBBulletedListItem *>* items;
@property (nonatomic,retain) NSMutableArray * verticalConstraints;
-(NSMutableArray  <OBBulletedListItem *>*)items;
-(void)setItems:(NSMutableArray <OBBulletedListItem *>*)arg1 ;
-(id)initWithFrame:(CGRect)arg1 ;
-(void)_updateConstraints;
-(NSMutableArray *)verticalConstraints;
-(void)setVerticalConstraints:(NSMutableArray *)arg1 ;
-(void)addItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3 ;
-(void)addItemWithDescription:(id)arg1 image:(id)arg2 ;
-(void)addBulletedListItem:(id)arg1 ;
-(double)bulletedListItemSpacing;
@end

@interface OBTemplateLabel : UILabel
@end

@interface OBPrivacyLinkController : UIViewController
@end

@interface OBButtonTrayLayoutGuide : UILayoutGuide
@end

@interface OBButtonTray : UIView
@property (assign,nonatomic) UIViewController * parentViewController;
@property (nonatomic,retain) NSMutableArray * buttons;
@property (nonatomic,retain) OBButtonTrayLayoutGuide * buttonLayoutGuide;
@property (nonatomic,retain) OBPrivacyLinkController * privacyLinkController;
@property (nonatomic,retain) OBTemplateLabel * captionLabel;
@property (nonatomic,retain) UIStackView * stackView;
@property (nonatomic,retain) UIView * backdropContainer;
@property (nonatomic,retain) UIVisualEffectView * effectView;
@property (nonatomic,retain) NSLayoutConstraint * stackViewTopConstraint;
@property (nonatomic,retain) NSLayoutConstraint * stackViewBottomConstraint;
@property (nonatomic,retain) NSLayoutConstraint * stackViewLeadingConstraint;
@property (nonatomic,retain) NSLayoutConstraint * stackViewTrailingConstraint;
@property (assign,nonatomic) long long backdropStyle;
- (void)addButton:(id)arg1;
- (void)addCaptionText:(id)arg1;;
@end

@interface OBBoldTrayButton : UIButton
-(void)setTitle:(id)arg1 forState:(unsigned long long)arg2;
+(id)buttonWithType:(long long)arg1;
@end

@interface OBWelcomeController : UIViewController
@property (nonatomic,retain) OBBulletedList * bulletedList;
- (OBButtonTray *)buttonTray;
- (id)initWithTitle:(id)arg1 detailText:(id)arg2 icon:(id)arg3;
- (void)addBulletedListItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3;
@end
