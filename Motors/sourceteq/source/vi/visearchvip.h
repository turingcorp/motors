#import "appdel.h"

@class visearchman;
@class moditemlocation;
@class moditempictures;
@class moditempicture;
@class moditemattribute;
@class moditemcontact;
@class modsearchresult;

@interface visearchvip:UICollectionViewCell<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

-(visearchvip*)initWithFrame:(CGRect)_rect pictures:(moditempictures*)_pictures;
-(void)selectpicture:(NSInteger)_index;

@property(weak, nonatomic)moditempictures *pictures;
@property(weak, nonatomic)UICollectionView *collection;

@end

@interface visearchvipcel:UICollectionViewCell

-(void)config:(moditempicture*)_picture;

@property(weak, nonatomic)moditempicture *picture;
@property(weak, nonatomic)UIView *indicator;
@property(weak, nonatomic)UIImageView *image;

@end

@interface visearchvipactions:UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

-(visearchvipactions*)initWithFrame:(CGRect)_rect man:(visearchman*)_man;

@property(weak, nonatomic)visearchman *searchman;
@property(weak, nonatomic)modsearchresult *result;
@property(weak, nonatomic)UICollectionView *collection;

@end

@interface visearchvipactionscel:UICollectionViewCell

-(void)actionback;
-(void)actionlike:(BOOL)_liked;
-(void)actiontrash;
-(void)actioncontactcall;
-(void)actioncontactemail;
-(void)actionchat;

@property(weak, nonatomic)UIImageView *image;

@end

@interface visearchvipbasic:UIView

-(visearchvipbasic*)initWithFrame:(CGRect)_rect result:(modsearchresult*)_result;

@end

@interface visearchviplocation:UIView<MKMapViewDelegate, CLLocationManagerDelegate>

-(visearchviplocation*)initWithFrame:(CGRect)_rect location:(moditemlocation*)_location title:(NSString*)_title;

@property(weak, nonatomic)moditemlocation *itemlocation;
@property(weak, nonatomic)MKMapView *mapview;
@property(nonatomic)CLLocationCoordinate2D userlocation;

@end

@interface visearchvipattribute:UIView

-(visearchvipattribute*)initWithFrame:(CGRect)_rect attribute:(moditemattribute*)_attr;

@property(weak, nonatomic)moditemattribute *attr;

@end

@interface visearchvipcontact:UIView

-(visearchvipcontact*)initWithFrame:(CGRect)_rect contact:(moditemcontact*)_contact;

@property(weak, nonatomic)moditemcontact *contact;

@end

@interface visearchvipempty:UIView

@end