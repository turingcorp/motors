#import "appdel.h"

@class vifiltervisor;
@class vifilterbarfield;
@class modfilters;
@class modfilter;
@class modfilterelement;

@interface vifilter:UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

+(void)show:(modfilters*)_filters;
-(void)close;

@property(weak, nonatomic)vifiltervisor *visor;
@property(weak, nonatomic)modfilters *filters;
@property(weak, nonatomic)UICollectionView *collection;
@property(nonatomic)BOOL changed;

@end

@interface vifilterheader:UICollectionReusableView

-(void)config:(modfilter*)_filter;

@property(weak, nonatomic)UILabel *lbl;

@end

@interface vifilterfooter:UICollectionReusableView

@end

@interface vifiltercel:UICollectionViewCell

-(void)config:(modfilterelement*)_element;
-(void)configtitle:(NSString*)_title;

@property(weak, nonatomic)UILabel *lbl;

@end

@interface vifiltercelpicker:UICollectionViewCell<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

-(void)config:(vifilter*)_main filter:(modfilter*)_filter;

@property(weak, nonatomic)vifilter *main;
@property(weak, nonatomic)modfilter *filter;
@property(weak, nonatomic)UICollectionView *collection;

@end

@interface vifiltercelpickercel:UICollectionViewCell

-(void)config:(modfilterelement*)_element;
-(void)configtitle:(NSString*)_title;

@property(weak, nonatomic)UILabel *lbl;

@end

@interface vifiltervisor:UIView

-(vifiltervisor*)init:(vifilter*)_filter;

@property(weak, nonatomic)vifilter *filter;

@end

@interface vifilterbar:UIView<UITextFieldDelegate>

@property(weak, nonatomic)vifilterbarfield *barfield;
@property(weak, nonatomic)modfilters *filters;
@property(weak, nonatomic)UIButton *btnquery;
@property(weak, nonatomic)UIButton *btnfilter;

@end

@interface vifilterbarfield:UIView

-(void)show;
-(void)hide;

@property(weak, nonatomic)UITextField *field;

@end