#import "appdel.h"

@class vicountriesimage;
@class modsite;

@interface vicountries:UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

-(vicountries*)initWithFrame:(CGRect)_rect;

@property(weak, nonatomic)UICollectionView *collection;
@property(weak, nonatomic)UILabel *lbl;

@end

@interface vicountriescel:UICollectionViewCell

-(void)config:(modsite*)_site;

@property(weak, nonatomic)vicountriesimage *image;

@end

@interface vicountriesimage:UIView

-(vicountriesimage*)initWithFrame:(CGRect)_rect triangle:(BOOL)_triangle site:(modsite*)_site;
-(void)hover:(BOOL)_selected;

@end

@interface vicountryshower:UIView

+(void)showcurrent;

@property(weak, nonatomic)UIImageView *flag;
@property(weak, nonatomic)UILabel *title;

@end