#import "visearchman.h"

@implementation visearchman
{
    NSInteger currentimageheight;
    NSInteger minimageheight;
    NSInteger maximageheight;
    NSInteger imageheight;
    NSInteger listheight;
    NSInteger attrnum;
}

@synthesize search;
@synthesize collection;
@synthesize gradient;
@synthesize searchstate;

-(visearchman*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    search = [[modsearch alloc] init];
    
    NSInteger height = _rect.size.height;
    minimageheight = 20;
    attrnum = 0;
    
    switch(applicationtype)
    {
        case apptypepad:
            
            currentimageheight = imageheight = screenwidth / 4;
            maximageheight = currentimageheight + 50;
            
            break;
            
        case apptypephone:
            
            currentimageheight = imageheight = screenwidth / 3.0 * 2.0;
            maximageheight = currentimageheight + 150;
            
            break;
    }
    
    listheight = height - imageheight;
    searchstate = appsearchstatelist;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    UIView *blackview = [[UIView alloc] initWithFrame:CGRectMake(0, -screenheight, screenwidth, screenheight)];
    [blackview setUserInteractionEnabled:NO];
    [blackview setBackgroundColor:[UIColor blackColor]];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection = strongcollection;
    [collection setClipsToBounds:YES];
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setDataSource:self];
    [collection setDelegate:self];
    [collection setBounces:NO];
    [collection setScrollEnabled:NO];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection registerClass:[visearchmanheader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerid];
    [collection registerClass:[visearchmanfooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerid];
    [collection registerClass:[visearchmancel class] forCellWithReuseIdentifier:celid];
    [collection setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    [collection addSubview:blackview];
    [self addSubview:collection];
    
    UIImageView *stronggradient = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenwidth, 80)];
    gradient = stronggradient;
    [gradient setUserInteractionEnabled:NO];
    [gradient setClipsToBounds:YES];
    [gradient setImage:[UIImage imageNamed:@"grad"]];
    [gradient setContentMode:UIViewContentModeTop];
    [gradient setHidden:YES];
    
    [self addSubview:gradient];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedupdateitem:) name:notupdateitem object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedcleansearch) name:notcleansearch object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedfilterschanged) name:notfilterschanged object:nil];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark notified

-(void)notifiedupdateitem:(NSNotification*)_notification
{
    if([search.resultselected equalsuserinfo:_notification.userInfo])
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^(void)
                       {
                           [collection reloadData];
                       });
    }
}

-(void)notifiedcleansearch
{
    search = [[modsearch alloc] init];
    
    [collection reloadData];
}

-(void)notifiedfilterschanged
{
    [search retry];
    
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [collection reloadData];
                   });
}

#pragma mark public

-(void)changesearchstate:(appsearchstate)_newsearchstate
{
    searchstate = _newsearchstate;
    
    switch(searchstate)
    {
        case appsearchstatedetail:
            
            currentimageheight = maximageheight;
            [search.resultselected getitem];
            [collection setScrollEnabled:YES];
            [collection setBounces:YES];
            [collection setAlwaysBounceVertical:YES];
            
            [[vimaster sha] changebar:appbarstatehide];
            [[ctrmain sha] statusbarlight];
            [gradient setHidden:NO];
            
            break;
            
        case appsearchstatelist:
            
            currentimageheight = imageheight;
            [collection setScrollEnabled:NO];
            [collection setBounces:NO];
            
            [[vimaster sha] changebar:appbarstateshown];
            [[ctrmain sha] statusbardark];
            [gradient setHidden:YES];
            
            break;
    }
    
    [collection reloadData];
}

-(void)trashresult:(modsearchresult*)_result
{
    [search remove:_result];
    [collection reloadData];
    
    if(search.count)
    {
        [search selectresult:search.indexselected];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:notupdateresult object:nil];
}

#pragma mark -
#pragma mark col del

-(void)scrollViewDidScroll:(UIScrollView*)_scroll
{
    switch(searchstate)
    {
        case appsearchstatedetail:
        {
            CGFloat offsety = collection.contentOffset.y;
            currentimageheight = maximageheight - (offsety * 2);
            
            if(currentimageheight < minimageheight)
            {
                currentimageheight = minimageheight;
            }
            else if(currentimageheight > maximageheight)
            {
                currentimageheight = maximageheight;
            }
        }
            break;
            
        case appsearchstatelist:
            
            currentimageheight = imageheight;
            
            break;
    }
    
    [collection.collectionViewLayout invalidateLayout];
}

