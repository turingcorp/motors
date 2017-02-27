#import "appdel.h"

@class modsearch;
@class moditempicture;
@class moditemattributes;

@interface visearchman:UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

-(void)changesearchstate:(appsearchstate)_newsearchstate;
-(void)trashresult:(modsearchresult*)_result;

@property(strong, nonatomic)modsearch *search;
@property(weak, nonatomic)UICollectionView *collection;
@property(weak, nonatomic)UIImageView *gradient;
@property(nonatomic)appsearchstate searchstate;

@end

@interface visearchmanheader:UICollectionReusableView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

-(void)config:(visearchman*)_searchman;

@property(weak, nonatomic)visearchman *searchman;
@property(weak, nonatomic)modsearchresult *searchresult;
@property(weak, nonatomic)moditempicture *picture;
@property(weak, nonatomic)UICollectionView *collection;
@property(weak, nonatomic)UIImageView *image;
@property(weak, nonatomic)UIImageView *gradient;

@end

@interface visearchmanheaderaction:UICollectionViewCell

-(void)actiondetail;
-(void)actionlike:(BOOL)_liked;

@property(weak, nonatomic)UIImageView *image;

@end

@interface visearchmanfooter:UICollectionReusableView

@end

@interface visearchmancel:UICollectionViewCell

-(void)config:(visearchman*)_searchman index:(NSInteger)_index;

@property(weak, nonatomic)visearchman *searchman;
@property(weak, nonatomic)moditemattributes *attributes;
@property(weak, nonatomic)UIView *innerview;

@end