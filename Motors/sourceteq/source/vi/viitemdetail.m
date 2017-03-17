#import "viitemdetail.h"

@implementation viitemdetail
{
    NSString *headeritem;
    NSInteger items;
    NSInteger headerheight;
}

@synthesize item;
@synthesize deepitem;
@synthesize collection;

+(void)show:(modinitem*)_item
{
    [[analytics singleton] screen:@"FavoritesItem"];
    
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [[vimaster sha] addSubview:[[viitemdetail alloc] init:_item]];
                   });
}

-(viitemdetail*)init:(modinitem*)_item
{
    self = [super initWithFrame:screenrect];
    [self setClipsToBounds:YES];
    [self setAlpha:0];
    
    headeritem = @"headeritem";
    items = 0;
    item = _item;
    
    switch(applicationtype)
    {
        case apptypepad:
            
            headerheight = (screenwidth / 4) + 50;
            
            break;
            
        case apptypephone:
            
            headerheight = (screenwidth / 3.0 * 2.0) + 150;
            
            break;
    }
    
    if(applicationios == ioslevel7)
    {
        [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.99]];
    }
    else
    {
        UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        [blur setFrame:screenrect];
        [blur setUserInteractionEnabled:NO];
        
        [self addSubview:blur];
    }
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setFooterReferenceSize:CGSizeMake(screenwidth, 55)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:0];
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flow setSectionInset:UIEdgeInsetsZero];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection = strongcollection;
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setClipsToBounds:YES];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setAlwaysBounceVertical:YES];
    [collection setDataSource:self];
    [collection setDelegate:self];
    [collection registerClass:[visearchmanheader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headeritem];
    [collection registerClass:[viitemdetailheader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerid];
    [collection registerClass:[viitemdetailfooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerid];
    [collection registerClass:[viitemdetailcel class] forCellWithReuseIdentifier:celid];
    
    UIImageView *gradient = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenwidth, 80)];
    [gradient setUserInteractionEnabled:NO];
    [gradient setClipsToBounds:YES];
    [gradient setImage:[UIImage imageNamed:@"grad"]];
    [gradient setContentMode:UIViewContentModeTop];
    
    UIView *black = [[UIView alloc] initWithFrame:CGRectMake(0, -screenheight, screenwidth, screenheight)];
    [black setUserInteractionEnabled:NO];
    [black setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8]];
    
    [collection addSubview:black];
    [self addSubview:collection];
    [self addSubview:gradient];
    [self animateshow];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedupdateitem:) name:notupdateitem object:nil];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark notified

-(void)notifiedupdateitem:(NSNotification*)_notification
{
    if([item.result equalsuserinfo:_notification.userInfo])
    {
        [self displayitem];
    }
}

#pragma mark animations

-(void)animateshow
{
    [[ctrmain sha] statusbarlight];
    
    [UIView animateWithDuration:0.3 animations:
     ^(void)
     {
         [self setAlpha:1];
     } completion:
     ^(BOOL _done)
     {
         [self loaditem];
     }];
}

-(void)animatehide
{
    [UIView animateWithDuration:0.3 animations:
     ^(void)
     {
         [self setAlpha:0];
     } completion:
     ^(BOOL _done)
     {
         [self removeFromSuperview];
         [[ctrmain sha] statusbardark];
     }];
}

#pragma mark functionality

-(void)loaditem
{
    if(item.result.item)
    {
        [self displayitem];
    }
    else
    {
        [item loaditem];
    }
}

-(void)displayitem
{
    deepitem = item.result.item;
    items = [deepitem.attributes count] + 7;
    
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [collection reloadData];
                   });
}

#pragma mark public

-(void)close
{
    [self animatehide];
}

#pragma mark -
#pragma mark col del

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    return items;
}

-(CGSize)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout referenceSizeForHeaderInSection:(NSInteger)_section
{
    NSInteger height;
    
    if(deepitem)
    {
        height = headerheight;
    }
    else
    {
        height = 300;
    }
    
    return CGSizeMake(screenwidth, height);
}

