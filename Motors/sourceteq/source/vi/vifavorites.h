#import "appdel.h"

@class modinitem;

@interface vifavorites:UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(weak, nonatomic)UICollectionView *collection;

@end

@interface vifavoritesheader:UICollectionReusableView

@end

@interface vifavoritescel:UICollectionViewCell

-(void)config:(modinitem*)_initem;

@property(weak, nonatomic)UIImageView *image;
@property(weak, nonatomic)UILabel *lbl;

@end

@interface vifavoritesmenu:UIView<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(weak, nonatomic)UICollectionView *collection;
@property(nonatomic)NSInteger selected;

@end

@interface vifavoritesmenucel:UICollectionViewCell

-(void)config:(NSInteger)_index;

@property(weak, nonatomic)UIImageView *image;
@property(weak, nonatomic)UIView *border;

@end