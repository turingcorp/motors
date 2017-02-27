#import "visearchvip.h"

@implementation visearchvip
{
    NSInteger height_2;
    BOOL trackscroll;
}

@synthesize pictures;
@synthesize collection;

-(visearchvip*)initWithFrame:(CGRect)_rect pictures:(moditempictures*)_pictures
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor blackColor]];
    
    trackscroll = NO;
    pictures = _pictures;
    NSInteger height = _rect.size.height;
    height_2 = height / 2;
    NSInteger imageheight = height - 4;
    NSInteger imagewidth = imageheight * 3.0 / 2;
    NSInteger imagewidth_2 = imagewidth / 2;
    NSInteger margin = screenwidth_2 - imagewidth_2;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setFooterReferenceSize:CGSizeZero];
    [flow setHeaderReferenceSize:CGSizeZero];
    [flow setItemSize:CGSizeMake(imagewidth, imageheight)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:2];
    [flow setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flow setSectionInset:UIEdgeInsetsMake(2, margin, 2, margin)];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection = strongcollection;
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setClipsToBounds:YES];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setAlwaysBounceHorizontal:YES];
    [collection setDelegate:self];
    [collection setDataSource:self];
    [collection registerClass:[visearchvipcel class] forCellWithReuseIdentifier:celid];
    
    [self addSubview:collection];
    
    if([pictures count])
    {
        [collection selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    }
    
    return self;
}

#pragma mark functionality

-(void)innerselectimage:(NSInteger)_index
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notchangeheaderpic object:nil userInfo:[[pictures picture:_index] userinfo]];
}

-(void)selectnear
{
    CGFloat leftoffset = collection.contentOffset.x;
    CGPoint point = CGPointMake(leftoffset + screenwidth_2, height_2);
    NSIndexPath *index = [collection indexPathForItemAtPoint:point];
    
    if(index)
    {
        [self innerselectimage:index.item];
        [collection selectItemAtIndexPath:index animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

#pragma mark public

-(void)selectpicture:(NSInteger)_index
{
    [self innerselectimage:_index];
    trackscroll = NO;
    [collection selectItemAtIndexPath:[NSIndexPath indexPathForItem:_index inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
}

#pragma mark -
#pragma mark scroll del

-(void)scrollViewWillBeginDragging:(UIScrollView*)_drag
{
    trackscroll = YES;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView*)_scroll
{
    trackscroll = NO;
}

-(void)scrollViewDidScroll:(UIScrollView*)_scroll
{
    if(trackscroll)
    {
        [self selectnear];
    }
}

#pragma mark col del

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    return [pictures count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    visearchvipcel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    [cel config:[pictures picture:_index.item]];
    
    return cel;
}

-(void)collectionView:(UICollectionView*)_col didSelectItemAtIndexPath:(NSIndexPath*)_index
{
    [collection scrollToItemAtIndexPath:_index atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self innerselectimage:_index.item];
    trackscroll = NO;
}

@end

@implementation visearchvipcel

@synthesize picture;
@synthesize indicator;
@synthesize image;

-(visearchvipcel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
 
    UIImageView *strongimage = [[UIImageView alloc] initWithFrame:self.bounds];
    image = strongimage;
    [image setClipsToBounds:YES];
    [image setUserInteractionEnabled:NO];
    [image setContentMode:UIViewContentModeScaleAspectFill];
    
    UIView *strongindicator = [[UIView alloc] initWithFrame:CGRectMake(0, _rect.size.height - 7, _rect.size.width, 7)];
    indicator = strongindicator;
    [indicator setBackgroundColor:[colormain colorWithAlphaComponent:0.7]];
    [indicator setUserInteractionEnabled:NO];
    
    [self addSubview:image];
    [self addSubview:indicator];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedimageready:) name:notimageready object:nil];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setSelected:(BOOL)_selected
{
    [super setSelected:_selected];
    [self hover];
}

-(void)setHighlighted:(BOOL)_highlighted
{
    [super setHighlighted:_highlighted];
    [self hover];
}

#pragma mark notified

-(void)notifiedimageready:(NSNotification*)_notification
{
    if([picture equalsuserinfo:_notification.userInfo])
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^(void)
                       {
                           [self configimage];
                       });
    }
}


#pragma mark functionality

-(void)hover
{
    if(self.isSelected || self.isHighlighted)
    {
        [image setAlpha:1];
        [indicator setHidden:NO];
    }
    else
    {
        [image setAlpha:0.6];
        [indicator setHidden:YES];
    }
}

-(void)configimage
{
    [image setImage:picture.image];
}

#pragma mark public

-(void)config:(moditempicture*)_picture
{
    picture = _picture;
    [self configimage];
    [self hover];
}

@end

@implementation visearchvipactions

@synthesize searchman;
@synthesize result;
@synthesize collection;

-(visearchvipactions*)initWithFrame:(CGRect)_rect man:(visearchman*)_man
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    searchman = _man;
    result = searchman.search.resultselected;
    NSInteger height = _rect.size.height;
    NSInteger itemwidth = screenwidth / 5;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setFooterReferenceSize:CGSizeZero];
    [flow setHeaderReferenceSize:CGSizeZero];
    [flow setItemSize:CGSizeMake(itemwidth, height)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:0];
    [flow setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flow setSectionInset:UIEdgeInsetsZero];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection = strongcollection;
    [collection setClipsToBounds:YES];
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setScrollEnabled:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setBounces:NO];
    [collection setDataSource:self];
    [collection setDelegate:self];
    [collection registerClass:[visearchvipactionscel class] forCellWithReuseIdentifier:celid];
    
    [self addSubview:collection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedupdatedstatus:) name:notupdatestatus object:nil];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark notified

