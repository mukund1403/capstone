set moduleName cnn_gesture_top_Pipeline_VITIS_LOOP_202_3
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
set C_modelName {cnn_gesture_top_Pipeline_VITIS_LOOP_202_3}
set C_modelType { void 0 }
set ap_memory_interface_dict [dict create]
dict set ap_memory_interface_dict exps { MEM_WIDTH 16 MEM_SIZE 12 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
set C_modelArgList {
	{ output_0 int 16 regular {pointer 1}  }
	{ output_5 int 16 regular {pointer 1}  }
	{ output_4 int 16 regular {pointer 1}  }
	{ output_3 int 16 regular {pointer 1}  }
	{ output_2 int 16 regular {pointer 1}  }
	{ output_1 int 16 regular {pointer 1}  }
	{ exps int 16 regular {array 6 { 1 3 } 1 1 }  }
	{ sext_ln202 int 16 regular  }
}
set hasAXIMCache 0
set l_AXIML2Cache [list]
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "output_0", "interface" : "wire", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "output_5", "interface" : "wire", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "output_4", "interface" : "wire", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "output_3", "interface" : "wire", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "output_2", "interface" : "wire", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "output_1", "interface" : "wire", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "exps", "interface" : "memory", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "sext_ln202", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} ]}
# RTL Port declarations: 
set portNum 22
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ output_0 sc_out sc_lv 16 signal 0 } 
	{ output_0_ap_vld sc_out sc_logic 1 outvld 0 } 
	{ output_5 sc_out sc_lv 16 signal 1 } 
	{ output_5_ap_vld sc_out sc_logic 1 outvld 1 } 
	{ output_4 sc_out sc_lv 16 signal 2 } 
	{ output_4_ap_vld sc_out sc_logic 1 outvld 2 } 
	{ output_3 sc_out sc_lv 16 signal 3 } 
	{ output_3_ap_vld sc_out sc_logic 1 outvld 3 } 
	{ output_2 sc_out sc_lv 16 signal 4 } 
	{ output_2_ap_vld sc_out sc_logic 1 outvld 4 } 
	{ output_1 sc_out sc_lv 16 signal 5 } 
	{ output_1_ap_vld sc_out sc_logic 1 outvld 5 } 
	{ exps_address0 sc_out sc_lv 3 signal 6 } 
	{ exps_ce0 sc_out sc_logic 1 signal 6 } 
	{ exps_q0 sc_in sc_lv 16 signal 6 } 
	{ sext_ln202 sc_in sc_lv 16 signal 7 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "output_0", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "output_0", "role": "default" }} , 
 	{ "name": "output_0_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "output_0", "role": "ap_vld" }} , 
 	{ "name": "output_5", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "output_5", "role": "default" }} , 
 	{ "name": "output_5_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "output_5", "role": "ap_vld" }} , 
 	{ "name": "output_4", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "output_4", "role": "default" }} , 
 	{ "name": "output_4_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "output_4", "role": "ap_vld" }} , 
 	{ "name": "output_3", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "output_3", "role": "default" }} , 
 	{ "name": "output_3_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "output_3", "role": "ap_vld" }} , 
 	{ "name": "output_2", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "output_2", "role": "default" }} , 
 	{ "name": "output_2_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "output_2", "role": "ap_vld" }} , 
 	{ "name": "output_1", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "output_1", "role": "default" }} , 
 	{ "name": "output_1_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "output_1", "role": "ap_vld" }} , 
 	{ "name": "exps_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "exps", "role": "address0" }} , 
 	{ "name": "exps_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "exps", "role": "ce0" }} , 
 	{ "name": "exps_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "exps", "role": "q0" }} , 
 	{ "name": "sext_ln202", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "sext_ln202", "role": "default" }}  ]}

set ArgLastReadFirstWriteLatency {
	cnn_gesture_top_Pipeline_VITIS_LOOP_202_3 {
		output_0 {Type O LastRead -1 FirstWrite 30}
		output_5 {Type O LastRead -1 FirstWrite 30}
		output_4 {Type O LastRead -1 FirstWrite 30}
		output_3 {Type O LastRead -1 FirstWrite 30}
		output_2 {Type O LastRead -1 FirstWrite 30}
		output_1 {Type O LastRead -1 FirstWrite 30}
		exps {Type I LastRead 0 FirstWrite -1}
		sext_ln202 {Type I LastRead 0 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "37", "Max" : "37"}
	, {"Name" : "Interval", "Min" : "7", "Max" : "7"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	output_0 { ap_vld {  { output_0 out_data 1 16 }  { output_0_ap_vld out_vld 1 1 } } }
	output_5 { ap_vld {  { output_5 out_data 1 16 }  { output_5_ap_vld out_vld 1 1 } } }
	output_4 { ap_vld {  { output_4 out_data 1 16 }  { output_4_ap_vld out_vld 1 1 } } }
	output_3 { ap_vld {  { output_3 out_data 1 16 }  { output_3_ap_vld out_vld 1 1 } } }
	output_2 { ap_vld {  { output_2 out_data 1 16 }  { output_2_ap_vld out_vld 1 1 } } }
	output_1 { ap_vld {  { output_1 out_data 1 16 }  { output_1_ap_vld out_vld 1 1 } } }
	exps { ap_memory {  { exps_address0 mem_address 1 3 }  { exps_ce0 mem_ce 1 1 }  { exps_q0 mem_dout 0 16 } } }
	sext_ln202 { ap_none {  { sext_ln202 in_data 0 16 } } }
}