-(UIEdgeInsets)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout insetForSectionAtIndex:(NSInteger)_section
{
    return UIEdgeInsetsZero;
}

-(CGFloat)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)_section
{
    return 0;
}

-(CGFloat)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout minimumLineSpacingForSectionAtIndex:(NSInteger)_section
{
    return 0;
}

-(CGSize)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout referenceSizeForHeaderInSection:(NSInteger)_section
{
    return CGSizeMake(screenwidth, currentimageheight);
}

-(CGSize)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout referenceSizeForFooterInSection:(NSInteger)_section
{
    NSInteger height = 0;
    
    switch(searchstate)
    {
        case appsearchstatedetail:
            
            if(!search.resultselected.item)
            {
                height = 150;
            }
            
            break;
            
        case appsearchstatelist:
            break;
    }
    
    return CGSizeMake(screenwidth, height);
}

-(CGSize)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout sizeForItemAtIndexPath:(NSIndexPath*)_index
{
    NSInteger item = _index.item;
    NSInteger height = 0;
    
    switch(searchstate)
    {
        case appsearchstatelist:
            
            height = listheight;
            
            break;
            
        case appsearchstatedetail:
            
            if(search.resultselected.item)
            {
                switch(item)
                {
                    case 0:
                        
                        height = 100;
                        
                        break;
                        
                    case 1:
                        
                        height = 60;
                        
                        break;
                        
                    case 2:
                        
                        height = 80;
                        
                        break;
                        
                    case 3:
                        
                        height = 50;
                        
                        break;
                        
                    default:
                        
                        if(item == 7 + attrnum)
                        {
                            height = 415;
                        }
                        else if(item == 5 + attrnum)
                        {
                            height = 60;
                        }
                        else if(item == 4 + attrnum || item == 6 + attrnum)
                        {
                            height = 50;
                        }
                        else
                        {
                            height = 34;
                        }
                        
                        break;
                }
            }
            else
            {
                switch(item)
                {
                    case 0:
                        
                        height = 60;
                        
                        break;
                        
                    case 1:
                        
                        height = 80;
                        
                        break;
                }
            }
            
            break;
    }
    
    return CGSizeMake(screenwidth, height);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    NSInteger sections;
    
    switch(searchstate)
    {
        case appsearchstatelist:
            
            sections = 1;
            
            break;
            
        case appsearchstatedetail:
            
            if(search.resultselected.item)
            {
                attrnum = [search.resultselected.item.attributes count];
                sections = 8 + attrnum;
            }
            else
            {
                sections = 3;
            }
            
            break;
    }
    
    return sections;
}

-(UICollectionReusableView*)collectionView:(UICollectionView*)_col viewForSupplementaryElementOfKind:(NSString*)_kind atIndexPath:(NSIndexPath*)_index
{
    UICollectionReusableView *reusable;
    
    if(_kind == UICollectionElementKindSectionHeader)
    {
        reusable = [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:headerid forIndexPath:_index];
        [(visearchmanheader*)reusable config:self];
    }
    else
    {
        reusable = [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:footerid forIndexPath:_index];
    }
    
    return reusable;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    NSInteger item = _index.item;
    
    visearchmancel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    [cel config:self index:item];
    
    return cel;
}

@end

@implementation visearchmanheader
{
    NSInteger numactions;
}

@synthesize searchman;
@synthesize searchresult;
@synthesize picture;
@synthesize collection;
@synthesize image;
@synthesize gradient;

