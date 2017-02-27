#import "vicountries.h"

@implementation vicountries
{
    BOOL trackscroll;
}

@synthesize collection;
@synthesize lbl;

-(vicountries*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    trackscroll = NO;
    CGFloat margin = (_rect.size.width / 2) - 50;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setFooterReferenceSize:CGSizeZero];
    [flow setHeaderReferenceSize:CGSizeZero];
    [flow setItemSize:CGSizeMake(100, 100)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:0];
    [flow setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flow setSectionInset:UIEdgeInsetsMake(0, margin, 0, margin)];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 10, _rect.size.width, 100) collectionViewLayout:flow];
    collection = strongcollection;
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setClipsToBounds:YES];
    [collection setAlwaysBounceHorizontal:YES];
    [collection setDataSource:self];
    [collection setDelegate:self];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection registerClass:[vicountriescel class] forCellWithReuseIdentifier:celid];
    [collection setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, _rect.size.width, 45)];
    lbl = stronglbl;
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setUserInteractionEnabled:NO];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setTextColor:colorsecond];
    [lbl setFont:[UIFont fontWithName:fontboldname size:20]];
    
    [self addSubview:lbl];
    [self addSubview:collection];
    [self selectcountryindex:[modsettings sha].siteindex];
    
    return self;
}

#pragma mark functionality

-(void)insideselectcountryindex:(NSInteger)_countryindex
{
    [[modsettings sha] changecountry:_countryindex];
    [[modsettings sha] savepreferences];
    [lbl setText:[modsettings sha].site.name];
}

-(void)selectcountryindex:(NSInteger)_countryindex
{
    [self insideselectcountryindex:_countryindex];
    trackscroll = NO;
    [collection selectItemAtIndexPath:[NSIndexPath indexPathForItem:_countryindex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

#pragma mark -
#pragma mark col del

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
        CGFloat leftoffset = collection.contentOffset.x;
        
        CGPoint point = CGPointMake(leftoffset + (collection.bounds.size.width / 2), collection.bounds.size.height / 2);
        NSIndexPath *index = [collection indexPathForItemAtPoint:point];
        
        if(index)
        {
            [self insideselectcountryindex:index.item];
            [collection selectItemAtIndexPath:index animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    return 14;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    vicountriescel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    [cel config:[[modsites sha] site:_index.item]];
    
    return cel;
}

-(void)collectionView:(UICollectionView*)_col didSelectItemAtIndexPath:(NSIndexPath*)_index
{
    [collection scrollToItemAtIndexPath:_index atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self insideselectcountryindex:_index.item];
    trackscroll = NO;
}

@end

@implementation vicountriescel

@synthesize image;

-(vicountriescel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
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
    [image hover:self.isSelected || self.isHighlighted];
}

#pragma mark public

-(void)config:(modsite*)_site
{
    [image removeFromSuperview];
    
    vicountriesimage *strongimage = [[vicountriesimage alloc] initWithFrame:self.bounds triangle:YES site:_site];
    image = strongimage;
    
    [self addSubview:image];
    [self hover];
}

@end

@implementation vicountriesimage
{
    BOOL triangle;
}

-(vicountriesimage*)initWithFrame:(CGRect)_rect triangle:(BOOL)_triangle site:(modsite*)_site
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setUserInteractionEnabled:NO];
    
    triangle = _triangle;
    CGFloat size = _rect.size.width - 50;
    CGRect rect;
    CGRect rectmask;
    
    if([_site.identifier isEqualToString:@"MLC"] || [_site.identifier isEqualToString:@"MLU"])
    {
        rect = CGRectMake(25, 0, _rect.size.width, _rect.size.height);
        rectmask = CGRectMake(0, 25, size, size);
    }
    else
    {
        rect = self.bounds;
        rectmask = CGRectMake(25, 25, size, size);
    }
    
    CALayer *layer = [CALayer layer];
    [layer setBackgroundColor:[UIColor whiteColor].CGColor];
    [layer setFrame:rectmask];
    [layer setCornerRadius:rectmask.size.width / 2];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:rect];
    [image setClipsToBounds:YES];
    [image setContentMode:UIViewContentModeScaleAspectFit];
    [image setImage:[UIImage imageNamed:_site.identifier]];
    [image.layer setMask:layer];
    
    [self addSubview:image];
    
    return self;
}

-(void)drawRect:(CGRect)_rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 10);
    CGContextSetStrokeColorWithColor(context, self.tintColor.CGColor);
    CGContextSetFillColorWithColor(context, self.tintColor.CGColor);
    CGContextAddEllipseInRect(context, CGRectMake(17, 17, _rect.size.width - 34, _rect.size.height - 34));
    CGContextDrawPath(context, kCGPathStroke);
    
    if(triangle)
    {
        CGContextMoveToPoint(context, (_rect.size.width / 2) - 7, _rect.size.height - 10);
        CGContextAddLineToPoint(context, _rect.size.width / 2, _rect.size.height - 2);
        CGContextAddLineToPoint(context, (_rect.size.width / 2) + 7, _rect.size.height - 10);
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFill);
    }
}

