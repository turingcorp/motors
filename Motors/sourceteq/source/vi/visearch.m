#import "visearch.h"

@implementation visearch
{
    UIEdgeInsets insets;
    NSInteger itemheight;
    NSInteger itemheight_2;
    NSInteger height;
    NSInteger height_2;
    NSInteger margin;
    BOOL trackscroll;
    BOOL ispanning;
}

@synthesize searchman;
@synthesize celpanning;
@synthesize collection;
@synthesize pan;

-(visearch*)initWithFrame:(CGRect)_rect man:(visearchman*)_man
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    searchman = _man;
    trackscroll = NO;
    ispanning = NO;
    itemheight = 78;
    itemheight_2 = itemheight / 2;
    height = _rect.size.height;
    height_2 = height / 2;
    margin = height_2 - itemheight_2;
    insets = UIEdgeInsetsMake(margin, 0, margin, 0);
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:0];
    [flow setItemSize:CGSizeMake(screenwidth, itemheight)];
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection = strongcollection;
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setClipsToBounds:YES];
    [collection setDelegate:self];
    [collection setDataSource:self];
    [collection setAlwaysBounceVertical:YES];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection registerClass:[visearchcel class] forCellWithReuseIdentifier:celid];
    [collection registerClass:[visearchheader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerid];
    [collection registerClass:[visearchfooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerid];
    [collection setAutoresizingMask:UIViewAutoresizingFlexibleHeight];

    [self addSubview:collection];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedupdatesearch) name:notupdatesearch object:nil];
    
    if([searchman.search count])
    {
        [self selectresult:searchman.search.indexselected];
        [self addpan];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark notified

-(void)notifiedupdatesearch
{
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [self breakswipe];
                       [collection reloadData];
                       
                       if([searchman.search count])
                       {
                           [self selectnear];
                           [self addpan];
                       }
                   });
}

#pragma mark gesture

-(void)panning:(UIPanGestureRecognizer*)_pan
{
    CGFloat trans = [_pan translationInView:self].x;
    
    switch(_pan.state)
    {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateChanged:
            
            if(ispanning)
            {
                [celpanning partlyswipe:trans];
            }
            else
            {
                [collection setScrollEnabled:NO];
                
                if(celpanning.swiped)
                {
                    [celpanning unswipe:YES];
                }
                else
                {
                    ispanning = YES;
                }
            }
            
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            
            ispanning = NO;
            
            if(celpanning)
            {
                if(trans > 100)
                {
                    [celpanning swiperight];
                }
                else if(trans < -100)
                {
                    [celpanning swipeleft];
                }
                else
                {
                    [celpanning unswipe:YES];
                }
                
                celpanning = nil;
            }
            
            [collection setScrollEnabled:YES];
            
            break;
    }
}

#pragma mark functionality

-(void)addpan
{
    if(!pan)
    {
        UIPanGestureRecognizer *strongpan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panning:)];
        pan = strongpan;
        [pan setDelegate:self];
        [collection addGestureRecognizer:pan];
    }
}

-(void)breakswipe
{
    [collection setScrollEnabled:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:notbreakswipe object:nil];
}

-(void)innerselectresult:(NSInteger)_index
{
    if(searchman.search.indexselected != _index)
    {
        [searchman.search selectresult:_index];
        [[NSNotificationCenter defaultCenter] postNotificationName:notupdateresult object:nil];
        [self breakswipe];
    }
}

