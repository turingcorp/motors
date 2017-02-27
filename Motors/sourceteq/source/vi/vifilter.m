#import "vifilter.h"

@implementation vifilter
{
    NSString *celpicker;
}

@synthesize visor;
@synthesize filters;
@synthesize collection;
@synthesize changed;

+(void)show:(modfilters*)_filters
{
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [[vimaster sha] addSubview:[[vifilter alloc] init:_filters]];
                   });
}

-(vifilter*)init:(modfilters*)_filters
{
    self = [super initWithFrame:screenrect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setAlpha:0];

    filters = _filters;
    changed = NO;
    celpicker = @"celpicker";
    
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
    
    vifiltervisor *strongvisor = [[vifiltervisor alloc] init:self];
    visor = strongvisor;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setHeaderReferenceSize:CGSizeMake(screenwidth, 60)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:1];
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flow setSectionInset:UIEdgeInsetsMake(0, 0, 40, 0)];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 70, screenwidth, screenheight - 70) collectionViewLayout:flow];
    collection = strongcollection;
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setClipsToBounds:YES];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:YES];
    [collection setAlwaysBounceVertical:YES];
    [collection setDelegate:self];
    [collection setDataSource:self];
    [collection registerClass:[vifiltercel class] forCellWithReuseIdentifier:celid];
    [collection registerClass:[vifiltercelpicker class] forCellWithReuseIdentifier:celpicker];
    [collection registerClass:[vifilterheader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerid];
    [collection registerClass:[vifilterfooter class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerid];
    [collection setAllowsMultipleSelection:YES];
    
    [self addSubview:collection];
    [self addSubview:visor];
    [self animateshow];
    [self refresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifiedupdatefilters) name:notupdatefilters object:nil];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark notified

-(void)notifiedupdatefilters
{
    [self refresh];
}

#pragma mark animations

-(CGSize)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout referenceSizeForFooterInSection:(NSInteger)_section
{
    NSInteger height = 200;
    
    if([[filters filter:_section] count])
    {
        height = 0;
    }
    
    return CGSizeMake(screenwidth, height);
}

-(void)animateshow
{
    [UIView animateWithDuration:0.35 animations:
     ^(void)
     {
         [self setAlpha:1];
     }];
}

-(void)animatehide
{
    if(changed)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:notfilterschanged object:nil];
    }
    
    [UIView animateWithDuration:0.25 animations:
     ^(void)
     {
         [self setAlpha:0];
     } completion:
     ^(BOOL _done)
     {
         [self removeFromSuperview];
     }];
}

#pragma mark functionality

-(void)refresh
{
    dispatch_async(dispatch_get_main_queue(),
                   ^(void)
                   {
                       [collection reloadData];
                       [self selectindexes];
                   });
}