-(void)notifiedupdatedstatus:(NSNotification*)_notification
{
    if([result equalsuserinfo:_notification.userInfo])
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^(void)
                       {
                           [collection reloadData];
                       });
    }
}

#pragma mark functionality

-(void)notifystatusupdated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notupdatestatus object:nil userInfo:[result userinfo]];
}

#pragma mark -
#pragma mark col del

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    return 5;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    NSInteger item = _index.item;
    
    visearchvipactionscel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    
    switch(item)
    {
        case 0:
            
            [cel actionback];
            
            break;
            
        case 1:
            
            [cel actiontrash];
            
            break;
            
        case 2:
            
            [cel actionlike:result.initem.status == statustypefavorite];
            
            break;
            
        case 3:
            
            [cel actionchat];
            
            break;
            
        case 4:
            
            if(result.item.contact.phone)
            {
                [cel actioncontactcall];
            }
            else if(result.item.contact.email)
            {
                [cel actioncontactemail];
            }
            
            break;
    }
    
    return cel;
}

-(void)collectionView:(UICollectionView*)_col didSelectItemAtIndexPath:(NSIndexPath*)_index
{
    switch(_index.item)
    {
        case 0:
            
            [searchman changesearchstate:appsearchstatelist];
            
            break;
            
        case 1:
            
            [searchman changesearchstate:appsearchstatelist];
            [searchman trashresult:result];
            
            break;
            
        case 2:
            
            if(result.initem.status != statustypefavorite)
            {
                [result.initem favorite];
            }
            else
            {
                [result.initem nostatus];
            }
            
            [self notifystatusupdated];
            
            break;
            
        case 3:
            
            break;
            
        case 4:
            
            if(result.item.contact.phone)
            {
                [result.item.contact call];
            }
            else if(result.item.contact.email)
            {
                [result.item.contact write];
            }
            
            break;
    }
}

@end

@implementation visearchvipactionscel
{
    UIColor *color;
}

@synthesize image;

-(visearchvipactionscel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    NSInteger imagesize = 32;
    
    UIImageView *strongimage = [[UIImageView alloc] initWithFrame:CGRectMake((_rect.size.width - imagesize) / 2, (_rect.size.height - imagesize) / 2, imagesize, imagesize)];
    image = strongimage;
    [image setUserInteractionEnabled:NO];
    [image setClipsToBounds:YES];
    [image setContentMode:UIViewContentModeScaleAspectFit];
    
    [self addSubview:image];
    
    return self;
}

