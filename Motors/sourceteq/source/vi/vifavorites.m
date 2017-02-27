#import "vifavorites.h"

@implementation vifavorites
{
    NSMutableArray *array;
}

@synthesize collection;

-(vifavorites*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setFooterReferenceSize:CGSizeZero];
    [flow setItemSize:CGSizeMake(screenwidth, 60)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:1];
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flow setSectionInset:UIEdgeInsetsMake(1, 0, 1, 0)];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection = strongcollection;
    [collection setClipsToBounds:YES];
    [collection setAlwaysBounceVertical:YES];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setDataSource:self];
    [collection setDelegate:self];
    [collection registerClass:[vifavoritesheader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerid];
    [collection registerClass:[vifavoritescel class] forCellWithReuseIdentifier:celid];
    
    [self addSubview:collection];
    [self loadtype:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedupdatefav) name:notupdatefav object:nil];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark notified

-(void)notifiedupdatefav
{
    [self loadtype:[vimaster sha].bar.favorites.selected];
}

#pragma mark functionality

-(void)loadtype:(NSInteger)_type
{
    [collection setHidden:YES];
    spinner *spin = [[spinner alloc] init:screenwidth_2 y:200];
    
    [self addSubview:spin];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       array = [NSMutableArray array];
                       statustype status = statustypeactive;
                       
                       if(_type)
                       {
                           status = statustypetrash;
                       }
                       else
                       {
                           status = statustypefavorite;
                       }
                       
                       NSArray *rawitems = [[modinitems sha] asarray];
                       NSInteger count = rawitems.count;
                       
                       for(NSInteger i = 0; i < count; i++)
                       {
                           modinitem *rawitem = rawitems[i];
                           
                           if(rawitem.status == status)
                           {
                               [array addObject:rawitem];
                           }
                       }
                       
                       dispatch_async(dispatch_get_main_queue(),
                                      ^(void)
                                      {
                                          [spin removeFromSuperview];
                                          [collection setHidden:NO];
                                          [collection reloadData];
                                      });
                   });
}

#pragma mark -
#pragma mark col del

-(CGSize)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout referenceSizeForHeaderInSection:(NSInteger)_section
{
    NSInteger height = 0;
    
    if(!array.count)
    {
        height = 200;
    }
    
    return CGSizeMake(screenwidth, height);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    return array.count;
}

-(UICollectionReusableView*)collectionView:(UICollectionView*)_col viewForSupplementaryElementOfKind:(NSString*)_kind atIndexPath:(NSIndexPath*)_index
{
    return [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:headerid forIndexPath:_index];
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    vifavoritescel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    [cel config:array[_index.item]];
    
    return cel;
}

-(void)collectionView:(UICollectionView*)_col didSelectItemAtIndexPath:(NSIndexPath*)_index
{
    [viitemdetail show:array[_index.item]];
}

@end

@implementation vifavoritesheader

-(vifavoritesheader*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, screenwidth - 40, _rect.size.height)];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setFont:[UIFont fontWithName:fontboldname size:18]];
    [lbl setTextColor:[UIColor colorWithWhite:0.6 alpha:1]];
    [lbl setNumberOfLines:0];
    [lbl setText:NSLocalizedString(@"favorites_empty", nil)];
    
    [self addSubview:lbl];
    
    return self;
}

@end

@implementation vifavoritescel

@synthesize image;
@synthesize lbl;

-(vifavoritescel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    
    NSInteger imagewidth = 60;
    NSInteger height = _rect.size.height;
    
    UIImageView *strongimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imagewidth, height)];
    image = strongimage;
    [image setUserInteractionEnabled:NO];
    [image setClipsToBounds:YES];
    [image setContentMode:UIViewContentModeScaleAspectFill];
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(imagewidth, 0, 1, height)];
    [border setUserInteractionEnabled:NO];
    [border setBackgroundColor:[UIColor blackColor]];
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:CGRectMake(imagewidth + 12, 0, screenwidth - (imagewidth + 22), height)];
    lbl = stronglbl;
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setNumberOfLines:0];
    [lbl setFont:[UIFont fontWithName:fontname size:14]];
    [lbl setTextColor:[UIColor colorWithWhite:0.1 alpha:1]];
    [lbl setUserInteractionEnabled:NO];
    
    [self addSubview:image];
    [self addSubview:border];
    [self addSubview:lbl];
    
    return self;
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