-(visearchmanheader*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor blackColor]];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    NSInteger height = _rect.size.height;
    NSInteger actionswidth = 50;
    NSInteger actionsx = screenwidth - actionswidth;
    NSInteger actionsheight = 100;
    NSInteger actionsmargin = (height - (actionsheight * 2)) / 2;
    numactions = 0;
    
    UIImageView *strongimage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, screenwidth, _rect.size.height - 2)];
    image = strongimage;
    [image setClipsToBounds:YES];
    [image setUserInteractionEnabled:NO];
    [image setContentMode:UIViewContentModeScaleAspectFill];
    [image setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setFooterReferenceSize:CGSizeZero];
    [flow setHeaderReferenceSize:CGSizeZero];
    [flow setItemSize:CGSizeMake(actionswidth, actionsheight)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:0];
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flow setSectionInset:UIEdgeInsetsMake(actionsmargin, 0, actionsmargin, 0)];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:CGRectMake(actionsx, 0, actionswidth, height) collectionViewLayout:flow];
    collection = strongcollection;
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setClipsToBounds:YES];
    [collection setBounces:NO];
    [collection setScrollEnabled:NO];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setDelegate:self];
    [collection setDataSource:self];
    [collection registerClass:[visearchmanheaderaction class] forCellWithReuseIdentifier:celid];
    [collection setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    UIImageView *stronggradient = [[UIImageView alloc] initWithFrame:CGRectMake(screenwidth - 200, 0, 200, height)];
    gradient = stronggradient;
    [gradient setUserInteractionEnabled:NO];
    [gradient setClipsToBounds:YES];
    [gradient setContentMode:UIViewContentModeCenter];
    [gradient setImage:[UIImage imageNamed:@"leftgrad"]];
    [gradient setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    [self addSubview:image];
    [self addSubview:gradient];
    [self addSubview:collection];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedthumbnailready:) name:notimageready object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedupdatestatus:) name:notupdatestatus object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedloadpicture:) name:notchangeheaderpic object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedupdateresult) name:notupdateresult object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedclean) name:notcleansearch object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedclean) name:notfilterschanged object:nil];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark notified

-(void)notifiedthumbnailready:(NSNotification*)_notification
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

-(void)notifiedupdatestatus:(NSNotification*)_notification
{
    if([searchresult equalsuserinfo:_notification.userInfo])
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^(void)
                       {
                           [collection reloadData];
                       });
    }
}

-(void)notifiedloadpicture:(NSNotification*)_notification
{
    picture = [moditempicture parse:_notification];
    
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [self configimage];
                   });
}

-(void)notifiedupdateresult
{
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [self updateresult];
                   });
}

-(void)notifiedclean
{
    picture = nil;
    numactions = 0;
    
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [self configimage];
                       [collection reloadData];
                   });
}

#pragma mark functionality

-(void)configimage
{
    [image setImage:picture.image];
}

-(void)updateresult
{
    searchresult = searchman.search.resultselected;
    picture = searchresult.picture;
    [self configimage];
    
    if(searchresult)
    {
        numactions = 2;
    }
    else
    {
        numactions = 0;
    }
    
    [collection reloadData];
}

#pragma mark public

-(void)config:(visearchman*)_searchman
{
    CGFloat alphagradient = 0;
    BOOL colhidden = YES;
    searchman = _searchman;
    
    if(_searchman)
    {
        switch(searchman.searchstate)
        {
            case appsearchstatedetail:
                
                break;
                
            case appsearchstatelist:
                
                alphagradient = 1;
                colhidden = NO;
                
                break;
        }
    }
    
    [collection setHidden:colhidden];
    
    [UIView animateWithDuration:0.4 animations:
     ^(void)
     {
         [gradient setAlpha:alphagradient];
     }];
}

#pragma mark -
#pragma mark col del

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    return numactions;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    visearchmanheaderaction *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    
    switch(_index.item)
    {
        case 0:
            
            [cel actionlike:searchresult.initem.status == statustypefavorite];
            
            break;
            
        case 1:
            
            [cel actiondetail];
            
            break;
    }
    
    return cel;
}

-(void)collectionView:(UICollectionView*)_col didSelectItemAtIndexPath:(NSIndexPath*)_index
{
    switch(_index.item)
    {
        case 0:
            
            if(searchresult.initem.status != statustypefavorite)
            {
                [searchresult.initem favorite];
            }
            else
            {
                [searchresult.initem nostatus];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:notupdatestatus object:nil userInfo:[searchresult userinfo]];
            
            break;
            
        case 1:
            
            [searchman changesearchstate:appsearchstatedetail];
            
            break;
    }
}

@end

@implementation visearchmanheaderaction
{
    UIColor *color;
    CGRect rectsmall;
    CGRect rectbig;
}

@synthesize image;