-(void)selectindexes
{
    NSInteger qty = [filters count];
    
    for(NSInteger i = 0; i < qty; i++)
    {
        modfilter *infilter = [filters filter:i];
        NSInteger index = 0;
        
        if(infilter.selected)
        {
            index = [infilter indexof:infilter.selected] + 1;
        }
        
        [collection selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:i] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

#pragma mark public

-(void)close
{
    [self animatehide];
}

#pragma mark -
#pragma mark col del

-(CGSize)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout sizeForItemAtIndexPath:(NSIndexPath*)_index
{
    NSInteger height = 0;
    
    switch([filters filter:_index.section].component)
    {
        case filtercomcat:
        case filtercomloc:
        
            height = 50;
            
            break;
            
        case filtercomyear:
            
            height = 65;
            
            break;
    }
    
    return CGSizeMake(screenwidth, height);
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return [filters count];
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    modfilter *infilter = [filters filter:_section];
    NSInteger items = 0;
    
    switch(infilter.component)
    {
        case filtercomcat:
        case filtercomloc:
            
            items = [infilter count];
            
            if(items)
            {
                items++;
            }
            
            break;
            
        case filtercomyear:
            
            if([infilter count])
            {
                items = 1;
            }
            
            break;
    }
    
    return items;
}

-(UICollectionReusableView*)collectionView:(UICollectionView*)_col viewForSupplementaryElementOfKind:(NSString*)_kind atIndexPath:(NSIndexPath*)_index
{
    UICollectionReusableView *reusable;
    
    if(_kind == UICollectionElementKindSectionHeader)
    {
        reusable = [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:headerid forIndexPath:_index];
        [(vifilterheader*)reusable config:[filters filter:_index.section]];
    }
    else
    {
        reusable = [_col dequeueReusableSupplementaryViewOfKind:_kind withReuseIdentifier:footerid forIndexPath:_index];
    }
    
    return reusable;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    NSInteger section = _index.section;
    NSInteger item = _index.item;
    
    UICollectionViewCell *cel;
    modfilter *infilter = [filters filter:section];
    
    switch(infilter.component)
    {
        case filtercomcat:
        case filtercomloc:
            
            cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
            
            if(item)
            {
                item--;
                [(vifiltercel*)cel config:[infilter element:item]];
            }
            else
            {
                [(vifiltercel*)cel configtitle:infilter.defaulttitle];
            }
            
            break;
            
        case filtercomyear:
            
            cel = [_col dequeueReusableCellWithReuseIdentifier:celpicker forIndexPath:_index];
            [(vifiltercelpicker*)cel config:self filter:infilter];
            
            break;
    }
    
    return cel;
}

-(BOOL)collectionView:(UICollectionView*)_col shouldSelectItemAtIndexPath:(NSIndexPath*)_index
{
    BOOL selectable = YES;
    NSInteger section = _index.section;
    
    switch([filters filter:section].component)
    {
        case filtercomcat:
        case filtercomloc:
            break;
            
        case filtercomyear:
            
            selectable = NO;
            
            break;
    }

    return selectable;
}

-(void)collectionView:(UICollectionView*)_col didSelectItemAtIndexPath:(NSIndexPath*)_index
{
    NSInteger section = _index.section;
    NSInteger item  = _index.item;
    
    modfilter *infilter = [filters filter:section];
    
    if(item)
    {
        infilter.selected = [infilter element:item - 1];
    }
    else
    {
        infilter.selected = nil;
    }
    
    [self refresh];
    changed = YES;
}

@end

@implementation vifilterheader

@synthesize lbl;

-(vifilterheader*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setUserInteractionEnabled:NO];
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, _rect.size.width, _rect.size.height)];
    lbl = stronglbl;
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setFont:[UIFont fontWithName:fontname size:19]];
    [lbl setTextColor:[UIColor blackColor]];
    
    [self addSubview:lbl];
    
    return self;
}

#pragma mark public

-(void)config:(modfilter*)_filter
{
    NSString *str;
    
    switch(_filter.component)
    {
        case filtercomcat:
            
            str = NSLocalizedString(@"filters_title_category", nil);
            
            break;
            
        case filtercomloc:
            
            str = NSLocalizedString(@"filters_title_location", nil);
            
            break;
            
        case filtercomyear:
            
            str = NSLocalizedString(@"filters_title_year", nil);
            
            break;
    }
    
    [lbl setText:str];
}

@end

@implementation vifilterfooter

-(vifilterfooter*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self addSubview:[[spinner alloc] init:_rect.size.width / 2 y:_rect.size.height / 2]];
    
    return self;
}

@end

@implementation vifiltercel

@synthesize lbl;

-(vifiltercel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, _rect.size.width - 20, _rect.size.height)];
    lbl = stronglbl;
    [lbl setUserInteractionEnabled:NO];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setFont:[UIFont fontWithName:fontboldname size:13]];
    
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
        [self setBackgroundColor:colormain];
        [lbl setTextColor:[UIColor colorWithWhite:0 alpha:0.7]];
    }
    else
    {
        [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
        [lbl setTextColor:[UIColor colorWithWhite:0 alpha:0.4]];
    }
}

#pragma mark public

-(void)config:(modfilterelement*)_element
{
    [self hover];
    [lbl setText:_element.valuename];
}