-(void)setSelected:(BOOL)_selected
{
    [self hover];
}

-(void)setHighlighted:(BOOL)_highlighted
{
    [super setHighlighted:_highlighted];
    [self hover];
}

#pragma mark functionality

-(void)hover
{
    if(self.isSelected || self.isHighlighted)
    {
        [image setTintColor:[color colorWithAlphaComponent:0.1]];
    }
    else
    {
        [image setTintColor:color];
    }
}

#pragma mark public

-(void)actionback
{
    [image setImage:[[UIImage imageNamed:@"backlist"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    color = colorsecond;
    
    [self hover];
}

-(void)actionlike:(BOOL)_liked
{
    [image setImage:[[UIImage imageNamed:@"like"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    if(_liked)
    {
        color = colormain;
    }
    else
    {
        color = colorsecond;
    }
    
    [self hover];
}

-(void)actiontrash
{
    [image setImage:[[UIImage imageNamed:@"trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    color = colorsecond;
    
    [self hover];
}

-(void)actioncontactcall
{
    if(applicationtype == apptypephone)
    {
        [image setImage:[[UIImage imageNamed:@"phone"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    }
    
    color = colorsecond;
    
    [self hover];
}

-(void)actioncontactemail
{
    [image setImage:[[UIImage imageNamed:@"email"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    color = colorsecond;
    
    [self hover];
}

-(void)actionchat;
{
//    [image setImage:[[UIImage imageNamed:@"chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    [image setImage:nil];
    
    color = colorsecond;
    
    [self hover];
}

@end

@implementation visearchvipbasic
{
    NSDictionary *attrtitle;
    NSDictionary *attrprice;
}

-(visearchvipbasic*)initWithFrame:(CGRect)_rect result:(modsearchresult*)_result
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setUserInteractionEnabled:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lbl = [[UILabel alloc] init];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setNumberOfLines:0];
    [lbl setFont:[UIFont fontWithName:fontname size:20]];
    [lbl setTextColor:[UIColor blackColor]];
    [lbl setText:_result.title];
    
    [self addSubview:lbl];
    attrtitle = @{NSFontAttributeName:[UIFont fontWithName:fontname size:15], NSForegroundColorAttributeName:[UIColor colorWithWhite:0.4 alpha:1]};
    attrprice = @{NSFontAttributeName:[UIFont fontWithName:fontname size:23], NSForegroundColorAttributeName:colorsecond};
    
    NSString *strtitle;
    NSString *strprice;
    
    if(_result.item)
    {
        moditem *item = _result.item;
        
        strtitle = item.title;
        
        if([item.currencyid isEqualToString:@"USD"])
        {
            strprice = [[tools sha] pricetostringusd:item.price];
        }
        else
        {
            strprice = [[tools sha] pricetostring:item.price];
        }
    }
    else
    {
        strtitle = _result.title;
        strprice = _result.price;
    }
    
    NSMutableAttributedString *mut = [[NSMutableAttributedString alloc] init];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:strprice attributes:attrprice]];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attrtitle]];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:strtitle attributes:attrtitle]];
    [lbl setAttributedText:mut];
    
    NSInteger width = screenwidth - 20;
    NSInteger height = ceilf([mut boundingRectWithSize:CGSizeMake(width, 200) options:stringdrawing context:nil].size.height);
    [lbl setFrame:CGRectMake(10, 10, width, height)];
    
    return self;
}

@end

@implementation visearchviplocation
{
    modann *annotation;
    locman *locationmanager;
    NSMutableDictionary *mutaddress;
    NSString *annotationtitle;
    MKCoordinateSpan mapspan;
    BOOL updateinitial;
}

@synthesize itemlocation;
@synthesize mapview;
@synthesize userlocation;

-(visearchviplocation*)initWithFrame:(CGRect)_rect location:(moditemlocation*)_location title:(NSString*)_title
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    itemlocation = _location;
    annotationtitle = _title;
    mutaddress = [NSMutableDictionary dictionary];
    NSDictionary *attrgen = @{NSFontAttributeName:[UIFont fontWithName:fontname size:16], NSForegroundColorAttributeName:[UIColor colorWithWhite:0.3 alpha:1]};
    NSDictionary *attrcountry = @{NSFontAttributeName:[UIFont fontWithName:fontboldname size:12], NSForegroundColorAttributeName:[UIColor blackColor]};
    NSMutableAttributedString *mut = [[NSMutableAttributedString alloc] init];
    
    if(_location.addressline.length)
    {
        mutaddress[(NSString*)kABPersonAddressStreetKey] = _location.addressline;
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:_location.addressline attributes:attrgen]];
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@", " attributes:attrgen]];
    }
    
    if(_location.neightbourhood.length)
    {
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:_location.neightbourhood attributes:attrgen]];
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@", " attributes:attrgen]];
    }
    
    if(_location.city.length)
    {
        mutaddress[(NSString*)kABPersonAddressCityKey] = _location.city;
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:_location.city attributes:attrgen]];
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:attrgen]];
    }
    
    if(_location.zipcode.length)
    {
        mutaddress[(NSString*)kABPersonAddressZIPKey] = _location.zipcode;
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:_location.zipcode attributes:attrgen]];
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:attrgen]];
    }
    
    mutaddress[(NSString*)kABPersonAddressStateKey] = _location.state;
    mutaddress[(NSString*)kABPersonAddressCountryKey] = _location.country;
    
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attrcountry]];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:_location.state attributes:attrcountry]];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@", " attributes:attrcountry]];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:_location.country attributes:attrcountry]];
    
    NSInteger lblheight = ceilf([mut boundingRectWithSize:CGSizeMake(resultlblwidth, 200) options:stringdrawing context:nil].size.height);
    NSInteger lbly = 10;
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, lbly, resultlblwidth, lblheight + 5)];
    [lbl setUserInteractionEnabled:NO];
    [lbl setNumberOfLines:0];
    [lbl setAttributedText:mut];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 55, screenwidth, self.bounds.size.height - 75)];
    [btn setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    [btn setTitle:NSLocalizedString(@"vip_showmap", nil) forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:fontname size:18]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.2] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(actionloadmap:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:lbl];
    [self addSubview:btn];
    
    return self;
}

