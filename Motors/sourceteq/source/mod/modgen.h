typedef enum
{
    appsectionsearch,
    appsectionpricesguide,
    appsectionphotocenters,
    appsectionfavorites,
    appsectionlistings,
    appsectionaccount,
    appsectionsettings,
    appsectionstore,
    appsectionnone
}appsection;

typedef enum
{
    appbarstatehide,
    appbarstateshown
}appbarstate;

typedef enum
{
    appmenustatehide,
    appmenustateshown
}appmenustate;

typedef enum
{
    appsearchstatelist,
    appsearchstatedetail
}appsearchstate;

typedef enum
{
    statustypeactive = 6,
    statustypefavorite = 7,
    statustypetrash = 13
}statustype;

typedef enum
{
    cloudreqtypelogin,
    cloudreqtypesearch,
    cloudreqtypeitem,
    cloudreqtypepricesselect,
    cloudreqtypepricesfilters,
    cloudreqtypepricesfetch
}cloudreqtype;

typedef enum
{
    filtercomcat,
    filtercomloc,
    filtercomyear
}filtercom;

typedef enum
{
    perkstatuspurchased,
    perkstatusnew,
    perkstatuspurchasing,
    perkstatusdeferred,
    perkstatusnotsupported
}perkstatus;

@protocol modgen <NSObject>

@end