#pragma mark public

-(void)hover:(BOOL)_selected
{
    if(_selected)
    {
        [self setTintColor:colorsecond];
        [self setAlpha:1];
    }
    else
    {
        [self setTintColor:[UIColor clearColor]];
        [self setAlpha:0.2];
    }
    
    [self setNeedsDisplay];
}

@end

@implementation vicountryshower
{
    NSTimer *timer;
    CGRect recttitleshown;
    CGRect recttitlehidden;
}

@synthesize flag;
@synthesize title;

+(void)showcurrent
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notclosecountryshower object:nil];
    
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [[ctrmain sha].view.superview addSubview:[[vicountryshower alloc] init]];
                   });
}

-(vicountryshower*)init
{
    self = [super initWithFrame:screenrect];
    [self setClipsToBounds:YES];
    [self setAlpha:0];
    [self setUserInteractionEnabled:NO];
    
    NSInteger titleheight = 70;
    NSInteger flagsize = 60;
    NSInteger flagsize_2 = flagsize / 2;
    NSInteger flagborder = flagsize + 10;
    NSInteger flagborder_2 = flagborder / 2;
    NSInteger addbig = 60;
    NSInteger addbig_2 = addbig / 2;
    NSInteger bigflagsize = flagsize + addbig;
    NSInteger bigflagsize_2 = bigflagsize / 2;
    
    recttitlehidden = CGRectMake(0, -titleheight, screenwidth, titleheight);
    recttitleshown = CGRectMake(0, 0, screenwidth, titleheight);
    
    UILabel *strongtitle = [[UILabel alloc] initWithFrame:recttitlehidden];
    title = strongtitle;
    [title setBackgroundColor:colorsecond];
    [title setUserInteractionEnabled:NO];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setFont:[UIFont fontWithName:fontboldname size:22]];
    [title setText:[modsettings sha].site.name];
    [title setTextColor:[UIColor whiteColor]];
    
    CALayer *layer = [CALayer layer];
    [layer setBackgroundColor:[UIColor whiteColor].CGColor];
    [layer setFrame:CGRectMake(addbig_2, addbig_2, flagsize, flagsize)];
    [layer setCornerRadius:flagsize_2];
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake((screenwidth - flagborder) / 2, (screenheight - flagborder) / 2, flagborder, flagborder)];
    [border setBackgroundColor:[UIColor blackColor]];
    [border setClipsToBounds:YES];
    [border setUserInteractionEnabled:NO];
    [border.layer setCornerRadius:flagborder_2];
    
    UIImageView *strongflag = [[UIImageView alloc] initWithFrame:CGRectMake(screenwidth_2 - bigflagsize_2, screenheight_2 - bigflagsize_2, bigflagsize, bigflagsize)];
    flag = strongflag;
    [flag setClipsToBounds:YES];
    [flag setContentMode:UIViewContentModeScaleAspectFit];
    [flag setImage:[UIImage imageNamed:[modsettings sha].site.identifier]];
    [flag.layer setMask:layer];
    
    if(applicationios == ioslevel7)
    {
        [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.95]];
    }
    else
    {
        UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        [blur setFrame:screenrect];
        
        UIView *blurbase = [[UIView alloc] initWithFrame:screenrect];
        [blurbase setAlpha:0.8];
        [blurbase setUserInteractionEnabled:NO];
        [blurbase addSubview:blur];
        
        [self addSubview:blurbase];
    }
    
    [self addSubview:border];
    [self addSubview:title];
    [self addSubview:flag];
    [self animateshow];
    
    return self;
}

#pragma mark animations

-(void)animatehide
{
    [UIView animateWithDuration:0.3 animations:
     ^(void)
     {
         [self setAlpha:0];
         [title setFrame:recttitlehidden];
     } completion:
     ^(BOOL _done)
     {
         [self removeFromSuperview];
     }];
}

-(void)animateshow
{
    [UIView animateWithDuration:0.2 animations:
     ^(void)
     {
         [self setAlpha:1];
     } completion:
     ^(BOOL _done)
     {
         [UIView animateWithDuration:0.25 animations:
          ^(void)
          {
              [title setFrame:recttitleshown];
          } completion:
          ^(BOOL _done)
          {
              timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeout) userInfo:nil repeats:NO];
          }];
     }];
}

#pragma mark functionality

-(void)timeout
{
    [timer invalidate];
    [self animatehide];
}

@end