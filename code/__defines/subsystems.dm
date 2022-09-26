#define NEW_SS_GLOBAL(varname) if(varname != src){if(istype(varname)){Recover();qdel(varname);}varname = src;}

#define SUBSYSTEM_DEF(X) var/global/subsystem/##X/SS##X;\
/subsystem/##X/New(){\
	NEW_SS_GLOBAL(SS##X);\
	PreInitialize();\
}\
/subsystem/##X


#define SS_ORDER_CONFIG 1
#define SS_ORDER_LOGGING 2
#define SS_ORDER_FIRST 3
#define SS_ORDER_PRELOAD 4
#define SS_ORDER_POSTLOAD 5
#define SS_ORDER_DMM 6
#define SS_ORDER_TURFS 7
#define SS_ORDER_AREAS 8
#define SS_ORDER_OBJS 9
#define SS_ORDER_POWER 10
#define SS_ORDER_SUNLIGHT 11
#define SS_ORDER_LIGHTING 12
#define SS_ORDER_GENERATION 13
#define SS_ORDER_IMPORTANT 14
#define SS_ORDER_NORMAL 15
#define SS_ORDER_LIFE 16
#define SS_ORDER_LAST 17
#define SS_ORDER_AIR 18
#define SS_ORDER_DELETE 19
#define SS_ORDER_REPORT 20




#define queue_smoothing(A) if(!A.queued_smoothing) {A.queued_smoothing = TRUE; SSsmoothing.queued_smoothing += A}