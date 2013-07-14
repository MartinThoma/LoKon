#ifdef _full
#define _undo
#define _osc
#define _elewin
#define _romram
#define _pla
#define _layele
#endif

#ifdef _small
#define _undo
#define _osc
#undef _elewin
#define _romram
#define _pla
#undef _layele
#endif

#ifdef _mini
#define _undo
#undef _osc
#undef _elewin
#undef _romram
#undef _pla
#undef _layele
#endif