-(visearchmanheaderaction*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    NSInteger width = _rect.size.width;
    NSInteger height = _rect.size.height;
    NSInteger iconsize = 30;
    NSInteger iconsizebig = 50;
    
    rectsmall = CGRectMake((width - iconsize) / 2, (height - iconsize) / 2, iconsize, iconsize);
    rectbig = CGRectMake((width - iconsizebig) / 2, (height - iconsizebig) / 2, iconsizebig, iconsizebig);
    UIImageView *strongimage = [[UIImageView alloc] initWithFrame:rectsmall];
    image = strongimage;
    [image setUserInteractionEnabled:NO];
    [image setClipsToBounds:YES];
    [image setContentMode:UIViewContentModeScaleAspectFit];
    
    [self addSubview:image];
    
    return self;
}

#pragma mark functionality

-(void)setHighlighted:(BOOL)_highlighted
{
    [super setHighlighted:_highlighted];
    [self hover];
}

-(void)setSelected:(BOOL)_selected
{
    [self hover];
}

-(void)hover
{
    if(self.isSelected || self.isHighlighted)
    {
        [image setTintColor:[color colorWithAlphaComponent:0.2]];
    }
    else
    {
        [image setTintColor:color];
    }
}

#pragma mark public

-(void)actiondetail
{
    [image setImage:[[UIImage imageNamed:@"detail"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    color = colormain;
    [image setFrame:rectsmall];
    
    [self hover];
}

-(void)actionlike:(BOOL)_liked
{
    [image setImage:[[UIImage imageNamed:@"like"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    if(_liked)
    {
        color = [UIColor colorWithWhite:1 alpha:0.4];
        [image setFrame:rectbig];
    }
    else
    {
        color = colormain;
        [image setFrame:rectsmall];
    }
    
    [self hover];
}

@end

@implementation visearchmanfooter

-(visearchmanfooter*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:[[spinner alloc] init:screenwidth_2 y:_rect.size.height / 2]];
    
    return self;
}

@end

@implementation visearchmancel

@synthesize searchman;
@synthesize attributes;
@synthesize innerview;

-(visearchmancel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    return self;
}

#pragma mark public

-(void)config:(visearchman*)_searchman index:(NSInteger)_index
{
    searchman = _searchman;
    
    modsearchresult *result = searchman.search.resultselected;
    attributes = result.item.attributes;
    NSInteger attrcount = [attributes count];
    [innerview removeFromSuperview];
    
    UIView *stronginnerview;
    
    switch(searchman.searchstate)
    {
        case appsearchstatelist:
            
            stronginnerview = [[visearch alloc] initWithFrame:self.bounds man:_searchman];
            
            break;
            
        case appsearchstatedetail:
            
            if(searchman.search.resultselected.item)
            {
                switch(_index)
                {
                    case 0:
                        
                        stronginnerview = [[visearchvip alloc] initWithFrame:self.bounds pictures:result.item.pictures];
                        
                        break;
                        
                    case 1:
                        
                        stronginnerview = [[visearchvipactions alloc] initWithFrame:self.bounds man:searchman];
                        
                        break;
                        
                    case 2:
                        
                        stronginnerview = [[visearchvipbasic alloc] initWithFrame:self.bounds result:result];
                        
                        break;
                        
                    case 3:
                        
                        stronginnerview = [[visearchvipempty alloc] initWithFrame:self.bounds];
                        
                        break;
                        
                    default:
                        
                        if(_index == 7 + attrcount)
                        {
                            stronginnerview = [[visearchviplocation alloc] initWithFrame:self.bounds location:result.item.location title:result.title];
                        }
                        else if(_index == 5 + attrcount)
                        {
                            stronginnerview = [[visearchvipcontact alloc] initWithFrame:self.bounds contact:result.item.contact];
                        }
                        else if(_index == 4 + attrcount || _index == 6 + attrcount)
                        {
                            stronginnerview = [[visearchvipempty alloc] initWithFrame:self.bounds];
                        }
                        else
                        {
                            stronginnerview = [[visearchvipattribute alloc] initWithFrame:self.bounds attribute:[attributes attribute:_index - 4]];
                        }
                        
                        break;
                }
            }
            else
            {
                switch(_index)
                {
                    case 0:
                        
                        stronginnerview = [[visearchvipactions alloc] initWithFrame:self.bounds man:_searchman];
                        
                        break;
                        
                    case 1:
                        
                        stronginnerview = [[visearchvipbasic alloc] initWithFrame:self.bounds result:result];
                        
                        break;
                }
            }
            
            break;
    }
    
    innerview = stronginnerview;
    
    [self addSubview:innerview];
}

@end