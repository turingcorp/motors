#import "viprices.h"

@implementation viprices

@synthesize header;
@synthesize notavailable;
@synthesize prices;
@synthesize collection;

-(viprices*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor colorWithWhite:0.98 alpha:1]];
    
    NSInteger headerheight = 70;
    NSInteger margin = 6;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setItemSize:CGSizeMake(screenwidth, 55)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:margin];
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flow setSectionInset:UIEdgeInsetsMake(headerheight + margin, 0, 30, 0)];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection = strongcollection;
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setAlwaysBounceVertical:YES];
    [collection setClipsToBounds:YES];
    [collection setDataSource:self];
    [collection setDelegate:self];
    [collection registerClass:[vipricescel class] forCellWithReuseIdentifier:celid];
    [collection registerClass:[vipricesreheader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerid];
    [collection registerClass:[vipricesrefooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerid];
    
    vipricesheader *strongheader = [[vipricesheader alloc] initWithFrame:CGRectMake(0, 0, screenwidth, headerheight) viprices:self];
    header = strongheader;
    
    [self addSubview:collection];
    [self addSubview:header];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedupdateprices) name:notupdateprices object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedrestartprices) name:notrestartprices object:nil];
    
    [self notifiedrestartprices];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark notified

-(void)notifiedupdateprices
{
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [self refresh];
                   });
}

-(void)notifiedrestartprices
{
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [notavailable removeFromSuperview];
                       prices = [[modprices alloc] init];
                       
                       if([[modsettings sha] shouldpricesguide])
                       {
                           [header setHidden:NO];
                           [collection setHidden:NO];
                       }
                       else
                       {
                           vipricesnotavailable *strongnotavailable = [[vipricesnotavailable alloc] initWithFrame:self.bounds];
                           notavailable = strongnotavailable;
                           
                           [self addSubview:notavailable];
                           
                           [header setHidden:YES];
                           [collection setHidden:YES];
                       }
                       
                       [self notifiedupdateprices];
                   });
}

#pragma mark functionality

-(void)refresh
{
    [header refresh];
    [collection reloadData];
    [collection scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

#pragma mark -
#pragma mark col del

-(CGSize)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout referenceSizeForFooterInSection:(NSInteger)_section
{
    NSInteger height = 0;
    
    if(![prices count] && !prices.leaf)
    {
        height = 220;
    }
    
    return CGSizeMake(screenwidth, height);
}

-(CGSize)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout referenceSizeForHeaderInSection:(NSInteger)_section
{
    NSInteger height = 0;
    
    if(prices.leaf)
    {
        height = 330;
    }
    
    return CGSizeMake(screenwidth, height);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    return [prices count];
}

-(UICollectionReusableView*)collectionView:(UICollectionView*)_col viewForSupplementaryElementOfKind:(NSString*)_kind atIndexPath:(NSIndexPath*)_index
{
    UICollectionReusableView *reusable;
    
    if(_kind == UICollectionElementKindSectionHeader)
    {
        reusable = [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:headerid forIndexPath:_index];
        
        if(prices.prevselected.report)
        {
            [(vipricesreheader*)reusable configprice:prices.prevselected.report];
        }
        else
        {
            [(vipricesreheader*)reusable configload];
        }
    }
    else
    {
        reusable = [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:footerid forIndexPath:_index];
        
        if(prices.error)
        {
            [(vipricesrefooter*)reusable showerror:prices.error];
        }
        else
        {
            [(vipricesrefooter*)reusable noerror];
            [prices pull];
        }
    }
    
    return reusable;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    vipricescel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    [cel config:[prices price:_index.item]];
    
    return cel;
}

-(void)collectionView:(UICollectionView*)_col didSelectItemAtIndexPath:(NSIndexPath*)_index
{
    prices.prevselected = [prices price:_index.item];
    [prices pull];
    [self refresh];
}

@end

@implementation vipricesheader

@synthesize prices;
@synthesize lbl;

-(vipricesheader*)initWithFrame:(CGRect)_rect viprices:(viprices*)_viprices
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    
    prices = _viprices;
    
    if(applicationios == ioslevel7)
    {
        [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.97]];
    }
    else
    {
        UIVisualEffectView *blur = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        [blur setFrame:self.bounds];
        [blur setUserInteractionEnabled:NO];
        
        [self addSubview:blur];
    }
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, _rect.size.height - 1, screenwidth, 1)];
    [border setUserInteractionEnabled:NO];
    [border setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:self.bounds];
    lbl = stronglbl;
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setUserInteractionEnabled:NO];
    [lbl setFont:[UIFont fontWithName:fontname size:16]];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    
    [self addSubview:border];
    [self addSubview:lbl];
    [self refresh];
    
    return self;
}

