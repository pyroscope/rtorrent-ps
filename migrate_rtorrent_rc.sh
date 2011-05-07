#! /bin/bash
test -n "$1" || { echo "Usage: $0 «rcfile»" ; exit 1; }

set -e
rc_file="$1"
test -e $rc_file,0.8.6 || cp $rc_file $rc_file,0.8.6

#    -e 's%^ratio.max\([ =]\)%group2.seeding.ratio.max\1%' \
#    -e 's%^ratio.min\([ =]\)%group2.seeding.ratio.min\1%' \
#    -e 's%^ratio.upload\([ =]\)%group2.seeding.ratio.upload\1%' \

# Always start fresh
cp $rc_file,0.8.6 $rc_file

# Generic
sed -i $rc_file \
    -e 's%^download_rate\([ =]\)%throttle.global_down.max_rate.set_kb\1%' \
    -e 's%^encoding_list\([ =]\)%encoding.add\1%' \
    -e 's%^system\.method\.insert\([ =]\)%method.insert\1%' \
    -e 's%^ratio\.disable\([ =]\)%group.seeding.ratio.disable\1%' \
    -e 's%^ratio\.enable\([ =]\)%group.seeding.ratio.enable\1%' \
    -e 's%^scgi_local\([ =]\)%network.scgi.open_local\1%' \
    -e 's%^scgi_port\([ =]\)%network.scgi.open_port\1%' \
    -e 's%^throttle_down\([ =]\)%throttle.down\1%' \
    -e 's%^throttle_ip\([ =]\)%throttle.ip\1%' \
    -e 's%^throttle_up\([ =]\)%throttle.up\1%' \
    -e 's%^upload_rate\([ =]\)%throttle.global_up.max_rate.set_kb\1%' \
    -e 's%view_add\([ =]\)%view.add\1%' \
    -e 's%view_filter_on\([ =]\)%view.filter_on\1%' \
    -e 's%view_filter\([ =]\)%view.filter\1%' \
    -e 's%view_list\([ =]\)%view.list\1%' \
    -e 's%view_sort_current\([ =]\)%view.sort_current\1%' \
    -e 's%view_sort_new\([ =]\)%view.sort_new\1%' \
    -e 's%view_sort\([ =]\)%view.sort\1%' \
    -r

