set moduleName cnn_gesture_top_Pipeline_VITIS_LOOP_160_2
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
set C_modelName {cnn_gesture_top_Pipeline_VITIS_LOOP_160_2}
set C_modelType { void 0 }
set ap_memory_interface_dict [dict create]
dict set ap_memory_interface_dict flat { MEM_WIDTH 16 MEM_SIZE 3200 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
set C_modelArgList {
	{ sext_ln158_2 int 26 regular  }
	{ empty int 7 regular  }
	{ flat int 16 regular {array 1600 { 1 3 } 1 1 }  }
	{ sum_9_out int 26 regular {pointer 1}  }
}
set hasAXIMCache 0
set l_AXIML2Cache [list]
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "sext_ln158_2", "interface" : "wire", "bitwidth" : 26, "direction" : "READONLY"} , 
 	{ "Name" : "empty", "interface" : "wire", "bitwidth" : 7, "direction" : "READONLY"} , 
 	{ "Name" : "flat", "interface" : "memory", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "sum_9_out", "interface" : "wire", "bitwidth" : 26, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 16
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ sext_ln158_2 sc_in sc_lv 26 signal 0 } 
	{ empty sc_in sc_lv 7 signal 1 } 
	{ flat_address0 sc_out sc_lv 11 signal 2 } 
	{ flat_ce0 sc_out sc_logic 1 signal 2 } 
	{ flat_q0 sc_in sc_lv 16 signal 2 } 
	{ sum_9_out sc_out sc_lv 26 signal 3 } 
	{ sum_9_out_ap_vld sc_out sc_logic 1 outvld 3 } 
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
 	{ "name": "sext_ln158_2", "direction": "in", "datatype": "sc_lv", "bitwidth":26, "type": "signal", "bundle":{"name": "sext_ln158_2", "role": "default" }} , 
 	{ "name": "empty", "direction": "in", "datatype": "sc_lv", "bitwidth":7, "type": "signal", "bundle":{"name": "empty", "role": "default" }} , 
 	{ "name": "flat_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":11, "type": "signal", "bundle":{"name": "flat", "role": "address0" }} , 
 	{ "name": "flat_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "flat", "role": "ce0" }} , 
 	{ "name": "flat_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "flat", "role": "q0" }} , 
 	{ "name": "sum_9_out", "direction": "out", "datatype": "sc_lv", "bitwidth":26, "type": "signal", "bundle":{"name": "sum_9_out", "role": "default" }} , 
 	{ "name": "sum_9_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "sum_9_out", "role": "ap_vld" }} , 
 	{ "name": "grp_fu_724_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_724_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_724_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "grp_fu_724_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_724_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_724_p_ce", "role": "default" }}  ]}

set ArgLastReadFirstWriteLatency {
	cnn_gesture_top_Pipeline_VITIS_LOOP_160_2 {
		sext_ln158_2 {Type I LastRead 0 FirstWrite -1}
		empty {Type I LastRead 0 FirstWrite -1}
		flat {Type I LastRead 2 FirstWrite -1}
		sum_9_out {Type O LastRead -1 FirstWrite 5}
		dense_param_0 {Type I LastRead -1 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "1607", "Max" : "1607"}
	, {"Name" : "Interval", "Min" : "1601", "Max" : "1601"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	sext_ln158_2 { ap_none {  { sext_ln158_2 in_data 0 26 } } }
	empty { ap_none {  { empty in_data 0 7 } } }
	flat { ap_memory {  { flat_address0 mem_address 1 11 }  { flat_ce0 mem_ce 1 1 }  { flat_q0 mem_dout 0 16 } } }
	sum_9_out { ap_vld {  { sum_9_out out_data 1 26 }  { sum_9_out_ap_vld out_vld 1 1 } } }
}