#pragma mark public

-(void)refresh
{
    NSString *str;
    
    if(prices.prices.prevselected)
    {
        str = prices.prices.prevselected.name;
        [lbl setTextColor:[UIColor colorWithWhite:0 alpha:0.9]];
    }
    else
    {
        str = NSLocalizedString(@"prices_nonselected", nil);
        [lbl setTextColor:[UIColor colorWithWhite:0 alpha:0.5]];
    }
    
    [lbl setText:str];
}

@end

@implementation vipricesreheader

@synthesize report;
@synthesize spin;
@synthesize collection;

-(vipricesreheader*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    return self;
}

#pragma mark public

-(void)configprice:(modpricereport*)_pricereport
{
    report = _pricereport;
    [spin removeFromSuperview];
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setFooterReferenceSize:CGSizeMake(screenwidth, 60)];
    [flow setHeaderReferenceSize:CGSizeZero];
    [flow setItemSize:CGSizeMake(screenwidth, 70)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:10];
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flow setSectionInset:UIEdgeInsetsMake(100, 0, 20, 0)];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection = strongcollection;
    [collection setClipsToBounds:YES];
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setScrollEnabled:NO];
    [collection setBounces:NO];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setDelegate:self];
    [collection setDataSource:self];
    [collection registerClass:[vipricesreheadercel class] forCellWithReuseIdentifier:celid];
    [collection registerClass:[vipricesreheaderfooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerid];
    
    [self addSubview:collection];
}

-(void)configload
{
    [collection removeFromSuperview];
    
    spinner *strongspin = [[spinner alloc] init:screenwidth_2 y:self.bounds.size.height / 2];
    spin = strongspin;
    
    [self addSubview:spin];
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

-(UICollectionReusableView*)collectionView:(UICollectionView*)_col viewForSupplementaryElementOfKind:(NSString*)_kind atIndexPath:(NSIndexPath*)_index
{
    return [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:footerid forIndexPath:_index];
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    vipricesreheadercel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];

    switch(_index.item)
    {
        case 0:
            
            [cel config:YES amount:report.max];
            
            break;
            
        case 1:
            
            [cel config:NO amount:report.min];
            
            break;
    }
    
    return cel;
}

@end

@implementation vipricesreheaderfooter

-(vipricesreheaderfooter*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:self.bounds];
    [btn setBackgroundColor:colorsecond];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithWhite:1 alpha:0.1] forState:UIControlStateHighlighted];
    [btn setTitle:NSLocalizedString(@"prices_again", nil) forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont fontWithName:fontboldname size:17]];
    [btn addTarget:self action:@selector(actionrestart) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:btn];
    
    return self;
}

#pragma mark actions

-(void)actionrestart
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notrestartprices object:nil];
}

@end

@implementation vipricesreheadercel

@synthesize icon;
@synthesize lbl;

-(vipricesreheadercel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setUserInteractionEnabled:NO];
    
    NSInteger width = _rect.size.width;
    NSInteger height = _rect.size.height;
    
    UIImageView *strongicon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 30, height)];
    icon = strongicon;
    [icon setClipsToBounds:YES];
    [icon setContentMode:UIViewContentModeScaleAspectFit];
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:CGRectMake(45, 0, width - 45, height)];
    lbl = stronglbl;
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setFont:[UIFont fontWithName:fontname size:24]];
    [lbl setTextColor:[UIColor blackColor]];
    
    [self addSubview:lbl];
    [self addSubview:icon];
    
    return self;
}

