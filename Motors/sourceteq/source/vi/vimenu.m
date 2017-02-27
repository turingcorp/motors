#import "vimenu.h"

@implementation vimenu
{
    NSInteger sections;
}

@synthesize collection;

-(vimenu*)init
{
    self = [super initWithFrame:CGRectMake(0, 0, menuwidth, screenheight)];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:1]];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    sections = 5;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setFooterReferenceSize:CGSizeZero];
    [flow setHeaderReferenceSize:CGSizeZero];
    [flow setItemSize:CGSizeMake(menuwidth, 60)];
    [flow setSectionInset:UIEdgeInsetsMake(20, 0, 30, 0)];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:0];
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collection = strongcollection;
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setClipsToBounds:YES];
    [collection setAlwaysBounceVertical:YES];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setDelegate:self];
    [collection setDataSource:self];
    [collection registerClass:[vimenucel class] forCellWithReuseIdentifier:celid];
    [collection setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(menuwidth - 1, 0, 1, screenheight)];
    [border setUserInteractionEnabled:NO];
    [border setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.2]];
    
    [self addSubview:border];
    [self addSubview:collection];
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark notified

-(void)notifiedupdatemenu
{
    
}

#pragma mark functionality

#pragma mark public

-(void)opensection:(appsection)_section
{
    NSInteger item = 0;
    
    switch(_section)
    {
        case appsectionaccount:
            
            break;
            
        case appsectionpricesguide:
            
            item = 2;
            
            break;
            
        case appsectionfavorites:
            
            item = 1;
            
            break;
            
        case appsectionlistings:
            
            break;
            
        case appsectionphotocenters:
            
            break;
            
        case appsectionsettings:
            
            item = 3;
            
            break;
            
        case appsectionstore:
            
            item = 4;
            
            break;
            
        case appsectionsearch:
        case appsectionnone:
            break;
    }
    
    [collection selectItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark -
#pragma mark col del

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)_col
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)_col numberOfItemsInSection:(NSInteger)_section
{
    return sections;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    appsection section = appsectionnone;
    vimenucel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];

    switch(_index.item)
    {
        case 0:
            
            section = appsectionsearch;
            
            break;
            
        case 1:
            
            section = appsectionfavorites;
            
            break;
            
        case 2:
            
            section = appsectionpricesguide;
            
            break;
            
        case 3:
            
            section = appsectionsettings;
            
            break;
            
        case 4:
            
            section = appsectionstore;
            
            break;
    }
    
    [cel config:section];
    
    return cel;
}

-(void)collectionView:(UICollectionView*)_col didSelectItemAtIndexPath:(NSIndexPath*)_index
{
    appsection section = [(vimenucel*)[_col cellForItemAtIndexPath:_index] section];
    [[vimaster sha] hidemenu];
    [[vimaster sha] opensection:section];
}

@end

@implementation vimenucel

@synthesize indicator;
@synthesize icon;
@synthesize lbl;
@synthesize section;

-(vimenucel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGFloat height = _rect.size.height;
    UIView *strongindicator = [[UIView alloc] initWithFrame:CGRectMake(menuwidth - 4, 0, 4, height)];
    indicator = strongindicator;
    [indicator setUserInteractionEnabled:NO];
    [indicator setAutoresizingMask:UIViewAutoresizingFlexibleHeight];

    UILabel *stronglbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, menuwidth - 50, height)];
    lbl = stronglbl;
    [lbl setTextAlignment:NSTextAlignmentRight];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setFont:[UIFont fontWithName:fontboldname size:15]];
    [lbl setUserInteractionEnabled:NO];
    [lbl setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    UIImageView *strongicon = [[UIImageView alloc] initWithFrame:CGRectMake(menuwidth - 45, 0, 36, height)];
    icon = strongicon;
    [icon setUserInteractionEnabled:NO];
    [icon setClipsToBounds:YES];
    [icon setContentMode:UIViewContentModeScaleAspectFit];
    [icon setTintColor:[UIColor colorWithWhite:1 alpha:0.2]];
    
    [self addSubview:indicator];
    [self addSubview:icon];
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
        [indicator setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.1]];
        [self setBackgroundColor:colorsecond];
        
        [lbl setTextColor:[UIColor whiteColor]];
        [icon setTintColor:[UIColor colorWithWhite:1 alpha:0.9]];
    }
    else
    {
        [indicator setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:[UIColor clearColor]];
        
        [lbl setTextColor:[UIColor colorWithWhite:1 alpha:0.5]];
        [icon setTintColor:[UIColor colorWithWhite:1 alpha:0.2]];
    }
}

#pragma mark public

-(void)config:(appsection)_section
{
    NSString *str;
    NSString *iconname;
    section = _section;
    
    switch(section)
    {
        case appsectionsearch:
            
            str = NSLocalizedString(@"menu_search", nil);
            iconname = @"search";
            
            break;
            
        case appsectionaccount:
            
            str = NSLocalizedString(@"menu_account", nil);
            
            break;
            
        case appsectionfavorites:
            
            str = NSLocalizedString(@"menu_favorites", nil);
            iconname = @"like";
            
            break;
            
        case appsectionlistings:
            
            str = NSLocalizedString(@"menu_listings", nil);
            
            break;
            
        case appsectionphotocenters:
            
            str = NSLocalizedString(@"menu_photocenters", nil);
            
            break;
            
        case appsectionsettings:
            
            str = NSLocalizedString(@"menu_settings", nil);
            iconname = @"settings";
            
            break;
            
        case appsectionpricesguide:
            
            str = NSLocalizedString(@"menu_pricesguide", nil);
            iconname = @"prices";
            
            break;
            
        case appsectionstore:
            
            str = NSLocalizedString(@"menu_store", nil);
            iconname = @"store";
            
            break;
            
        case appsectionnone:
            break;
    }
    
    [lbl setText:str];
    [icon setImage:[[UIImage imageNamed:iconname] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [self hover];
}

@end