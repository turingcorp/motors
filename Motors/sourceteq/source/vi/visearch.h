#import "appdel.h"

@class visearchman;
@class visearchcel;
@class modsearch;
@class modsearchresult;

@interface visearch:UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

-(visearch*)initWithFrame:(CGRect)_rect man:(visearchman*)_man;

@property(weak, nonatomic)visearchman *searchman;
@property(weak, nonatomic)visearchcel *celpanning;
@property(weak, nonatomic)UICollectionView *collection;
@property(weak, nonatomic)UIPanGestureRecognizer *pan;

@end

@interface visearchheader:UICollectionReusableView

-(void)config:(visearchman*)_man;

@property(weak, nonatomic)visearchman *searchman;

@end

@interface visearchfooter:UICollectionReusableView

-(void)config:(visearchman*)_man;

@property(weak, nonatomic)visearchman *searchman;

@end

@interface visearchcel:UICollectionViewCell<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

-(void)config:(modsearchresult*)_result man:(visearchman*)_man;
-(void)swipeleft;
-(void)swiperight;
-(void)unswipe:(BOOL)_animated;
-(void)partlyswipe:(CGFloat)_xpos;

@property(weak, nonatomic)visearchman *searchman;
@property(weak, nonatomic)modsearchresult *result;
@property(weak, nonatomic)UIView *baselbl;
@property(weak, nonatomic)UILabel *lbl;
@property(weak, nonatomic)UICollectionView *collection;
@property(nonatomic)BOOL swiped;

@end

@interface visearchcelaction:UICollectionViewCell

-(void)actiontrash:(BOOL)_trashed;
-(void)actionlike:(BOOL)_liked;
-(void)actiondetail;

@property(weak, nonatomic)UIImageView *image;

@end