#pragma mark public

-(void)config:(BOOL)_max amount:(double)_amount
{
    UIColor *tintcolor;
    NSString *imagename;
    NSString *amnum = [[tools sha] pricetostring:@(_amount)];
    
    if(_max)
    {
        tintcolor = colorsecond;
        imagename = @"maxprice";
    }
    else
    {
        tintcolor = [UIColor colorWithRed:1 green:0.2 blue:0 alpha:1];
        imagename = @"minprice";
    }
    
    [icon setImage:[[UIImage imageNamed:imagename] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [icon setTintColor:tintcolor];
    [lbl setText:amnum];
}

@end

@implementation vipricesrefooter

@synthesize view;

-(vipricesrefooter*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setUserInteractionEnabled:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    
    return self;
}

#pragma mark public

-(void)showerror:(NSString*)_error
{
    [view removeFromSuperview];
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:self.bounds];
    view = stronglbl;
    [stronglbl setBackgroundColor:[UIColor clearColor]];
    [stronglbl setFont:[UIFont fontWithName:fontname size:15]];
    [stronglbl setNumberOfLines:0];
    [stronglbl setTextColor:[UIColor colorWithWhite:0 alpha:0.7]];
    [stronglbl setText:_error];
    [stronglbl setTextAlignment:NSTextAlignmentCenter];
    
    [self addSubview:view];
}

-(void)noerror
{
    [view removeFromSuperview];
    
    UIView *strongview = [[spinner alloc] init:screenwidth_2 y:self.bounds.size.height / 2];
    view = strongview;
    
    [self addSubview:view];
}

@end

@implementation vipricescel

@synthesize lbl;

-(vipricescel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, screenwidth - 40, _rect.size.height)];
    lbl = stronglbl;
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setUserInteractionEnabled:NO];
    [lbl setFont:[UIFont fontWithName:fontboldname size:15]];
    
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

-(void)hover
{
    if(self.isSelected || self.isHighlighted)
    {
        [self setBackgroundColor:colormain];
        [lbl setTextColor:[UIColor colorWithWhite:0 alpha:0.85]];
    }
    else
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        [lbl setTextColor:[UIColor colorWithWhite:0 alpha:0.45]];
    }
}

#pragma mark public

-(void)config:(modprice*)_price
{
    [lbl setText:_price.name];
    [self hover];
}

@end

@implementation vipricesnotavailable

-(vipricesnotavailable*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    NSInteger width = _rect.size.width;
    
    UILabel *lblwarning = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, width - 40, 250)];
    [lblwarning setBackgroundColor:[UIColor clearColor]];
    [lblwarning setFont:[UIFont fontWithName:fontname size:20]];
    [lblwarning setTextColor:[UIColor colorWithWhite:0 alpha:0.9]];
    [lblwarning setTextAlignment:NSTextAlignmentCenter];
    [lblwarning setNumberOfLines:0];
    [lblwarning setText:NSLocalizedString(@"prices_notavailable", nil)];
    [lblwarning setUserInteractionEnabled:NO];
    
    UIButton *btnpurchase = [[UIButton alloc] initWithFrame:CGRectMake((width - 140) / 2, 300, 140, 37)];
    [btnpurchase setBackgroundColor:colorsecond];
    [btnpurchase setClipsToBounds:YES];
    [btnpurchase setTitle:NSLocalizedString(@"prices_btn_purchase", nil) forState:UIControlStateNormal];
    [btnpurchase setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnpurchase setTitleColor:[UIColor colorWithWhite:1 alpha:0.1] forState:UIControlStateHighlighted];
    [btnpurchase.titleLabel setFont:[UIFont fontWithName:fontboldname size:16]];
    [btnpurchase.layer setCornerRadius:4];
    [btnpurchase addTarget:self action:@selector(actionstore) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:lblwarning];
    [self addSubview:btnpurchase];
    
    return self;
}

#pragma mark actions

-(void)actionstore
{
    [[vimaster sha] opensection:appsectionstore];
}

@end