#pragma mark functionality

-(void)hover
{
    if(self.isSelected || self.isHighlighted)
    {
        [self setBackgroundColor:[colorsecond colorWithAlphaComponent:0.2]];
    }
    else
    {
        [self setBackgroundColor:[UIColor clearColor]];
    }
}

#pragma mark public

-(void)config:(modinitem*)_initem
{
    [image setImage:_initem.image];
    [lbl setText:_initem.title];
    [self hover];
}

@end

@implementation vifavoritesmenu

@synthesize collection;
@synthesize selected;

-(vifavoritesmenu*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    NSInteger width = _rect.size.width;
    NSInteger height = _rect.size.height;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setHeaderReferenceSize:CGSizeZero];
    [flow setFooterReferenceSize:CGSizeZero];
    [flow setItemSize:CGSizeMake(width / 2, height)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:0];
    [flow setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flow setSectionInset:UIEdgeInsetsZero];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection = strongcollection;
    [collection setClipsToBounds:YES];
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setScrollEnabled:NO];
    [collection setBounces:NO];
    [collection setDataSource:self];
    [collection setDelegate:self];
    [collection registerClass:[vifavoritesmenucel class] forCellWithReuseIdentifier:celid];
    
    selected = 0;
    
    [self addSubview:collection];
    [collection selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    return self;
}

#pragma mark -
#pragma mark col del

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    return 2;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    vifavoritesmenucel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    [cel config:_index.item];
    
    return cel;
}

-(void)collectionView:(UICollectionView*)_col didSelectItemAtIndexPath:(NSIndexPath*)_index
{
    NSInteger index = _index.item;
    
    if(index != selected)
    {
        selected = index;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:notupdatefav object:nil];
    }
}

@end

@implementation vifavoritesmenucel

@synthesize image;
@synthesize border;

-(vifavoritesmenucel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    NSInteger width = _rect.size.width;
    NSInteger height = _rect.size.height;
    NSInteger size = 30;
    
    UIImageView *strongimage = [[UIImageView alloc] initWithFrame:CGRectMake((width - size) / 2, ((height - size) / 2) + 5, size, size)];
    image = strongimage;
    [image setUserInteractionEnabled:NO];
    [image setClipsToBounds:YES];
    [image setContentMode:UIViewContentModeScaleAspectFit];
    
    UIView *strongborder = [[UIView alloc] initWithFrame:CGRectMake(0, height - 5, width, 4)];
    border = strongborder;
    [border setUserInteractionEnabled:NO];
    [border setBackgroundColor:[UIColor blackColor]];
    
    [self addSubview:image];
    [self addSubview:border];
    
    return self;
}

-(void)setHighlighted:(BOOL)_highlighted
{
    [super setHighlighted:_highlighted];
    [self hover];
}

-(void)setSelected:(BOOL)_selected
{
    [super setSelected:_selected];
    [self hover];
}

#pragma mark functionality

-(void)hover
{
    if(self.isSelected || self.isHighlighted)
    {
        [image setTintColor:[UIColor blackColor]];
        [border setHidden:NO];
    }
    else
    {
        [image setTintColor:[UIColor colorWithWhite:0 alpha:0.2]];
        [border setHidden:YES];
    }
}

#pragma mark public

-(void)config:(NSInteger)_index
{
    NSString *imgname;
    
    switch(_index)
    {
        case 0:
            
            imgname = @"like";
            
            break;
            
        case 1:
            
            imgname = @"trash";
            
            break;
    }
    
    [image setImage:[[UIImage imageNamed:imgname] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self hover];
}

@end