# Setters
sed -i $rc_file \
    -e 's%^bind\([ =]\)%network.bind_address\1%' \
    -e 's%^check_hash\([ =]\)%pieces.hash.on_completion\1%' \
    -e 's%^connection_leech\([ =]\)%protocol.connection.leech\1%' \
    -e 's%^connection_seed\([ =]\)%protocol.connection.seed\1%' \
    -e 's%^dht_port\([ =]\)%dht.port\1%' \
    -e 's%^directory\([ =]\)%directory.default\1%' \
    -e 's%^hash_interval\([ =]\)%system.hash.interval\1%' \
    -e 's%^hash_max_tries\([ =]\)%system.hash.max_tries\1%' \
    -e 's%^hash_read_ahead\([ =]\)%system.hash.read_ahead\1%' \
    -e 's%^http_cacert\([ =]\)%network.http.cacert\1%' \
    -e 's%^http_capath\([ =]\)%network.http.capath\1%' \
    -e 's%^http_proxy\([ =]\)%network.http.proxy_address\1%' \
    -e 's%^ip\([ =]\)%network.local_address\1%' \
    -e 's%^key_layout\([ =]\)%keys.layout\1%' \
    -e 's%^max_downloads_div\([ =]\)%throttle.max_downloads.div\1%' \
    -e 's%^max_downloads_global\([ =]\)%throttle.max_downloads.global\1%' \
    -e 's%^max_memory_usage\([ =]\)%pieces.memory.max\1%' \
    -e 's%^max_peers_seed\([ =]\)%throttle.max_peers.seed\1%' \
    -e 's%^max_peers\([ =]\)%throttle.max_peers.normal\1%' \
    -e 's%^max_uploads_div\([ =]\)%throttle.max_uploads.div\1%' \
    -e 's%^max_uploads_global\([ =]\)%throttle.max_uploads.global\1%' \
    -e 's%^max_uploads\([ =]\)%throttle.max_uploads\1%' \
    -e 's%^min_peers_seed\([ =]\)%throttle.min_peers.seed\1%' \
    -e 's%^min_peers\([ =]\)%throttle.min_peers.normal\1%' \
    -e 's%^peer_exchange\([ =]\)%protocol.pex\1%' \
    -e 's%^port_open\([ =]\)%network.port_open\1%' \
    -e 's%^port_random\([ =]\)%network.port_random\1%' \
    -e 's%^port_range\([ =]\)%network.port_range\1%' \
    -e 's%^proxy_address\([ =]\)%network.proxy_address\1%' \
    -e 's%^scgi_dont_route\([ =]\)%network.scgi.dont_route\1%' \
    -e 's%^session\([ =]\)%session.path.set\1%' \
    -e 's%^system\.file_allocate.set\([ =]\)%system.file.allocate.set\1%' \
    -e 's%^system\.method\.set\([ =]\)%method.set\1%' \
    -e 's%^tracker_numwant\([ =]\)%trackers.numwant.set\1%' \
    -e 's%^use_udp_trackers\([ =]\)%trackers.use_udp.set\1%' \
    -e 's%^view_set\([ =]\)%view\1%' \
    -e 's%^xmlrpc_dialect\([ =]\)%network.xmlrpc.dialect.set\1%' \
    -e 's%^xmlrpc_size_limit\([ =]\)%network.xmlrpc.size_limit.set\1%' \
    -e 's%^system.method.has_key\([ =]\)%method.has_key\1%' \
    -e 's%^system.method.set_key\([ =]\)%method.set_key\1%' \
    -e 's%^system.method.list_keys\([ =]\)%method.list_keys\1%' \
    -e 's%^system.method.insert\([ =]\)%method.insert\1%' \
    -e 's%^system.method.erase\([ =]\)%method.erase\1%' \
    -e 's%^system.method.get\([ =]\)%method.get\1%' \
    -e 's%^system.method.set\([ =]\)%method.set\1%' \
    -r

# Setters that need ".set"
sed -i $rc_file \
    -e 's%^dht\([ =]\)%dht.mode.set\1%' \
    -e 's%^encryption\([ =]\)%protocol.encryption.set\1%' \
    -r

# Missing Mappings (not in 0.8.7 source code)
sed -i $rc_file \
    -e 's%^max_open_sockets\([ =]\)%network.max_open_sockets\1%' \
    -e 's%^max_open_files\([ =]\)%network.max_open_files\1%' \
    -e 's%^umask\([ =]\)%system.umask.set\1%' \
    -r

# Missing INLINE Mappings (not in 0.8.7 source code)
sed -i $rc_file \
    -e 's%d\.save_session=%d\.save_full_session=%g' \
    -r

# Inline Commands - Generic
sed -i $rc_file \
    -e 's%to_xb=%convert.xb=%g' \
    -e 's%to_time=%convert.time=%g' \
    -e 's%to_throttle=%convert.throttle=%g' \
    -e 's%to_mb=%convert.mb=%g' \
    -e 's%to_kb=%convert.kb=%g' \
    -e 's%to_gm_time=%convert.gm_time=%g' \
    -e 's%to_gm_date=%convert.gm_date=%g' \
    -e 's%to_elapsed_time=%convert.elapsed_time=%g' \
    -e 's%to_date=%convert.date=%g' \
    -e 's%system\.method\.set_key=%method.set_key=%g' \
    -e 's%system\.method\.list_keys=%method.list_keys=%g' \
    -e 's%system\.method\.has_key=%method.has_key=%g' \
    -e 's%system\.method\.erase=%method.erase=%g' \
    -e 's%system\.file_allocate=%system.file.allocate=%g' \
    -e 's%session_save=%session.save=%g' \
    -e 's%load_verbose=%load.verbose=%g' \
    -e 's%load_start_verbose=%load.start_verbose=%g' \
    -e 's%load_start=%load.start=%g' \
    -e 's%load_raw_verbose=%load.raw_verbose=%g' \
    -e 's%load_raw_start=%load.raw_start=%g' \
    -e 's%load_raw=%load.raw=%g' \
    -e 's%load=%load.normal=%g' \
    -e 's%execute_throw=%execute.throw=%g' \
    -e 's%execute_raw_nothrow=%execute.raw_nothrow=%g' \
    -e 's%execute_raw=%execute.raw=%g' \
    -e 's%execute_nothrow=%execute.nothrow=%g' \
    -e 's%execute_capture_nothrow=%execute.capture_nothrow=%g' \
    -e 's%execute_capture=%execute.capture=%g' \
    -e 's%dht_statistics=%dht.statistics=%g' \
    -e 's%dht_add_node=%dht.add_node=%g' \
    -e 's%delete_tied=%d.delete_tied=%g' \
    -e 's%delete_link=%d.delete_link=%g' \
    -e 's%create_link=%d.create_link=%g' \
    -r

