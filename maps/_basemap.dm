#include "map_files\generic\Admin_level.dmm"
#ifdef TARGET_SUBURB
#include "map_files\Suburb_lv759\Suburb_lv759.dmm"
#endif
#ifdef TARGET_BIGRED_MULTIZ
#include "map_files\BigRed_multiz\BigRed.dmm"
#endif
#ifdef TARGET_NAVALIS
#include "map_files\Navalis_Platform_13\Navalis_Platform_13.dmm"
#endif
#ifdef TARGET_NAVALIS_SINGLEZ
#include "map_files\Navalis_Platform_13_singlez\Navalis_Platform_13_singlez.dmm"
#endif
#ifdef TARGET_TYRARGO
#include "map_files\Tyrargo_Rift\Tyrargo_Rift.dmm"
#endif
#ifdef TARGET_ANTRE
#include "map_files\White_Antre_Research_Facility\White_Antre_Research_Facility.dmm"
#endif
#ifdef TARGET_PUDONG
#include "map_files\pudong_bunker\mi264_pudong_bunker.dmm"
#endif
#ifdef TARGET_FIRE_COLONY
#include "map_files\Fire_Colony\Fire_Colony.dmm"
#endif

#ifdef ALL_MAPS
	#ifdef CIBUILDING
		#if defined(ALL_MAPS_STAGE_BASE)
			#include "templates_base.dm"
		#elif defined(ALL_MAPS_STAGE_EXTRA)
			#include "templates_extra.dm"
		#else
			#include "templates_base.dm"
			#include "templates_extra.dm"
		#endif
	#endif
#endif