-(void)dealloc
{
    [locationmanager stopUpdatingLocation];
    [mapview setShowsUserLocation:NO];
}

#pragma mark actions

-(void)actionloadmap:(UIButton*)_button
{
    [_button removeFromSuperview];
    [self afterloadmap];
}

#pragma mark functionality

-(void)placelocation
{
    if(annotation)
    {
        [mapview addAnnotation:annotation];
        [mapview setRegion:MKCoordinateRegionMake(annotation.coordinate, mapspan) animated:YES];
    }
}

-(void)locationscheck
{
    switch([CLLocationManager authorizationStatus])
    {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            
            [mapview setShowsUserLocation:YES];
            
            break;
            
        case kCLAuthorizationStatusNotDetermined:
            
            locationmanager = [[locman alloc] init];
            [locationmanager setDelegate:self];
            
            if(applicationios == ioslevel7)
            {
                [mapview setShowsUserLocation:YES];
            }
            
            break;
            
        case kCLAuthorizationStatusDenied:
            break;
        case kCLAuthorizationStatusRestricted:
            break;
    }
}

-(void)centeruser
{
    [mapview setRegion:MKCoordinateRegionMake(userlocation, mapspan) animated:YES];
}

-(void)afterloadmap
{
    UIView *blackview = [[UIView alloc] initWithFrame:CGRectMake(0, 55, screenwidth, self.bounds.size.height - 75)];
    [blackview setBackgroundColor:[UIColor blackColor]];
    [self addSubview:blackview];
    
    mapspan = MKCoordinateSpanMake(0.1, 0.1);
    updateinitial = NO;
    MKMapView *strongmapview = [[MKMapView alloc] initWithFrame:CGRectMake(0, 1, screenwidth, CGRectGetHeight(blackview.frame) - 2)];
    mapview = strongmapview;
    [mapview setDelegate:self];
    [mapview setRotateEnabled:NO];
    [mapview setMapType:MKMapTypeStandard];
    [mapview setPitchEnabled:NO];
    [mapview setAlpha:0];
    
    if(itemlocation.latitude && itemlocation.longitude)
    {
        annotation = [[modann alloc] init:itemlocation.latitude lon:itemlocation.longitude title:annotationtitle];
    }
    else
    {
        [[[CLGeocoder alloc] init] geocodeAddressDictionary:mutaddress completionHandler:
         ^(NSArray<CLPlacemark *> * _Nullable _marks, NSError * _Nullable _error)
         {
             if(_error)
             {
                 NSLog(@"%@", _error.localizedDescription);
             }
             else if(_marks.count)
             {
                 CLPlacemark *mark = _marks[0];
                 annotation = [[modann alloc] init:mark.location.coordinate.latitude lon:mark.location.coordinate.longitude title:annotationtitle];
                 
                 [self placelocation];
             }
         }];
    }
    
    [blackview addSubview:mapview];
    
    [UIView animateWithDuration:1.5 animations:
     ^(void)
     {
         [mapview setAlpha:1];
     } completion:
     ^(BOOL _done)
     {
         [self locationscheck];
         [self placelocation];
     }];
}

