diff --git a/patches/ui_pyroscope.cc b/patches/ui_pyroscope.cc
index ddc6bfc..f044258 100644
--- a/patches/ui_pyroscope.cc
+++ b/patches/ui_pyroscope.cc
@@ -35,11 +35,11 @@ python -c 'print u"\u22c5 \u22c5\u22c5 \u201d \u2019 \u266f \u2622 \u260d \u2318
 #include "control.h"
 #include "command_helpers.h"
 
-#if (RT_HEX_VERSION >= 0x000901)
-    #define _cxxstd_ tr1
-#else
+//#if (RT_HEX_VERSION >= 0x000901)
+//    #define _cxxstd_ tr1
+//#else
     #define _cxxstd_ std
-#endif
+//#endif
 
 #if defined(CMD2_ANY)
        #define D_INFO(item) (item->info())
@@ -785,7 +785,7 @@ torrent::Object network_history_sample() {
 void initialize_command_ui_pyroscope() {
 #if defined(CMD2_ANY)
        #define PS_VARIABLE_COLOR(key, value) \
-               control->object_storage()->insert_c_str(key, value, rpc::object_storage::flag_string_type); \
+               control->object_storage()->insert_c_str(key, value, rpc::flag_string_type); \
                CMD2_ANY(key, _cxxstd_::bind(&rpc::object_storage::get, control->object_storage(),   \
                        torrent::raw_string::from_c_str(key)));  \
                CMD2_ANY_STRING(key ".set", _cxxstd_::bind(&rpc::object_storage::set_color_string, control->object_storage(), \
