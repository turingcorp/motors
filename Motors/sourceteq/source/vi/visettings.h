#import "appdel.h"

@interface visettings:UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property(weak, nonatomic)UICollectionView *collection;

@end

@interface visettingscel:UICollectionViewCell

-(void)config:(NSInteger)_index;

@property(strong, nonatomic)UIView *view;

@end