-(void)configtitle:(NSString*)_title
{
    [self hover];
    [lbl setText:_title];
}

@end

@implementation vifiltercelpicker
{
    BOOL trackscroll;
}

@synthesize main;
@synthesize filter;
@synthesize collection;

-(vifiltercelpicker*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
    
    NSInteger width = _rect.size.width;
    NSInteger height = _rect.size.height;
    NSInteger itemwidth = 70;
    NSInteger margin = (width / 2) - (itemwidth / 2);
    trackscroll = NO;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setFooterReferenceSize:CGSizeZero];
    [flow setHeaderReferenceSize:CGSizeZero];
    [flow setItemSize:CGSizeMake(itemwidth, height)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:0];
    [flow setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flow setSectionInset:UIEdgeInsetsMake(0, margin, 0, margin)];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection = strongcollection;
    [collection setClipsToBounds:YES];
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setAlwaysBounceHorizontal:YES];
    [collection setDelegate:self];
    [collection setDataSource:self];
    [collection registerClass:[vifiltercelpickercel class] forCellWithReuseIdentifier:celid];
    
    [self addSubview:collection];
    
    return self;
}

#pragma mark functionality

-(void)synthselect
{
    NSInteger item;
    
    if(filter.selected)
    {
        item = [filter indexof:filter.selected];
    }
    else
    {
        item = [filter count];
    }
    
    [collection selectItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}

-(void)postselect:(NSIndexPath*)_index
{
    main.changed = YES;
    NSInteger item = _index.item;
    
    if(item < [filter count])
    {
        filter.selected = [filter element:item];
    }
    else
    {
        filter.selected = nil;
    }
}

#pragma mark public

-(void)config:(vifilter*)_main filter:(modfilter*)_filter
{
    main = _main;
    filter = _filter;
    [collection reloadData];
    [self synthselect];
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
        CGFloat leftoffset = collection.contentOffset.x;
        
        CGPoint point = CGPointMake(leftoffset + screenwidth_2, 0);
        NSIndexPath *index = [collection indexPathForItemAtPoint:point];
        
        if(index)
        {
            [self postselect:index];
            [collection selectItemAtIndexPath:index animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
}

#pragma mark col del

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    NSInteger items = [filter count];
    
    if(items)
    {
        items++;
    }
    
    return items;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    vifiltercelpickercel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    
    NSInteger item = _index.item;
    
    if(item < [filter count])
    {
        [cel config:[filter element:item]];
    }
    else
    {
        [cel configtitle:filter.defaulttitle];
    }
    
    return cel;
}


-(void)collectionView:(UICollectionView*)_col didSelectItemAtIndexPath:(NSIndexPath*)_index
{
    [collection scrollToItemAtIndexPath:_index atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self postselect:_index];
    trackscroll = NO;
}

@end

@implementation vifiltercelpickercel

@synthesize lbl;

-(vifiltercelpickercel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    
    UILabel *stronglbl = [[UILabel alloc] initWithFrame:self.bounds];
    lbl = stronglbl;
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setUserInteractionEnabled:NO];
    [lbl setFont:[UIFont fontWithName:fontboldname size:13]];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    
    [self addSubview:lbl];
    
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
        [self setBackgroundColor:colormain];
        [lbl setTextColor:[UIColor blackColor]];
    }
    else
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [lbl setTextColor:[UIColor colorWithWhite:0 alpha:0.3]];
    }
}

#pragma mark public

-(void)config:(modfilterelement*)_element
{
    [lbl setText:_element.valuename];
    [self hover];
}

-(void)configtitle:(NSString*)_title
{
    [lbl setText:_title];
    [self hover];
}

@end

@implementation vifiltervisor

@synthesize filter;