#pragma -
#pragma mark location delegate

-(void)mapView:(MKMapView*)_mapview didUpdateUserLocation:(MKUserLocation*)_userlocation
{
    userlocation = _userlocation.coordinate;
    
    if(!updateinitial)
    {
        updateinitial = YES;
        
        if(!annotation)
        {
            [self centeruser];
        }
    }
}

-(void)locationManager:(CLLocationManager*)_manager didChangeAuthorizationStatus:(CLAuthorizationStatus)_status
{
    if(_status == kCLAuthorizationStatusAuthorizedAlways || _status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [mapview setShowsUserLocation:YES];
    }
}

@end

@implementation visearchvipattribute
{
    NSDictionary *attrtitle;
    NSDictionary *attrvalue;
}

@synthesize attr;

-(visearchvipattribute*)initWithFrame:(CGRect)_rect attribute:(moditemattribute*)_attr
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setUserInteractionEnabled:NO];
    
    attrtitle = @{NSFontAttributeName:[UIFont fontWithName:fontname size:14], NSForegroundColorAttributeName:[UIColor colorWithWhite:0.4 alpha:1]};
    attrvalue = @{NSFontAttributeName:[UIFont fontWithName:fontboldname size:14], NSForegroundColorAttributeName:colorsecond};
    
    attr = _attr;
    
    if([attr isKindOfClass:[moditemattributesimple class]])
    {
        [self attributesimple];
    }
    else if([attr isKindOfClass:[moditemattributecomplex class]])
    {
        [self attributecomplex];
    }
    else if([attr isKindOfClass:[moditemattributenum class]])
    {
        [self attributenumeric];
    }
    
    return self;
}

#pragma mark functionality

-(void)attributenumeric
{
    NSString *attrname = [(moditemattributenum*)attr name];
    NSMutableAttributedString *mut = [[NSMutableAttributedString alloc] init];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:attrname attributes:attrtitle]];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:attrtitle]];
    
    if([attrname isEqualToString:@"Año"])
    {
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [(moditemattributenum*)attr value]] attributes:attrvalue]];
    }
    else
    {
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:[[tools sha] numbertostring:[(moditemattributenum*)attr value]] attributes:attrvalue]];
    }
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width - 20, self.bounds.size.height)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setAttributedText:mut];
    [lbl setNumberOfLines:0];
    
    [self addSubview:lbl];
}

