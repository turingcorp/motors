#import "appdel.h"

@class modinitem;
@class moditem;
@class moditemcontact;
@class moditemattribute;
@class moditempictures;
@class visearchmanheader;
@class spinner;

@interface viitemdetail:UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

+(void)show:(modinitem*)_item;
-(void)close;

@property(weak, nonatomic)modinitem *item;
@property(weak, nonatomic)moditem *deepitem;
@property(weak, nonatomic)UICollectionView *collection;

@end

@interface viitemdetailheader:UICollectionReusableView

@end

@interface viitemdetailfooter:UICollectionReusableView

-(void)config:(viitemdetail*)_detail;

@property(weak, nonatomic)viitemdetail *detail;

@end

@interface viitemdetailcel:UICollectionViewCell

-(void)loadimages:(moditempictures*)_pictures;
-(void)loadbasic:(modsearchresult*)_result;
-(void)loadcontact:(moditemcontact*)_contact;
-(void)loadlocation:(moditemlocation*)_location title:(NSString*)_title;
-(void)loadattribute:(moditemattribute*)_attribute;
-(void)loadempty;

@property(weak, nonatomic)UIView *inview;

@end