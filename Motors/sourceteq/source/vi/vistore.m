#import "vistore.h"

@implementation vistore

@synthesize visor;
@synthesize spin;
@synthesize collection;
@synthesize lbl;

-(vistore*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor whiteColor]];
    
    NSInteger width = _rect.size.width;
    NSInteger height = _rect.size.height;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setFooterReferenceSize:CGSizeMake(width, 60)];
    [flow setHeaderReferenceSize:CGSizeMake(width, 110)];
    [flow setItemSize:CGSizeMake(width, 60)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:0];
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flow setSectionInset:UIEdgeInsetsZero];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection = strongcollection;
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setAlwaysBounceVertical:YES];
    [collection setDataSource:self];
    [collection setDelegate:self];
    [collection registerClass:[vistorecel class] forCellWithReuseIdentifier:celid];
    [collection registerClass:[vistoreheader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerid];
    [collection registerClass:[vistorefooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerid];
    [collection setHidden:YES];
    
    vistorevisor *strongvisor = [[vistorevisor alloc] initWithFrame:CGRectMake(0, 0, width, 70)];
    visor = strongvisor;
    [visor setHidden:YES];
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, width - 40, height)];
    lbl = stronglbl;
    [lbl setUserInteractionEnabled:NO];
    [lbl setNumberOfLines:0];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setFont:[UIFont fontWithName:fontname size:18]];
    [lbl setTextColor:[UIColor colorWithWhite:0 alpha:0.7]];
    
    spinner *strongspin = [[spinner alloc] init:width / 2 y:height / 2];
    spin = strongspin;
    
    [self addSubview:collection];
    [self addSubview:visor];
    [self addSubview:lbl];
    [self addSubview:spin];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedupdatepurchases) name:notpurchaseupd object:nil];
    [[skman sha] checkavailabilities];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)notifiedupdatepurchases
{
    [self refresh];
}

#pragma mark functionality

-(void)refresh
{
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [spin removeFromSuperview];
                       [visor setHidden:NO];
                       
                       if([skman sha].error)
                       {
                           [lbl setText:[skman sha].error];
                           [lbl setHidden:NO];
                           [collection setHidden:YES];
                       }
                       else
                       {
                           [lbl setText:@""];
                           [lbl setHidden:YES];
                           [collection setHidden:NO];
                           [collection reloadData];
                       }
                   });
}

#pragma mark -
#pragma mark col del

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return [[modperks sha] count];
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    return 1;
}

-(UICollectionReusableView*)collectionView:(UICollectionView*)_col viewForSupplementaryElementOfKind:(NSString*)_kind atIndexPath:(NSIndexPath*)_index
{
    UICollectionReusableView<vistoreperk> *reusable;
    
    if(_kind == UICollectionElementKindSectionHeader)
    {
        reusable = [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:headerid forIndexPath:_index];
    }
    else
    {
        reusable = [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:footerid forIndexPath:_index];
    }
    
    [reusable config:[[modperks sha] perk:_index.section]];
    
    return reusable;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    vistorecel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    [cel config:[[modperks sha] perk:_index.item]];
    
    return cel;
}

@end

@implementation vistorevisor

-(vistorevisor*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    
    NSInteger width = _rect.size.width;
    NSInteger height = _rect.size.height;
    
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
    
    UIButton *restore = [[UIButton alloc] initWithFrame:CGRectMake(width - 200, 15, 185, height - 30)];
    [restore setBackgroundColor:colorsecond];
    [restore setClipsToBounds:YES];
    [restore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [restore setTitleColor:[UIColor colorWithWhite:1 alpha:0.1] forState:UIControlStateHighlighted];
    [restore setTitle:NSLocalizedString(@"store_btn_restore", nil) forState:UIControlStateNormal];
    [restore.titleLabel setFont:[UIFont fontWithName:fontboldname size:14]];
    [restore.layer setCornerRadius:3];
    [restore addTarget:self action:@selector(actionrestore) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, height - 1, width, 1)];
    [border setUserInteractionEnabled:NO];
    [border setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1]];
    
    [self addSubview:restore];
    [self addSubview:border];
    
    return self;
}

#pragma mark actions

-(void)actionrestore
{
    [[skman sha] restorepurchases];
}