-(void)attributecomplex
{
    NSMutableAttributedString *mut = [[NSMutableAttributedString alloc] init];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:[(moditemattributecomplex*)attr name] attributes:attrtitle]];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:attrtitle]];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:[(moditemattributecomplex*)attr value] attributes:attrvalue]];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width - 20, self.bounds.size.height)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setAttributedText:mut];
    [lbl setNumberOfLines:0];
    
    [self addSubview:lbl];
}

-(void)attributesimple
{
    NSMutableAttributedString *mut = [[NSMutableAttributedString alloc] init];
    [mut appendAttributedString:[[NSAttributedString alloc] initWithString:[(moditemattributesimple*)attr title] attributes:attrvalue]];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, self.bounds.size.width - 40, self.bounds.size.height)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setNumberOfLines:0];
    [lbl setAttributedText:mut];
    
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(12, (self.bounds.size.height - 10)/ 2, 10, 10)];
    [indicator setClipsToBounds:YES];
    [indicator.layer setCornerRadius:6];
    [indicator setBackgroundColor:colorsecond];
    
    [self addSubview:lbl];
    [self addSubview:indicator];
}

@end

@implementation visearchvipcontact

@synthesize contact;

-(visearchvipcontact*)initWithFrame:(CGRect)_rect contact:(moditemcontact*)_contact
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    
    NSInteger width = _rect.size.width;
    NSInteger height = _rect.size.height;
    
    contact = _contact;
    NSDictionary *attrtitle = @{NSFontAttributeName:[UIFont fontWithName:fontname size:15], NSForegroundColorAttributeName:[UIColor colorWithWhite:0.3 alpha:1]};
    NSDictionary *attrvalue = @{NSFontAttributeName:[UIFont fontWithName:fontname size:18], NSForegroundColorAttributeName:colorsecond};
    NSMutableAttributedString *mut = [[NSMutableAttributedString alloc] init];
    NSString *phone = _contact.phone;
    NSString *email = _contact.email;
    NSString *imagename;
    
    if(contact.name.length)
    {
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:contact.name attributes:attrtitle]];
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attrtitle]];
    }
    
    if(_contact.openhours.length)
    {
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:contact.openhours attributes:attrtitle]];
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attrtitle]];
    }
    
    if(_contact.areacode.length)
    {
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"(%@) ", contact.areacode] attributes:attrvalue]];

    }
    
    if(phone)
    {
        NSInteger count = phone.length;
        NSInteger center = count / 2;
        
        phone = [NSString stringWithFormat:@"%@ %@", [phone substringToIndex:center], [phone substringFromIndex:center]];
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:phone attributes:attrvalue]];
        
        if(applicationtype == apptypephone)
        {
            imagename = @"phone";
        }
    }
    else if(email)
    {
        mut = [[NSMutableAttributedString alloc] init];
        [mut appendAttributedString:[[NSAttributedString alloc] initWithString:email attributes:attrvalue]];
        
        imagename = @"email";
    }
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, width - 50, height)];
    [lbl setUserInteractionEnabled:NO];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setNumberOfLines:0];
    [lbl setAttributedText:mut];
    
    [self addSubview:lbl];
    
    if(imagename)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 40, height)];
        [button setClipsToBounds:YES];
        [button setContentMode:UIViewContentModeScaleAspectFit];
        [button setImage:[[UIImage imageNamed:imagename] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [button.imageView setClipsToBounds:YES];
        [button.imageView setTintColor:colorsecond];
        
        if(phone)
        {
            [button addTarget:self action:@selector(actioncall) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [button addTarget:self action:@selector(actionwrite) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self addSubview:button];
    }
    
    return self;
}

#pragma mark actions

-(void)actioncall
{
    [contact call];
}

-(void)actionwrite
{
    [contact write];
}

@end

@implementation visearchvipempty

-(visearchvipempty*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setUserInteractionEnabled:NO];
    
    UIView *base = [[UIView alloc] initWithFrame:CGRectMake(0, 20, _rect.size.width, _rect.size.height - 40)];
    [base setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.03]];
    
    [self addSubview:base];
    
    return self;
}

@end