-(void)selectnear
{
    CGFloat topoffest = collection.contentOffset.y;
    CGPoint point = CGPointMake(screenwidth_2, topoffest + height_2);
    NSIndexPath *index = [collection indexPathForItemAtPoint:point];
    
    if(index)
    {
        [self innerselectresult:index.item];
        [collection selectItemAtIndexPath:index animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    [pan setEnabled:YES];
}

#pragma mark public

-(void)selectresult:(NSInteger)_index
{
    [self innerselectresult:_index];
    trackscroll = NO;
    [collection selectItemAtIndexPath:[NSIndexPath indexPathForItem:_index inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
}

#pragma mark -
#pragma mark gesture del

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)_gesture shouldReceiveTouch:(UITouch*)_touch
{
    BOOL receive = NO;
    
    CGPoint point = [_touch locationInView:self];
    point.y += collection.contentOffset.y;
    NSIndexPath *index = [collection indexPathForItemAtPoint:point];
    
    if(index.item == searchman.search.indexselected)
    {
        celpanning = (visearchcel*)[collection cellForItemAtIndexPath:index];
        receive = YES;
    }
    
    return receive;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)_gest shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)_othergest
{
    return YES;
}

#pragma mark scroll del

-(void)scrollViewWillBeginDragging:(UIScrollView*)_drag
{
    [pan setEnabled:NO];
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

-(UIEdgeInsets)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout insetForSectionAtIndex:(NSInteger)_section
{
    UIEdgeInsets ins;
    
    if([searchman.search count])
    {
        ins = insets;
    }
    else
    {
        ins = UIEdgeInsetsZero;
    }
    
    return ins;
}

-(CGSize)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout referenceSizeForHeaderInSection:(NSInteger)_section
{
    CGFloat headerheight = 0;
    
    if(!searchman.search.poolable)
    {
        if(![searchman.search count])
        {
            headerheight = 200;
        }
    }
    
    return CGSizeMake(screenwidth, headerheight);
}

-(CGSize)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout referenceSizeForFooterInSection:(NSInteger)_section
{
    NSInteger footerheight = 0;
    
    if(searchman.search.poolable)
    {
        footerheight = 150;
    }
    
    return CGSizeMake(screenwidth, footerheight);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    return [searchman.search count];
}

-(UICollectionReusableView*)collectionView:(UICollectionView*)_col viewForSupplementaryElementOfKind:(NSString*)_kind atIndexPath:(NSIndexPath*)_index
{
    UICollectionReusableView *reusable;
    
    if(_kind == UICollectionElementKindSectionHeader)
    {
         reusable = [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:headerid forIndexPath:_index];
        [(visearchheader*)reusable config:searchman];
    }
    else
    {
        reusable = [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:footerid forIndexPath:_index];
        [(visearchfooter*)reusable config:searchman];
    }
    
    return reusable;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    celpanning = nil;
    NSInteger item = _index.item;
    visearchcel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    [cel config:[searchman.search searchresult:item] man:searchman];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   ^(void)
                   {
                       if(searchman.search.poolable)
                       {
                           if(item > [searchman.search count] - 20)
                           {
                               [searchman.search pull];
                           }
                       }
                   });
    
    return cel;
}

-(void)collectionView:(UICollectionView*)_col didSelectItemAtIndexPath:(NSIndexPath*)_index
{
    [collection scrollToItemAtIndexPath:_index atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    [self innerselectresult:_index.item];
    trackscroll = NO;
}

@end

@implementation visearchheader

@synthesize searchman;

-(visearchheader*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIButton *btnretry = [[UIButton alloc] initWithFrame:CGRectMake(screenwidth_2 - 65, 70, 130, 36)];
    [btnretry setBackgroundColor:colorsecond];
    [btnretry setClipsToBounds:YES];
    [btnretry setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnretry setTitleColor:[UIColor colorWithWhite:1 alpha:0.1] forState:UIControlStateHighlighted];
    [btnretry setTitle:NSLocalizedString(@"search_btnretry", nil) forState:UIControlStateNormal];
    [btnretry.titleLabel setFont:[UIFont fontWithName:fontboldname size:17]];
    [btnretry.layer setCornerRadius:4];
    [btnretry addTarget:self action:@selector(actionretry) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btnretry];
    
    return self;
}

#pragma mark actions

-(void)actionretry
{
    [searchman.search pull];
    [[NSNotificationCenter defaultCenter] postNotificationName:notupdatesearch object:nil];
}

#pragma mark public

-(void)config:(visearchman*)_man
{
    searchman = _man;
}

@end

@implementation visearchfooter

@synthesize searchman;

-(visearchfooter*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setUserInteractionEnabled:NO];
    [self addSubview:[[spinner alloc] init:screenwidth_2 y:_rect.size.height / 2]];
    
    return self;
}

#pragma mark public

-(void)config:(visearchman*)_man
{
    searchman = _man;
    [searchman.search pull];
}

@end

@implementation visearchcel
{
    CGRect rectorigin;
    CGRect rectleft;
    CGRect rectright;
}

@synthesize searchman;
@synthesize result;
@synthesize baselbl;
@synthesize lbl;
@synthesize collection;
@synthesize swiped;

-(visearchcel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    
    NSInteger margin = 20;
    NSInteger width = _rect.size.width - (margin * 2);
    NSInteger maxheight = _rect.size.height;
    NSInteger height = maxheight - 2;
    NSInteger itemwidth = width / 3;
    swiped = NO;

    rectorigin = CGRectMake(0, 1, screenwidth, height);
    rectleft = CGRectMake(-screenwidth, 1, screenwidth, height);
    rectright = CGRectMake(screenwidth, 1, screenwidth, height);
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, resultlblwidth, height)];
    lbl = stronglbl;
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setUserInteractionEnabled:NO];
    [lbl setNumberOfLines:0];
    [lbl setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    
    UIView *strongbaselbl = [[UIView alloc] initWithFrame:rectorigin];
    baselbl = strongbaselbl;
    [baselbl setBackgroundColor:[UIColor whiteColor]];
    [baselbl setClipsToBounds:YES];
    [baselbl setUserInteractionEnabled:NO];
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setFooterReferenceSize:CGSizeZero];
    [flow setHeaderReferenceSize:CGSizeZero];
    [flow setItemSize:CGSizeMake(itemwidth, maxheight)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:0];
    [flow setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flow setSectionInset:UIEdgeInsetsMake(0, margin, 0, margin)];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection = strongcollection;
    [collection setUserInteractionEnabled:NO];
    [collection setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setScrollEnabled:NO];
    [collection setBounces:NO];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setClipsToBounds:YES];
    [collection setDataSource:self];
    [collection setDelegate:self];
    [collection registerClass:[visearchcelaction class] forCellWithReuseIdentifier:celid];
    
    [baselbl addSubview:lbl];
    [self addSubview:collection];
    [self addSubview:baselbl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedbreakswipe) name:notbreakswipe object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedupdatestatus:) name:notupdatestatus object:nil];
    
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

