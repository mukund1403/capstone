set moduleName cnn_gesture_top_Pipeline_VITIS_LOOP_197_2
set isTopModule 0
set isCombinational 0
set isDatapathOnly 0
set isPipelined 1
set isPipelined_legacy 1
set pipeline_type loop_auto_rewind
set FunctionProtocol ap_ctrl_hs
set restart_counter_num 0
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set hasInterrupt 0
set DLRegFirstOffset 0
set DLRegItemOffset 0
set svuvm_can_support 1
set cdfgNum 13
set C_modelName {cnn_gesture_top_Pipeline_VITIS_LOOP_197_2}
set C_modelType { void 0 }
set ap_memory_interface_dict [dict create]
dict set ap_memory_interface_dict logits { MEM_WIDTH 16 MEM_SIZE 12 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict exps { MEM_WIDTH 16 MEM_SIZE 12 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 0 }
set C_modelArgList {
	{ logits int 16 regular {array 6 { 1 3 } 1 1 }  }
	{ sext_ln198 int 16 regular  }
	{ max_v_1_reload int 16 regular  }
	{ exps int 16 regular {array 6 { 0 3 } 0 1 }  }
	{ sum_7_out int 16 regular {pointer 1}  }
}
set hasAXIMCache 0
set l_AXIML2Cache [list]
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "logits", "interface" : "memory", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "sext_ln198", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "max_v_1_reload", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "exps", "interface" : "memory", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "sum_7_out", "interface" : "wire", "bitwidth" : 16, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 20
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ logits_address0 sc_out sc_lv 3 signal 0 } 
	{ logits_ce0 sc_out sc_logic 1 signal 0 } 
	{ logits_q0 sc_in sc_lv 16 signal 0 } 
	{ sext_ln198 sc_in sc_lv 16 signal 1 } 
	{ max_v_1_reload sc_in sc_lv 16 signal 2 } 
	{ exps_address0 sc_out sc_lv 3 signal 3 } 
	{ exps_ce0 sc_out sc_logic 1 signal 3 } 
	{ exps_we0 sc_out sc_logic 1 signal 3 } 
	{ exps_d0 sc_out sc_lv 16 signal 3 } 
	{ sum_7_out sc_out sc_lv 16 signal 4 } 
	{ sum_7_out_ap_vld sc_out sc_logic 1 outvld 4 } 
	{ grp_fu_724_p_din0 sc_out sc_lv 32 signal -1 } 
	{ grp_fu_724_p_dout0 sc_in sc_lv 64 signal -1 } 
	{ grp_fu_724_p_ce sc_out sc_logic 1 signal -1 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "logits_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "logits", "role": "address0" }} , 
 	{ "name": "logits_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "logits", "role": "ce0" }} , 
 	{ "name": "logits_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "logits", "role": "q0" }} , 
 	{ "name": "sext_ln198", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "sext_ln198", "role": "default" }} , 
 	{ "name": "max_v_1_reload", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "max_v_1_reload", "role": "default" }} , 
 	{ "name": "exps_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "exps", "role": "address0" }} , 
 	{ "name": "exps_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "exps", "role": "ce0" }} , 
 	{ "name": "exps_we0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "exps", "role": "we0" }} , 
 	{ "name": "exps_d0", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "exps", "role": "d0" }} , 
 	{ "name": "sum_7_out", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "sum_7_out", "role": "default" }} , 
 	{ "name": "sum_7_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "sum_7_out", "role": "ap_vld" }} , 
 	{ "name": "grp_fu_724_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_724_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_724_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "grp_fu_724_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_724_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_724_p_ce", "role": "default" }}  ]}

set ArgLastReadFirstWriteLatency {
	cnn_gesture_top_Pipeline_VITIS_LOOP_197_2 {
		logits {Type I LastRead 0 FirstWrite -1}
		sext_ln198 {Type I LastRead 0 FirstWrite -1}
		max_v_1_reload {Type I LastRead 0 FirstWrite -1}
		exps {Type O LastRead -1 FirstWrite 11}
		sum_7_out {Type O LastRead -1 FirstWrite 10}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "18", "Max" : "18"}
	, {"Name" : "Interval", "Min" : "7", "Max" : "7"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	logits { ap_memory {  { logits_address0 mem_address 1 3 }  { logits_ce0 mem_ce 1 1 }  { logits_q0 mem_dout 0 16 } } }
	sext_ln198 { ap_none {  { sext_ln198 in_data 0 16 } } }
	max_v_1_reload { ap_none {  { max_v_1_reload in_data 0 16 } } }
	exps { ap_memory {  { exps_address0 mem_address 1 3 }  { exps_ce0 mem_ce 1 1 }  { exps_we0 mem_we 1 1 }  { exps_d0 mem_din 1 16 } } }
	sum_7_out { ap_vld {  { sum_7_out out_data 1 16 }  { sum_7_out_ap_vld out_vld 1 1 } } }
}
