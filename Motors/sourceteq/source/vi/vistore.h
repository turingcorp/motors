#import "appdel.h"

@class vistorevisor;
@class modperkelement;
@class spinner;

@interface vistore:UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(weak, nonatomic)vistorevisor *visor;
@property(weak, nonatomic)spinner *spin;
@property(weak, nonatomic)UICollectionView *collection;
@property(weak, nonatomic)UILabel *lbl;

@end

@protocol vistoreperk <NSObject>

-(void)config:(modperkelement*)_perkelement;

@end

@interface vistorevisor:UIView

@end

@interface vistoreheader:UICollectionReusableView<vistoreperk>

@property(weak, nonatomic)UILabel *lbl;

@end

@interface vistorefooter:UICollectionReusableView<vistoreperk>

@property(weak, nonatomic)modperkelement *element;
@property(weak, nonatomic)spinner *spin;
@property(weak, nonatomic)UILabel *lbl;
@property(weak, nonatomic)UILabel *lblpurchased;
@property(weak, nonatomic)UIButton *btnpurchase;

@end

@interface vistorecel:UICollectionViewCell<vistoreperk>

@property(weak, nonatomic)UILabel *lbl;

@end