@end

@implementation vistoreheader

@synthesize lbl;

-(vistoreheader*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setUserInteractionEnabled:NO];
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, _rect.size.width - 40, 25)];
    lbl = stronglbl;
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setNumberOfLines:0];
    [lbl setTextColor:[UIColor blackColor]];
    [lbl setFont:[UIFont fontWithName:fontboldname size:19]];
    
    [self addSubview:lbl];
    
    return self;
}

#pragma mark perk

-(void)config:(modperkelement*)_perkelement
{
    [lbl setText:NSLocalizedString(_perkelement.title, nil)];
}

@end

@implementation vistorefooter

@synthesize element;
@synthesize spin;
@synthesize lbl;
@synthesize lblpurchased;
@synthesize btnpurchase;

-(vistorefooter*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    NSInteger width = _rect.size.width;
    NSInteger height = _rect.size.height;
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, width, height)];
    lbl = stronglbl;
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setNumberOfLines:0];
    [lbl setTextColor:colorsecond];
    [lbl setFont:[UIFont fontWithName:fontname size:22]];
    
    UILabel *stronglblpurchased = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width - 20, height)];
    lblpurchased = stronglblpurchased;
    [lblpurchased setBackgroundColor:[UIColor clearColor]];
    [lblpurchased setTextAlignment:NSTextAlignmentRight];
    [lblpurchased setFont:[UIFont fontWithName:fontboldname size:15]];
    [lblpurchased setTextColor:colorsecond];
    [lblpurchased setText:NSLocalizedString(@"store_purchased", nil)];
    [lblpurchased setUserInteractionEnabled:NO];
    
    UIButton *strongbtnpurchase = [[UIButton alloc] initWithFrame:CGRectMake(width - 120, 10, 100, height - 20)];
    btnpurchase = strongbtnpurchase;
    [btnpurchase setBackgroundColor:colorsecond];
    [btnpurchase setClipsToBounds:YES];
    [btnpurchase setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnpurchase setTitleColor:[UIColor colorWithWhite:1 alpha:0.1] forState:UIControlStateHighlighted];
    [btnpurchase setTitle:NSLocalizedString(@"store_btn_purchase", nil) forState:UIControlStateNormal];
    [btnpurchase.layer setCornerRadius:4];
    [btnpurchase.titleLabel setFont:[UIFont fontWithName:fontboldname size:15]];
    [btnpurchase addTarget:self action:@selector(actionpurchase) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:lbl];
    [self addSubview:btnpurchase];
    [self addSubview:lblpurchased];
    
    return self;
}

#pragma mark actions

-(void)actionpurchase
{
    [element purchase];
}

#pragma mark functionality

-(void)loadspin
{
    spinner *strongspin = [[spinner alloc] init:btnpurchase.center.x y:btnpurchase.center.y];
    spin = strongspin;
    
    [self addSubview:spin];
}

#pragma mark perk

-(void)config:(modperkelement*)_perkelement
{
    [spin removeFromSuperview];
    
    element = _perkelement;
    [lbl setText:element.pricestr];
    
    BOOL lblhidden = YES;
    BOOL btnhidden = YES;
    
    switch(element.status)
    {
        case perkstatusnew:
            
            btnhidden = NO;
            
            break;
            
        case perkstatuspurchased:
            
            lblhidden = NO;
            
            break;
            
        case perkstatuspurchasing:
            
            [self loadspin];
            
            break;
            
        default:
            break;
    }
    
    [btnpurchase setHidden:btnhidden];
    [lblpurchased setHidden:lblhidden];
}

@end

@implementation vistorecel

@synthesize lbl;

-(vistorecel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setUserInteractionEnabled:NO];
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, _rect.size.width - 40, _rect.size.height)];
    lbl = stronglbl;
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setNumberOfLines:0];
    [lbl setTextColor:[UIColor colorWithWhite:0 alpha:0.7]];
    [lbl setFont:[UIFont fontWithName:fontname size:19]];
    
    [self addSubview:lbl];
    
    return self;
}

#pragma mark perk

-(void)config:(modperkelement*)_perkelement
{
    [lbl setText:NSLocalizedString(_perkelement.descr, nil)];
}

@end