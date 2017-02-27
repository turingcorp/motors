#import "appdel.h"

@class modfilter;
@class modfilterelement;

@interface modfilters:NSObject

-(void)parse:(NSDictionary*)_json;
-(NSInteger)count;
-(modfilter*)filter:(NSInteger)_index;
-(modfilter*)filterbycomponent:(filtercom)_component;

@end

@interface modfilter:NSObject

-(modfilter*)init:(filtercom)_component;
-(NSInteger)count;
-(modfilterelement*)element:(NSInteger)_index;
-(void)add:(modfilterelement*)_filter;
-(NSInteger)indexof:(modfilterelement*)_element;
-(void)sort;

@property(weak, nonatomic)modfilterelement *selected;
@property(copy, nonatomic)NSString *filterid;
@property(copy, nonatomic)NSString *defaulttitle;
@property(nonatomic)filtercom component;

@end

@interface modfilterelement:NSObject

@property(strong, nonatomic)modfilter *children;
@property(copy, nonatomic)NSString *valueid;
@property(copy, nonatomic)NSString *valuename;
@property(weak, nonatomic)modfilter *container;
@property(weak, nonatomic)modfilterelement *parent;
@property(nonatomic)NSInteger results;

@end