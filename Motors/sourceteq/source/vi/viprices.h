#import "appdel.h"

@class vipricesheader;
@class vipricesnotavailable;
@class modprices;
@class modprice;
@class modpricereport;
@class spinner;

@interface viprices:UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(weak, nonatomic)vipricesheader *header;
@property(weak, nonatomic)vipricesnotavailable *notavailable;
@property(strong, nonatomic)modprices *prices;
@property(weak, nonatomic)UICollectionView *collection;

@end

@interface vipricesheader:UIView

-(vipricesheader*)initWithFrame:(CGRect)_rect viprices:(viprices*)_viprices;
-(void)refresh;

@property(weak, nonatomic)viprices *prices;
@property(weak, nonatomic)UILabel *lbl;

@end

@interface vipricesreheader:UICollectionReusableView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

-(void)configprice:(modpricereport*)_pricereport;
-(void)configload;

@property(weak, nonatomic)modpricereport *report;
@property(weak, nonatomic)spinner *spin;
@property(weak, nonatomic)UICollectionView *collection;

@end

@interface vipricesreheaderfooter:UICollectionReusableView

@end

@interface vipricesreheadercel:UICollectionViewCell

-(void)config:(BOOL)_max amount:(double)_amount;

@property(weak, nonatomic)UIImageView *icon;
@property(weak, nonatomic)UILabel *lbl;

@end

@interface vipricesrefooter:UICollectionReusableView

-(void)showerror:(NSString*)_error;
-(void)noerror;

@property(weak, nonatomic)UIView *view;

@end

@interface vipricescel:UICollectionViewCell

-(void)config:(modprice*)_price;

@property(weak, nonatomic)UILabel *lbl;

@end

@interface vipricesnotavailable:UIView

@end