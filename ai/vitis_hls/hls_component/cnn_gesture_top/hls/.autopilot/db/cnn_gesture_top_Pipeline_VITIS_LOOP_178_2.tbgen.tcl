set moduleName cnn_gesture_top_Pipeline_VITIS_LOOP_178_2
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
set C_modelName {cnn_gesture_top_Pipeline_VITIS_LOOP_178_2}
set C_modelType { void 0 }
set ap_memory_interface_dict [dict create]
dict set ap_memory_interface_dict fc1 { MEM_WIDTH 15 MEM_SIZE 256 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
set C_modelArgList {
	{ sext_ln176_2 int 26 regular  }
	{ zext_ln178 int 3 regular  }
	{ fc1 int 15 regular {array 128 { 1 3 } 1 1 }  }
	{ sum_11_out int 26 regular {pointer 1}  }
}
set hasAXIMCache 0
set l_AXIML2Cache [list]
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "sext_ln176_2", "interface" : "wire", "bitwidth" : 26, "direction" : "READONLY"} , 
 	{ "Name" : "zext_ln178", "interface" : "wire", "bitwidth" : 3, "direction" : "READONLY"} , 
 	{ "Name" : "fc1", "interface" : "memory", "bitwidth" : 15, "direction" : "READONLY"} , 
 	{ "Name" : "sum_11_out", "interface" : "wire", "bitwidth" : 26, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 16
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ sext_ln176_2 sc_in sc_lv 26 signal 0 } 
	{ zext_ln178 sc_in sc_lv 3 signal 1 } 
	{ fc1_address0 sc_out sc_lv 7 signal 2 } 
	{ fc1_ce0 sc_out sc_logic 1 signal 2 } 
	{ fc1_q0 sc_in sc_lv 15 signal 2 } 
	{ sum_11_out sc_out sc_lv 26 signal 3 } 
	{ sum_11_out_ap_vld sc_out sc_logic 1 outvld 3 } 
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
 	{ "name": "sext_ln176_2", "direction": "in", "datatype": "sc_lv", "bitwidth":26, "type": "signal", "bundle":{"name": "sext_ln176_2", "role": "default" }} , 
 	{ "name": "zext_ln178", "direction": "in", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "zext_ln178", "role": "default" }} , 
 	{ "name": "fc1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":7, "type": "signal", "bundle":{"name": "fc1", "role": "address0" }} , 
 	{ "name": "fc1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "fc1", "role": "ce0" }} , 
 	{ "name": "fc1_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":15, "type": "signal", "bundle":{"name": "fc1", "role": "q0" }} , 
 	{ "name": "sum_11_out", "direction": "out", "datatype": "sc_lv", "bitwidth":26, "type": "signal", "bundle":{"name": "sum_11_out", "role": "default" }} , 
 	{ "name": "sum_11_out_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "sum_11_out", "role": "ap_vld" }} , 
 	{ "name": "grp_fu_724_p_din0", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "grp_fu_724_p_din0", "role": "default" }} , 
 	{ "name": "grp_fu_724_p_dout0", "direction": "in", "datatype": "sc_lv", "bitwidth":64, "type": "signal", "bundle":{"name": "grp_fu_724_p_dout0", "role": "default" }} , 
 	{ "name": "grp_fu_724_p_ce", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grp_fu_724_p_ce", "role": "default" }}  ]}

set ArgLastReadFirstWriteLatency {
	cnn_gesture_top_Pipeline_VITIS_LOOP_178_2 {
		sext_ln176_2 {Type I LastRead 0 FirstWrite -1}
		zext_ln178 {Type I LastRead 0 FirstWrite -1}
		fc1 {Type I LastRead 2 FirstWrite -1}
		sum_11_out {Type O LastRead -1 FirstWrite 5}
		dense_1_param_0 {Type I LastRead -1 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "135", "Max" : "135"}
	, {"Name" : "Interval", "Min" : "129", "Max" : "129"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	sext_ln176_2 { ap_none {  { sext_ln176_2 in_data 0 26 } } }
	zext_ln178 { ap_none {  { zext_ln178 in_data 0 3 } } }
	fc1 { ap_memory {  { fc1_address0 mem_address 1 7 }  { fc1_ce0 mem_ce 1 1 }  { fc1_q0 mem_dout 0 15 } } }
	sum_11_out { ap_vld {  { sum_11_out out_data 1 26 }  { sum_11_out_ap_vld out_vld 1 1 } } }
}