-(void)notifiedbreakswipe
{
    if(swiped)
    {
        [self unswipe:YES];
    }
}

-(void)notifiedupdatestatus:(NSNotification*)_notification
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

-(void)hover
{
    if(self.isSelected || self.isHighlighted)
    {
        [lbl setAlpha:1];
        [self setBackgroundColor:[UIColor blackColor]];
    }
    else
    {
        [lbl setAlpha:0.2];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
}

-(void)notifyupdatestatus
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notupdatestatus object:nil userInfo:[result userinfo]];
}

#pragma mark public

-(void)config:(modsearchresult*)_result man:(visearchman*)_man
{
    searchman = _man;
    result = _result;
    [lbl setAttributedText:result.attr];
    [collection reloadData];
    [self hover];
}

-(void)swipeleft
{
    swiped = YES;
    
    [UIView animateWithDuration:0.3 animations:
     ^(void)
     {
         [baselbl setFrame:rectleft];
     } completion:
     ^(BOOL _done)
     {
         [collection setUserInteractionEnabled:YES];
     }];
}

-(void)swiperight
{
    swiped = YES;
    
    [UIView animateWithDuration:0.3 animations:
     ^(void)
     {
         [baselbl setFrame:rectright];
     } completion:
     ^(BOOL _done)
     {
         [collection setUserInteractionEnabled:YES];
     }];
}

-(void)unswipe:(BOOL)_animated
{
    [collection setUserInteractionEnabled:NO];
    swiped = NO;
    CGFloat duration = 0;
    
    if(_animated)
    {
        duration = 0.25;
    }
    
    [UIView animateWithDuration:duration animations:
     ^(void)
     {
         [baselbl setFrame:rectorigin];
     }];
}

-(void)partlyswipe:(CGFloat)_xpos
{
    swiped = YES;
    [baselbl setFrame:CGRectMake(rectorigin.origin.x + _xpos, rectorigin.origin.y, rectorigin.size.width, rectorigin.size.height)];
}

#pragma mark -
#pragma mark col del

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    return 3;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    visearchcelaction *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    
    switch(_index.item)
    {
        case 0:
            
            [cel actiontrash:result.initem.status == statustypetrash];
            
            break;
            
        case 1:
            
            [cel actionlike:result.initem.status == statustypefavorite];
            
            break;
            
        case 2:
            
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
            
            [result.initem trash];
            [searchman trashresult:result];
            
            [self notifyupdatestatus];
            
            break;
            
        case 1:
            
            if(result.initem.status != statustypefavorite)
            {
                [result.initem favorite];
            }
            else
            {
                [result.initem nostatus];
            }
            
            [self notifyupdatestatus];
            
            break;
            
        case 2:
            
            [searchman changesearchstate:appsearchstatedetail];
            
            break;
    }
}

@end

@implementation visearchcelaction
{
    UIColor *color;
}

@synthesize image;

-(visearchcelaction*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *strongimage = [[UIImageView alloc] initWithFrame:CGRectMake(24, 24, _rect.size.width - 48, _rect.size.height - 48)];
    image = strongimage;
    [image setClipsToBounds:YES];
    [image setUserInteractionEnabled:NO];
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
        [image setTintColor:[color colorWithAlphaComponent:0.2]];
    }
    else
    {
        [image setTintColor:color];
    }
}

#pragma mark public

-(void)actiontrash:(BOOL)_trashed
{
    [image setImage:[[UIImage imageNamed:@"trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    if(_trashed)
    {
        color = colormain;
    }
    else
    {
        color = colorsecond;
    }
    
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

-(void)actiondetail
{
    [image setImage:[[UIImage imageNamed:@"detail"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    color = colorsecond;
    [self hover];
}

@end