# Inline Commands - Setter
sed -i $rc_file \
    -e 's%d\.set_connection_current=%d.connection_current.set=%g' \
    -e 's%d\.set_custom1=%d.custom1.set=%g' \
    -e 's%d\.set_custom2=%d.custom2.set=%g' \
    -e 's%d\.set_custom3=%d.custom3.set=%g' \
    -e 's%d\.set_custom4=%d.custom4.set=%g' \
    -e 's%d\.set_custom5=%d.custom5.set=%g' \
    -e 's%d\.set_custom=%d.custom.set=%g' \
    -e 's%d\.set_directory_base=%d.directory_base.set=%g' \
    -e 's%d\.set_directory=%d.directory.set=%g' \
    -e 's%d\.set_hashing_failed=%d.hashing_failed.set=%g' \
    -e 's%d\.set_ignore_commands=%d.ignore_commands.set=%g' \
    -e 's%d\.set_max_file_size=%d.max_file_size.set=%g' \
    -e 's%d\.set_message=%d.message.set=%g' \
    -e 's%d\.set_peers_max=%d.peers_max.set=%g' \
    -e 's%d\.set_peers_min=%d.peers_min.set=%g' \
    -e 's%d\.set_priority=%d.priority.set=%g' \
    -e 's%d\.set_throttle_name=%d.throttle_name.set=%g' \
    -e 's%d\.set_tied_to_file=%d.tied_to_file.set=%g' \
    -e 's%d\.set_tracker_numwant=%d.tracker_numwant.set=%g' \
    -e 's%d\.set_uploads_max=%d.uploads_max.set=%g' \
    -e 's%f\.set_priority=%f.priority.set=%g' \
    -e 's%t\.set_enabled=%t.is_enabled.set=%g' \
    -e 's%set_bind=%network.bind_address.set=%g' \
    -e 's%set_check_hash=%pieces.hash.on_completion.set=%g' \
    -e 's%set_connection_leech=%protocol.connection.leech.set=%g' \
    -e 's%set_connection_seed=%protocol.connection.seed.set=%g' \
    -e 's%set_dht_port=%dht.port.set=%g' \
    -e 's%set_dht_throttle=%dht.throttle.name.set=%g' \
    -e 's%set_directory=%directory.default.set=%g' \
    -e 's%set_download_rate=%throttle.global_down.max_rate.set=%g' \
    -e 's%set_handshake_log=%log.handshake.set=%g' \
    -e 's%set_hash_interval=%system.hash.interval.set=%g' \
    -e 's%set_hash_max_tries=%system.hash.max_tries.set=%g' \
    -e 's%set_hash_read_ahead=%system.hash.read_ahead.set=%g' \
    -e 's%set_http_cacert=%network.http.cacert.set=%g' \
    -e 's%set_http_capath=%network.http.capath.set=%g' \
    -e 's%set_http_proxy=%network.http.proxy_address.set=%g' \
    -e 's%set_ip=%network.local_address.set=%g' \
    -e 's%set_log.tracker=%log.tracker.set=%g' \
    -e 's%set_max_downloads_div=%throttle.max_downloads.div.set=%g' \
    -e 's%set_max_downloads_global=%throttle.max_downloads.global.set=%g' \
    -e 's%set_max_file_size=%system.file.max_size.set=%g' \
    -e 's%set_max_memory_usage=%pieces.memory.max.set=%g' \
    -e 's%set_max_open_files=%network.max_open_files.set=%g' \
    -e 's%set_max_open_http=%network.http.max_open.set=%g' \
    -e 's%set_max_peers_seed=%throttle.max_peers.seed.set=%g' \
    -e 's%set_max_peers=%throttle.max_peers.normal.set=%g' \
    -e 's%set_max_uploads_div=%throttle.max_uploads.div.set=%g' \
    -e 's%set_max_uploads_global=%throttle.max_uploads.global.set=%g' \
    -e 's%set_max_uploads=%throttle.max_uploads.set=%g' \
    -e 's%set_min_peers_seed=%throttle.min_peers.seed.set=%g' \
    -e 's%set_min_peers=%throttle.min_peers.normal.set=%g' \
    -e 's%set_name=%session.name.set=%g' \
    -e 's%set_peer_exchange=%protocol.pex.set=%g' \
    -e 's%set_port_open=%network.port_open.set=%g' \
    -e 's%set_port_random=%network.port_random.set=%g' \
    -e 's%set_port_range=%network.port_range.set=%g' \
    -e 's%set_preload_min_size=%pieces.preload.min_size.set=%g' \
    -e 's%set_preload_required_rate=%pieces.preload.min_rate.set=%g' \
    -e 's%set_preload_type=%pieces.preload.type.set=%g' \
    -e 's%set_proxy_address=%network.proxy_address.set=%g' \
    -e 's%set_receive_buffer_size=%network.receive_buffer.size.set=%g' \
    -e 's%set_safe_sync=%pieces.sync.always_safe.set=%g' \
    -e 's%set_scgi_dont_route=%network.scgi.dont_route.set=%g' \
    -e 's%set_send_buffer_size=%network.send_buffer.size.set=%g' \
    -e 's%set_session_lock=%session.use_lock.set=%g' \
    -e 's%set_session_on_completion=%session.on_completion.set=%g' \
    -e 's%set_session=%session.path.set=%g' \
    -e 's%set_split_file_size=%system.file.split_size.set=%g' \
    -e 's%set_split_suffix=%system.file.split_suffix.set=%g' \
    -e 's%set_timeout_safe_sync=%pieces.sync.timeout_safe.set=%g' \
    -e 's%set_timeout_sync=%pieces.sync.timeout.set=%g' \
    -e 's%set_tracker_numwant=%trackers.numwant.set=%g' \
    -e 's%set_upload_rate=%throttle.global_up.max_rate.set=%g' \
    -e 's%set_use_udp_trackers=%trackers.use_udp.set=%g' \
    -e 's%set_xmlrpc_dialect=%network.xmlrpc.dialect.set=%g' \
    -e 's%set_xmlrpc_size_limit=%network.xmlrpc.size_limit.set=%g' \
    -r

