#import "appdel.h"

@class moditem;
@class moditemcontact;
@class modinitem;
@class modsearchresult;

@interface modinitems:NSObject

+(modinitems*)sha;
-(void)refresh;
-(modinitem*)fetchorcreate:(NSString*)_identifier;
-(NSArray*)asarray;

@end

@interface modinitem:NSObject

-(void)favorite;
-(void)trash;
-(void)nostatus;
-(void)save;
-(void)loaditem;
-(void)loadimage;

@property(weak, nonatomic)moditem *item;
@property(strong, nonatomic)modsearchresult *result;
@property(strong, nonatomic)moditemcontact *contact;
@property(strong, nonatomic)UIImage *image;
@property(copy, nonatomic)NSString *identifier;
@property(copy, nonatomic)NSString *title;
@property(nonatomic)statustype status;
@property(nonatomic)NSInteger itemid;

@end