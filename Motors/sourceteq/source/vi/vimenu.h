#import "appdel.h"

@interface vimenu:UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

-(void)opensection:(appsection)_section;

@property(weak, nonatomic)UICollectionView *collection;

@end

@interface vimenucel:UICollectionViewCell

-(void)config:(appsection)_section;

@property(weak, nonatomic)UIView *indicator;
@property(weak, nonatomic)UIImageView *icon;
@property(weak, nonatomic)UILabel *lbl;
@property(nonatomic)appsection section;

@end