# Inline Commands - Getter
sed -i $rc_file \
    -e 's%d\.get_base_filename=%d.base_filename=%g' \
    -e 's%d\.get_base_path=%d.base_path=%g' \
    -e 's%d\.get_bitfield=%d.bitfield=%g' \
    -e 's%d\.get_bytes_done=%d.bytes_done=%g' \
    -e 's%d\.get_chunks_hashed=%d.chunks_hashed=%g' \
    -e 's%d\.get_chunk_size=%d.chunk_size=%g' \
    -e 's%d\.get_completed_bytes=%d.completed_bytes=%g' \
    -e 's%d\.get_completed_chunks=%d.completed_chunks=%g' \
    -e 's%d\.get_complete=%d.complete=%g' \
    -e 's%d\.get_connection_current=%d.connection_current=%g' \
    -e 's%d\.get_connection_leech=%d.connection_leech=%g' \
    -e 's%d\.get_connection_seed=%d.connection_seed=%g' \
    -e 's%d\.get_creation_date=%d.creation_date=%g' \
    -e 's%d\.get_custom1=%d.custom1=%g' \
    -e 's%d\.get_custom2=%d.custom2=%g' \
    -e 's%d\.get_custom3=%d.custom3=%g' \
    -e 's%d\.get_custom4=%d.custom4=%g' \
    -e 's%d\.get_custom5=%d.custom5=%g' \
    -e 's%d\.get_custom=%d.custom=%g' \
    -e 's%d\.get_custom_throw=%d.custom_throw=%g' \
    -e 's%d\.get_directory_base=%d.directory_base=%g' \
    -e 's%d\.get_directory=%d.directory=%g' \
    -e 's%d\.get_down_rate=%d.down.rate=%g' \
    -e 's%d\.get_down_total=%d.down.total=%g' \
    -e 's%d\.get_free_diskspace=%d.free_diskspace=%g' \
    -e 's%d\.get_hash=%d.hash=%g' \
    -e 's%d\.get_hashing=%d.hashing=%g' \
    -e 's%d\.get_hashing_failed=%d.hashing_failed=%g' \
    -e 's%d\.get_ignore_commands=%d.ignore_commands=%g' \
    -e 's%d\.get_left_bytes=%d.left_bytes=%g' \
    -e 's%d\.get_loaded_file=%d.loaded_file=%g' \
    -e 's%d\.get_local_id=%d.local_id=%g' \
    -e 's%d\.get_local_id_html=%d.local_id_html=%g' \
    -e 's%d\.get_max_file_size=%d.max_file_size=%g' \
    -e 's%d\.get_max_size_pex=%d.max_size_pex=%g' \
    -e 's%d\.get_message=%d.message=%g' \
    -e 's%d\.get_mode=%d.mode=%g' \
    -e 's%d\.get_name=%d.name=%g' \
    -e 's%d\.get_peer_exchange=%d.peer_exchange=%g' \
    -e 's%d\.get_peers_accounted=%d.peers_accounted=%g' \
    -e 's%d\.get_peers_complete=%d.peers_complete=%g' \
    -e 's%d\.get_peers_connected=%d.peers_connected=%g' \
    -e 's%d\.get_peers_max=%d.peers_max=%g' \
    -e 's%d\.get_peers_min=%d.peers_min=%g' \
    -e 's%d\.get_peers_not_connected=%d.peers_not_connected=%g' \
    -e 's%d\.get_priority=%d.priority=%g' \
    -e 's%d\.get_priority_str=%d.priority_str=%g' \
    -e 's%d\.get_ratio=%d.ratio=%g' \
    -e 's%d\.get_size_bytes=%d.size_bytes=%g' \
    -e 's%d\.get_size_chunks=%d.size_chunks=%g' \
    -e 's%d\.get_size_files=%d.size_files=%g' \
    -e 's%d\.get_size_pex=%d.size_pex=%g' \
    -e 's%d\.get_skip_rate=%d.skip.rate=%g' \
    -e 's%d\.get_skip_total=%d.skip.total=%g' \
    -e 's%d\.get_state_changed=%d.state_changed=%g' \
    -e 's%d\.get_state_counter=%d.state_counter=%g' \
    -e 's%d\.get_state=%d.state=%g' \
    -e 's%d\.get_throttle_name=%d.throttle_name=%g' \
    -e 's%d\.get_tied_to_file=%d.tied_to_file=%g' \
    -e 's%d\.get_tracker_focus=%d.tracker_focus=%g' \
    -e 's%d\.get_tracker_numwant=%d.tracker_numwant=%g' \
    -e 's%d\.get_tracker_size=%d.tracker_size=%g' \
    -e 's%d\.get_uploads_max=%d.uploads_max=%g' \
    -e 's%d\.get_up_rate=%d.up.rate=%g' \
    -e 's%d\.get_up_total=%d.up.total=%g' \
    -e 's%f\.get_completed_chunks=%f.completed_chunks=%g' \
    -e 's%f\.get_frozen_path=%f.frozen_path=%g' \
    -e 's%f\.get_last_touched=%f.last_touched=%g' \
    -e 's%f\.get_match_depth_next=%f.match_depth_next=%g' \
    -e 's%f\.get_match_depth_prev=%f.match_depth_prev=%g' \
    -e 's%f\.get_offset=%f.offset=%g' \
    -e 's%f\.get_path_components=%f.path_components=%g' \
    -e 's%f\.get_path_depth=%f.path_depth=%g' \
    -e 's%f\.get_path=%f.path=%g' \
    -e 's%f\.get_priority=%f.priority=%g' \
    -e 's%f\.get_range_first=%f.range_first=%g' \
    -e 's%f\.get_range_second=%f.range_second=%g' \
    -e 's%f\.get_size_bytes=%f.size_bytes=%g' \
    -e 's%f\.get_size_chunks=%f.size_chunks=%g' \
    -e 's%fi\.get_filename_last=%fi.filename_last=%g' \
    -e 's%get_bind=%network.bind_address=%g' \
    -e 's%get_check_hash=%pieces.hash.on_completion=%g' \
    -e 's%get_connection_leech=%protocol.connection.leech=%g' \
    -e 's%get_connection_seed=%protocol.connection.seed=%g' \
    -e 's%get_dht_port=%dht.port=%g' \
    -e 's%get_dht_throttle=%dht.throttle.name=%g' \
    -e 's%get_directory=%directory.default=%g' \
    -e 's%get_download_rate=%throttle.global_down.max_rate=%g' \
    -e 's%get_down_rate=%throttle.global_down.rate=%g' \
    -e 's%get_down_total=%throttle.global_down.total=%g' \
    -e 's%get_handshake_log=%log.handshake=%g' \
    -e 's%get_hash_interval=%system.hash.interval=%g' \
    -e 's%get_hash_max_tries=%system.hash.max_tries=%g' \
    -e 's%get_hash_read_ahead=%system.hash.read_ahead=%g' \
    -e 's%get_http_cacert=%network.http.cacert=%g' \
    -e 's%get_http_capath=%network.http.capath=%g' \
    -e 's%get_http_proxy=%network.http.proxy_address=%g' \
    -e 's%get_ip=%network.local_address=%g' \
    -e 's%get_log.tracker=%log.tracker=%g' \
    -e 's%get_max_downloads_div=%throttle.max_downloads.div=%g' \
    -e 's%get_max_downloads_global=%throttle.max_downloads.global=%g' \
    -e 's%get_max_file_size=%system.file.max_size=%g' \
    -e 's%get_max_memory_usage=%pieces.memory.max=%g' \
    -e 's%get_max_open_files=%network.max_open_files=%g' \
    -e 's%get_max_open_http=%network.http.max_open=%g' \
    -e 's%get_max_open_sockets=%network.max_open_sockets=%g' \
    -e 's%get_max_peers_seed=%throttle.max_peers.seed=%g' \
    -e 's%get_max_peers=%throttle.max_peers.normal=%g' \
    -e 's%get_max_uploads_div=%throttle.max_uploads.div=%g' \
    -e 's%get_max_uploads_global=%throttle.max_uploads.global=%g' \
    -e 's%get_max_uploads=%throttle.max_uploads=%g' \
    -e 's%get_memory_usage=%pieces.memory.current=%g' \
    -e 's%get_min_peers_seed=%throttle.min_peers.seed=%g' \
    -e 's%get_min_peers=%throttle.min_peers.normal=%g' \
    -e 's%get_name=%session.name=%g' \
    -e 's%get_peer_exchange=%protocol.pex=%g' \
    -e 's%get_port_open=%network.port_open=%g' \
    -e 's%get_port_random=%network.port_random=%g' \
    -e 's%get_port_range=%network.port_range=%g' \
    -e 's%get_preload_min_size=%pieces.preload.min_size=%g' \
    -e 's%get_preload_required_rate=%pieces.preload.min_rate=%g' \
    -e 's%get_preload_type=%pieces.preload.type=%g' \
    -e 's%get_proxy_address=%network.proxy_address=%g' \
    -e 's%get_receive_buffer_size=%network.receive_buffer.size=%g' \
    -e 's%get_safe_sync=%pieces.sync.always_safe=%g' \
    -e 's%get_scgi_dont_route=%network.scgi.dont_route=%g' \
    -e 's%get_send_buffer_size=%network.send_buffer.size=%g' \
    -e 's%get_session_lock=%session.use_lock=%g' \
    -e 's%get_session_on_completion=%session.on_completion=%g' \
    -e 's%get_session=%session.path=%g' \
    -e 's%get_split_file_size=%system.file.split_size=%g' \
    -e 's%get_split_suffix=%system.file.split_suffix=%g' \
    -e 's%get_stats_not_preloaded=%pieces.stats_not_preloaded=%g' \
    -e 's%get_stats_preloaded=%pieces.stats_preloaded=%g' \
    -e 's%get_throttle_down_max=%throttle.down.max=%g' \
    -e 's%get_throttle_down_rate=%throttle.down.rate=%g' \
    -e 's%get_throttle_up_max=%throttle.up.max=%g' \
    -e 's%get_throttle_up_rate=%throttle.up.rate=%g' \
    -e 's%get_timeout_safe_sync=%pieces.sync.timeout_safe=%g' \
    -e 's%get_timeout_sync=%pieces.sync.timeout=%g' \
    -e 's%get_tracker_numwant=%trackers.numwant=%g' \
    -e 's%get_upload_rate=%throttle.global_up.max_rate=%g' \
    -e 's%get_up_rate=%throttle.global_up.rate=%g' \
    -e 's%get_up_total=%throttle.global_up.total=%g' \
    -e 's%get_use_udp_trackers=%trackers.use_udp=%g' \
    -e 's%get_xmlrpc_size_limit=%network.xmlrpc.size_limit=%g' \
    -e 's%p\.get_address=%p.address=%g' \
    -e 's%p\.get_client_version=%p.client_version=%g' \
    -e 's%p\.get_completed_percent=%p.completed_percent=%g' \
    -e 's%p\.get_down_rate=%p.down_rate=%g' \
    -e 's%p\.get_down_total=%p.down_total=%g' \
    -e 's%p\.get_id_html=%p.id_html=%g' \
    -e 's%p\.get_id=%p.id=%g' \
    -e 's%p\.get_options_str=%p.options_str=%g' \
    -e 's%p\.get_peer_rate=%p.peer_rate=%g' \
    -e 's%p\.get_peer_total=%p.peer_total=%g' \
    -e 's%p\.get_port=%p.port=%g' \
    -e 's%p\.get_up_rate=%p.up_rate=%g' \
    -e 's%p\.get_up_total=%p.up_total=%g' \
    -e 's%^system\.method\.get=%method.get=%g' \
    -e 's%t\.get_group=%t.group=%g' \
    -e 's%t\.get_id=%t.id=%g' \
    -e 's%t\.get_min_interval=%t.min_interval=%g' \
    -e 's%t\.get_normal_interval=%t.normal_interval=%g' \
    -e 's%t\.get_scrape_complete=%t.scrape_complete=%g' \
    -e 's%t\.get_scrape_downloaded=%t.scrape_downloaded=%g' \
    -e 's%t\.get_scrape_incomplete=%t.scrape_incomplete=%g' \
    -e 's%t\.get_scrape_time_last=%t.scrape_time_last=%g' \
    -e 's%t\.get_type=%t.type=%g' \
    -e 's%t\.get_url=%t.url=%g' \
    -r

diff -U1 $rc_file,0.8.6 $rc_file || :

echo "WARNINGS:"
echo "  event.download.inserted_new is now also called at startup, you have:"
grep "event.download.inserted_new" $rc_file | sed -e "s/^/    /"


