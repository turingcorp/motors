#import "moddb.h"

@implementation moddb

+(void)create
{
    NSString *cleandb = [[NSBundle mainBundle] pathForResource:@"empty.db" ofType:@""];
    [moddirs copy:cleandb to:dbname];
    
    db *_db = [db begin];
    
    NSString *query;
    query = @"CREATE TABLE site (id INTEGER PRIMARY KEY, site TEXT, name TEXT COLLATE NOCASE);";
    [_db query:query];
    
    query = @"CREATE TABLE item (id INTEGER PRIMARY KEY, created INTEGER, status INTEGER, item TEXT COLLATE NOCASE, title TEXT COLLATE NOCASE);";
    [_db query:query];
    
    query = @"CREATE TABLE iteminfo (id INTEGER PRIMARY KEY, itemid INTEGER, descr TEXT, siteid INTEGER, sellerid TEXT COLLATE NOCASE, categoryid TEXT COLLATE NOCASE, currencyid TEXT COLLATE NOCASE, price INTEGER, addressline TEXT COLLATE NOCASE, zipcode TEXT COLLATE NOCASE, neight TEXT COLLATE NOCASE, city TEXT COLLATE NOCASE, state TEXT COLLATE NOCASE, country TEXT COLLATE NOCASE, latitude INTEGER, longitude INTEGER, contactname TEXT COLLATE NOCASE, openhours TEXT, areacode TEXT, phone TEXT, email TEXT);";
    [_db query:query];
    
    query = @"CREATE TABLE itemattr (id INTEGER PRIMARY KEY, itemid INTEGER, title TEXT COLLATE NOCASE);";
    [_db query:query];
    
    query = @"CREATE TABLE itemattrcomplex (id INTEGER PRIMARY KEY, itemid INTEGER, name TEXT COLLATE NOCASE, value TEXT COLLATE NOCASE);";
    [_db query:query];
    
    query = @"CREATE TABLE itemattrnum (id INTEGER PRIMARY KEY, itemid INTEGER, name TEXT COLLATE NOCASE, value INTEGER);";
    [_db query:query];
    [_db commit];
    
    [moddb defaults];
    [tools dataexport:@[[NSURL fileURLWithPath:dbname]] view:[ctrmain sha].view];
}

+(void)defaults
{
    db *_db = [db begin];
    [moddb createsite:_db site:@"MLA" name:@"Argentina"];
    [moddb createsite:_db site:@"MLB" name:@"Brasil"];
    [moddb createsite:_db site:@"MCO" name:@"Colombia"];
    [moddb createsite:_db site:@"MCR" name:@"Costa Rica"];
    [moddb createsite:_db site:@"MEC" name:@"Ecuador"];
    [moddb createsite:_db site:@"MLC" name:@"Chile"];
    [moddb createsite:_db site:@"MLM" name:@"Mexico"];
    [moddb createsite:_db site:@"MLU" name:@"Uruguay"];
    [moddb createsite:_db site:@"MLV" name:@"Venezuela"];
    [moddb createsite:_db site:@"MPA" name:@"Panama"];
    [moddb createsite:_db site:@"MPE" name:@"Peru"];
    [moddb createsite:_db site:@"MPT" name:@"Portugal"];
    [moddb createsite:_db site:@"MRD" name:@"Dominicana"];
    [moddb createsite:_db site:@"MBO" name:@"Bolivia"];
    [moddb createsite:_db site:@"MGT" name:@"Guatemala"];
    [_db commit];
}

+(void)createsite:(db*)_db site:(NSString*)_site name:(NSString*)_name
{
    NSString *query = [NSString stringWithFormat:
                       @"INSERT INTO site (site, name) values(\"%@\", \"%@\");",
                       _site, _name];
    
    [_db query:query];
}

@end