-(vifiltervisor*)init:(vifilter*)_filter
{
    self = [super initWithFrame:CGRectMake(0, 0, screenwidth, 70)];
    [self setClipsToBounds:YES];
    
    filter = _filter;
    
    UIButton *btnclose = [[UIButton alloc] initWithFrame:CGRectMake(0, 25, 65, 35)];
    [btnclose setImage:[[UIImage imageNamed:@"backlist"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [btnclose setImage:[[UIImage imageNamed:@"backlist"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    [btnclose.imageView setTintColor:[UIColor colorWithWhite:0 alpha:0.1]];
    [btnclose.imageView setClipsToBounds:YES];
    [btnclose.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnclose setClipsToBounds:YES];
    [btnclose addTarget:self action:@selector(actionclose) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(0, 69, screenwidth, 1)];
    [border setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
    [border setUserInteractionEnabled:NO];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, screenwidth, 55)];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setFont:[UIFont fontWithName:fontboldname size:16]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setUserInteractionEnabled:NO];
    [title setTextColor:[UIColor blackColor]];
    [title setText:NSLocalizedString(@"filters_title", nil)];
    
    [self addSubview:border];
    [self addSubview:title];
    [self addSubview:btnclose];
    
    return self;
}

#pragma mark actions

-(void)actionclose
{
    [filter close];
}

@end

@implementation vifilterbar

@synthesize btnfilter;
@synthesize filters;
@synthesize btnquery;
@synthesize barfield;

-(vifilterbar*)init
{
    self = [super initWithFrame:CGRectMake(0, 0, screenwidth, barheight)];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    vifilterbarfield *strongbarfield = [[vifilterbarfield alloc] init];
    barfield = strongbarfield;
    [barfield.field setDelegate:self];
    
    UIButton *strongbtnfilter = [[UIButton alloc] initWithFrame:CGRectMake(screenwidth_2 - 37, 30, 74, 40)];
    btnfilter = strongbtnfilter;
    [btnfilter addTarget:self action:@selector(actionfilter) forControlEvents:UIControlEventTouchUpInside];
    [btnfilter setImage:[[UIImage imageNamed:@"filters"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [btnfilter setImage:[[UIImage imageNamed:@"filters"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    [btnfilter.imageView setClipsToBounds:YES];
    [btnfilter.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnfilter.imageView setTintColor:[UIColor colorWithWhite:0 alpha:0.1]];
    
    UIButton *strongbtnquery = [[UIButton alloc] initWithFrame:CGRectMake(screenwidth - 60, 30, 60, 40)];
    btnquery = strongbtnquery;
    [btnquery addTarget:self action:@selector(actionquery) forControlEvents:UIControlEventTouchUpInside];
    [btnquery setImage:[[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [btnquery setImage:[[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
    [btnquery.imageView setClipsToBounds:YES];
    [btnquery.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnquery.imageView setTintColor:[UIColor colorWithWhite:0 alpha:0.1]];
    
    [self addSubview:btnfilter];
    [self addSubview:btnquery];
    [self addSubview:barfield];
    
    return self;
}

#pragma mark actions

-(void)actionquery
{
    [[analytics singleton] screen:@"Search query"];
    
    if([modsettings sha].searchquery)
    {
        [barfield.field setText:[modsettings sha].searchquery];
    }
    else
    {
        [barfield.field setText:@""];
    }
    
    [barfield show];
    
    [UIView animateWithDuration:0.3 animations:
     ^(void)
     {
         [btnquery setAlpha:0];
         [btnfilter setAlpha:0];
     }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 400), dispatch_get_main_queue(),
                   ^(void)
                   {
                       [barfield.field becomeFirstResponder];
                   });
}

-(void)actionfilter
{
    [[analytics singleton] screen:@"Filters"];
    
    [vifilter show:filters];
}

#pragma mark -
#pragma mark field del

-(void)textFieldDidEndEditing:(UITextField*)_field
{
    [barfield hide];
    
    [UIView animateWithDuration:0.6 animations:
     ^(void)
     {
         [btnquery setAlpha:1];
         [btnfilter setAlpha:1];
     }];
}

-(BOOL)textFieldShouldReturn:(UITextField*)_field
{
    [[modsettings sha] editquery:_field.text];
    [_field resignFirstResponder];
    
    return YES;
}

@end

@implementation vifilterbarfield
{
    CGRect initialrect;
    CGRect finalrect;
}

@synthesize field;

-(vifilterbarfield*)init
{
    NSInteger height = barheight - 35;
    
    self = [super initWithFrame:CGRectMake(screenwidth - 16, 28, 6, height)];
    [self setClipsToBounds:YES];
    [self setAlpha:0];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self.layer setCornerRadius:3];
    [self.layer setBorderWidth:1];
    [self.layer setBorderColor:[UIColor colorWithWhite:0 alpha:0.2].CGColor];
    
    initialrect = self.frame;
    finalrect = CGRectMake(screenwidth - 210, 28, 200, height);
    
    UITextField *strongfield = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, 185, height)];
    field = strongfield;
    [field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [field setBackgroundColor:[UIColor clearColor]];
    [field setBorderStyle:UITextBorderStyleNone];
    [field setClearButtonMode:UITextFieldViewModeNever];
    [field setClearsOnBeginEditing:NO];
    [field setClearsOnInsertion:NO];
    [field setFont:[UIFont fontWithName:fontname size:20]];
    [field setKeyboardAppearance:UIKeyboardAppearanceLight];
    [field setKeyboardType:UIKeyboardTypeAlphabet];
    [field setPlaceholder:NSLocalizedString(@"search_field_placeholder", nil)];
    [field setReturnKeyType:UIReturnKeySearch];
    [field setSpellCheckingType:UITextSpellCheckingTypeNo];
    [field setTextColor:[UIColor blackColor]];
    [field setTintColor:[UIColor blackColor]];
    
    UIView *accessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenwidth, 47)];
    
    UIButton *btncancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, screenwidth - 140, 47)];
    [btncancel setBackgroundColor:[UIColor colorWithRed:1 green:0.1 blue:0 alpha:1]];
    [btncancel setClipsToBounds:YES];
    [btncancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btncancel setTitleColor:[UIColor colorWithWhite:1 alpha:0.2] forState:UIControlStateHighlighted];
    [btncancel setTitle:NSLocalizedString(@"search_btncancel", nil) forState:UIControlStateNormal];
    [btncancel.titleLabel setFont:[UIFont fontWithName:fontboldname size:15]];
    [btncancel addTarget:self action:@selector(actioncancel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnsearch = [[UIButton alloc] initWithFrame:CGRectMake(screenwidth - 140, 0, 140, 47)];
    [btnsearch setBackgroundColor:colorsecond];
    [btnsearch setClipsToBounds:YES];
    [btnsearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnsearch setTitleColor:[UIColor colorWithWhite:1 alpha:0.2] forState:UIControlStateHighlighted];
    [btnsearch setTitle:NSLocalizedString(@"search_btnsearch", nil) forState:UIControlStateNormal];
    [btnsearch.titleLabel setFont:[UIFont fontWithName:fontboldname size:15]];
    [btnsearch addTarget:self action:@selector(actionsearch) forControlEvents:UIControlEventTouchUpInside];
    
    [accessory addSubview:btncancel];
    [accessory addSubview:btnsearch];
    
    [field setInputAccessoryView:accessory];
    
    [self addSubview:field];
    
    return self;
}

#pragma mark actions

-(void)actioncancel
{
    [[modsettings sha] editquery:nil];
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [field setText:@""];
}

-(void)actionsearch
{
    [[modsettings sha] editquery:field.text];
    [field resignFirstResponder];
}

#pragma mark public

-(void)show
{
    [UIView animateWithDuration:0.2 animations:
     ^(void)
     {
         [self setAlpha:1];
     } completion:
     ^(BOOL _done)
     {
         [UIView animateWithDuration:0.3 animations:
          ^(void)
          {
              [self setFrame:finalrect];
          }];
     }];
}

-(void)hide
{
    [UIView animateWithDuration:0.3 animations:
     ^(void)
     {
         [self setFrame:initialrect];
         [self setAlpha:0];
     }];
}

@end
