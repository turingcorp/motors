#import "visettings.h"

@implementation visettings

@synthesize collection;

-(visettings*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self setClipsToBounds:YES];
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setFooterReferenceSize:CGSizeZero];
    [flow setHeaderReferenceSize:CGSizeZero];
    [flow setMinimumInteritemSpacing:0];
    [flow setMinimumLineSpacing:10];
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flow setSectionInset:UIEdgeInsetsZero];
    
    UICollectionView *strongcollection = [[UICollectionView alloc] initWithFrame:screenrect collectionViewLayout:flow];
    collection = strongcollection;
    [collection setClipsToBounds:YES];
    [collection setBackgroundColor:[UIColor clearColor]];
    [collection setShowsHorizontalScrollIndicator:NO];
    [collection setShowsVerticalScrollIndicator:NO];
    [collection setBounces:NO];
    [collection setDataSource:self];
    [collection setDelegate:self];
    [collection registerClass:[visettingscel class] forCellWithReuseIdentifier:celid];
    
    [self addSubview:collection];
    
    return self;
}

#pragma mark -
#pragma mark col del

-(CGSize)collectionView:(UICollectionView*)_col layout:(UICollectionViewLayout*)_layout sizeForItemAtIndexPath:(NSIndexPath*)_index
{
    CGFloat height = 50;
    
    switch(_index.item)
    {
        case 0:
            
            break;
            
        case 1:
            
            break;
            
        case 2:
            
            break;
            
        case 3:
            
            height = 160;
            
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
    return 4;
}

-(UICollectionViewCell*)collectionView:(UICollectionView*)_col cellForItemAtIndexPath:(NSIndexPath*)_index
{
    visettingscel *cel = [_col dequeueReusableCellWithReuseIdentifier:celid forIndexPath:_index];
    [cel config:_index.item];
    
    return cel;
}

@end

@implementation visettingscel

@synthesize view;

-(visettingscel*)initWithFrame:(CGRect)_rect
{
    self = [super initWithFrame:_rect];
    [self setClipsToBounds:YES];
    [self setBackgroundColor:[UIColor clearColor]];
    
    return self;
}

#pragma mark public

-(void)config:(NSInteger)_index
{
    [view removeFromSuperview];
    
    switch(_index)
    {
        case 0:
            
            break;
            
        case 1:
            
            break;
            
        case 2:
            
            break;
            
        case 3:
            
            view = [[vicountries alloc] initWithFrame:CGRectMake(0, 0, screenwidth, 160)];
            
            break;
    }
    
    [self addSubview:view];
}

@end