-(CGSize)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout sizeForItemAtIndexPath:(NSIndexPath*)_index
{
    NSInteger height = 0;
    
    switch(_index.item)
    {
        case 0:
            
            height = 100;
            
            break;
            
        case 1:
            
            height = 80;
            
            break;
            
        case 2:
            
            height = 50;
            
            break;
            
        case 3:
            
            height = 60;
            
            break;
            
        case 4:
            
            height = 50;
            
            break;
            
        case 5:
            
            height = 415;
            
            break;
            
        case 6:
            
            height = 50;
            
            break;
            
        default:
            
            height = 34;
            
            break;
    }
    
    return CGSizeMake(screenwidth, height);
}

-(UICollectionReusableView*)collectionView:(UICollectionView*)_col viewForSupplementaryElementOfKind:(NSString*)_kind atIndexPath:(NSIndexPath*)_index
{
    UICollectionReusableView *reusable;
    
    if(_kind == UICollectionElementKindSectionHeader)
    {
        if(deepitem)
        {
            reusable = [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:headeritem forIndexPath:_index];
            [(visearchmanheader*)reusable config:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:notchangeheaderpic object:nil userInfo:[item.result.picture userinfo]];
        }
        else
        {
            reusable = [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:headerid forIndexPath:_index];
        }
    }
    else
    {
        reusable = [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:footerid forIndexPath:_index];
        [(viitemdetailfooter*)reusable config:self];
    }
    
    return reusable;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    viitemdetailcel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    NSInteger index = _index.item;
    
    switch(index)
    {
        case 0:
            
            [cel loadimages:deepitem.pictures];
            
            break;
            
        case 1:
            
            [cel loadbasic:item.result];
            
            break;
            
        case 2:
            
            [cel loadempty];
            
            break;
            
        case 3:
            
            [cel loadcontact:item.contact];
            
            break;
            
        case 4:
            
            [cel loadempty];
            
            break;
            
        case 5:
            
            [cel loadlocation:deepitem.location title:item.title];
            
            break;
            
        case 6:
            
            [cel loadempty];
            
            break;
            
        default:

            [cel loadattribute:[deepitem.attributes attribute:index - 7]];
            
            break;
    }
    
    return cel;
}

@end

@implementation viitemdetailheader

-(viitemdetailheader*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    [self addSubview:[[spinner alloc] init:_rect.size.width / 2 y:_rect.size.height / 2]];
    [self setUserInteractionEnabled:NO];
    
    return self;
}

@end

@implementation viitemdetailfooter

@synthesize detail;

-(viitemdetailfooter*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    NSInteger height = _rect.size.height;
    
    UIButton *btnclose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, height)];
    [btnclose setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    [btnclose setImage:[[UIImage imageNamed:@"close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [btnclose.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnclose.imageView setTintColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [btnclose.imageView setClipsToBounds:YES];
    [btnclose addTarget:self action:@selector(actionclose) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenwidth, 1)];
    [border setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
    [border setUserInteractionEnabled:NO];
    
    [self addSubview:border];
    [self addSubview:btnclose];
    
    return self;
}

#pragma mark actions

-(void)actionclose
{
    [detail close];
}

#pragma mark public

-(void)config:(viitemdetail*)_detail
{
    detail = _detail;
}

@end

@implementation viitemdetailcel

@synthesize inview;

-(viitemdetailcel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    return self;
}

#pragma mark functionality

-(void)newinview:(UIView*)_inview
{
    [inview removeFromSuperview];
    inview = _inview;
    
    [self addSubview:inview];
}

#pragma mark public

-(void)loadimages:(moditempictures*)_pictures
{
    [self newinview:[[visearchvip alloc] initWithFrame:self.bounds pictures:_pictures]];
}

-(void)loadbasic:(modsearchresult*)_result
{
    [self newinview:[[visearchvipbasic alloc] initWithFrame:self.bounds result:_result]];
}

-(void)loadcontact:(moditemcontact*)_contact
{
    [self newinview:[[visearchvipcontact alloc] initWithFrame:self.bounds contact:_contact]];
}

-(void)loadlocation:(moditemlocation*)_location title:(NSString*)_title
{
    [self newinview:[[visearchviplocation alloc] initWithFrame:self.bounds location:_location title:_title]];
}

-(void)loadattribute:(moditemattribute*)_attribute
{
    [self newinview:[[visearchvipattribute alloc] initWithFrame:self.bounds attribute:_attribute]];
}

-(void)loadempty
{
    [self newinview:[[visearchvipempty alloc] initWithFrame:self.bounds]];
}

@end
