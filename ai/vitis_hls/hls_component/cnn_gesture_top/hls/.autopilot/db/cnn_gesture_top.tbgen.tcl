set moduleName cnn_gesture_top
set isTopModule 1
set isCombinational 0
set isDatapathOnly 0
set isPipelined 0
set isPipelined_legacy 0
set pipeline_type none
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
set C_modelName {cnn_gesture_top}
set C_modelType { void 0 }
set ap_memory_interface_dict [dict create]
dict set ap_memory_interface_dict input_0 { MEM_WIDTH 16 MEM_SIZE 600 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
dict set ap_memory_interface_dict input_1 { MEM_WIDTH 16 MEM_SIZE 600 MASTER_TYPE BRAM_CTRL MEM_ADDRESS_MODE WORD_ADDRESS PACKAGE_IO port READ_LATENCY 1 }
set C_modelArgList {
	{ input_0 int 16 regular {array 300 { 1 1 } 1 1 }  }
	{ input_1 int 16 regular {array 300 { 1 1 } 1 1 }  }
	{ output_0 int 16 regular {pointer 1}  }
	{ output_1 int 16 regular {pointer 1}  }
	{ output_2 int 16 regular {pointer 1}  }
	{ output_3 int 16 regular {pointer 1}  }
	{ output_4 int 16 regular {pointer 1}  }
	{ output_5 int 16 regular {pointer 1}  }
}
set hasAXIMCache 0
set l_AXIML2Cache [list]
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "input_0", "interface" : "memory", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "input_1", "interface" : "memory", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "output_0", "interface" : "wire", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "output_1", "interface" : "wire", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "output_2", "interface" : "wire", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "output_3", "interface" : "wire", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "output_4", "interface" : "wire", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "output_5", "interface" : "wire", "bitwidth" : 16, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 30
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ input_0_address0 sc_out sc_lv 9 signal 0 } 
	{ input_0_ce0 sc_out sc_logic 1 signal 0 } 
	{ input_0_q0 sc_in sc_lv 16 signal 0 } 
	{ input_0_address1 sc_out sc_lv 9 signal 0 } 
	{ input_0_ce1 sc_out sc_logic 1 signal 0 } 
	{ input_0_q1 sc_in sc_lv 16 signal 0 } 
	{ input_1_address0 sc_out sc_lv 9 signal 1 } 
	{ input_1_ce0 sc_out sc_logic 1 signal 1 } 
	{ input_1_q0 sc_in sc_lv 16 signal 1 } 
	{ input_1_address1 sc_out sc_lv 9 signal 1 } 
	{ input_1_ce1 sc_out sc_logic 1 signal 1 } 
	{ input_1_q1 sc_in sc_lv 16 signal 1 } 
	{ output_0 sc_out sc_lv 16 signal 2 } 
	{ output_0_ap_vld sc_out sc_logic 1 outvld 2 } 
	{ output_1 sc_out sc_lv 16 signal 3 } 
	{ output_1_ap_vld sc_out sc_logic 1 outvld 3 } 
	{ output_2 sc_out sc_lv 16 signal 4 } 
	{ output_2_ap_vld sc_out sc_logic 1 outvld 4 } 
	{ output_3 sc_out sc_lv 16 signal 5 } 
	{ output_3_ap_vld sc_out sc_logic 1 outvld 5 } 
	{ output_4 sc_out sc_lv 16 signal 6 } 
	{ output_4_ap_vld sc_out sc_logic 1 outvld 6 } 
	{ output_5 sc_out sc_lv 16 signal 7 } 
	{ output_5_ap_vld sc_out sc_logic 1 outvld 7 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "input_0_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "input_0", "role": "address0" }} , 
 	{ "name": "input_0_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "input_0", "role": "ce0" }} , 
 	{ "name": "input_0_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "input_0", "role": "q0" }} , 
 	{ "name": "input_0_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "input_0", "role": "address1" }} , 
 	{ "name": "input_0_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "input_0", "role": "ce1" }} , 
 	{ "name": "input_0_q1", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "input_0", "role": "q1" }} , 
 	{ "name": "input_1_address0", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "input_1", "role": "address0" }} , 
 	{ "name": "input_1_ce0", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "input_1", "role": "ce0" }} , 
 	{ "name": "input_1_q0", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "input_1", "role": "q0" }} , 
 	{ "name": "input_1_address1", "direction": "out", "datatype": "sc_lv", "bitwidth":9, "type": "signal", "bundle":{"name": "input_1", "role": "address1" }} , 
 	{ "name": "input_1_ce1", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "input_1", "role": "ce1" }} , 
 	{ "name": "input_1_q1", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "input_1", "role": "q1" }} , 
 	{ "name": "output_0", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "output_0", "role": "default" }} , 
 	{ "name": "output_0_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "output_0", "role": "ap_vld" }} , 
 	{ "name": "output_1", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "output_1", "role": "default" }} , 
 	{ "name": "output_1_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "output_1", "role": "ap_vld" }} , 
 	{ "name": "output_2", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "output_2", "role": "default" }} , 
 	{ "name": "output_2_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "output_2", "role": "ap_vld" }} , 
 	{ "name": "output_3", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "output_3", "role": "default" }} , 
 	{ "name": "output_3_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "output_3", "role": "ap_vld" }} , 
 	{ "name": "output_4", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "output_4", "role": "default" }} , 
 	{ "name": "output_4_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "output_4", "role": "ap_vld" }} , 
 	{ "name": "output_5", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "output_5", "role": "default" }} , 
 	{ "name": "output_5_ap_vld", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "output_5", "role": "ap_vld" }}  ]}

set ArgLastReadFirstWriteLatency {
	cnn_gesture_top {
		input_0 {Type I LastRead 5 FirstWrite -1}
		input_1 {Type I LastRead 5 FirstWrite -1}
		output_0 {Type O LastRead -1 FirstWrite 30}
		output_1 {Type O LastRead -1 FirstWrite 30}
		output_2 {Type O LastRead -1 FirstWrite 30}
		output_3 {Type O LastRead -1 FirstWrite 30}
		output_4 {Type O LastRead -1 FirstWrite 30}
		output_5 {Type O LastRead -1 FirstWrite 30}
		p_ZL14conv1d_param_0_0 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_1 {Type I LastRead -1 FirstWrite -1}
		conv1d_param_1 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_param_0 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_param_1 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_param_2 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_param_3 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_0 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_1 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_2 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_3 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_4 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_5 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_6 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_7 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_8 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_9 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_10 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_11 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_12 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_13 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_14 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_15 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_16 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_17 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_18 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_19 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_20 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_21 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_22 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_23 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_24 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_25 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_26 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_27 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_28 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_29 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_30 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_31 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_32 {Type I LastRead -1 FirstWrite -1}
		conv1d_1_param_1 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_1_param_0 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_1_param_1 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_1_param_2 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_1_param_3 {Type I LastRead -1 FirstWrite -1}
		dense_param_1 {Type I LastRead -1 FirstWrite -1}
		dense_param_0 {Type I LastRead -1 FirstWrite -1}
		dense_1_param_1 {Type I LastRead -1 FirstWrite -1}
		dense_1_param_0 {Type I LastRead -1 FirstWrite -1}}
	cnn_gesture_top_Pipeline_VITIS_LOOP_39_1_VITIS_LOOP_40_2 {
		input_0 {Type I LastRead 5 FirstWrite -1}
		input_1 {Type I LastRead 5 FirstWrite -1}
		conv1_out {Type O LastRead -1 FirstWrite 50}
		p_ZL14conv1d_param_0_0 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_1 {Type I LastRead -1 FirstWrite -1}
		conv1d_param_1 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_param_0 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_param_1 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_param_2 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_param_3 {Type I LastRead -1 FirstWrite -1}}
	cnn_gesture_top_Pipeline_VITIS_LOOP_77_1_VITIS_LOOP_78_2 {
		pool1_out {Type O LastRead -1 FirstWrite 1}
		pool1_out_1 {Type O LastRead -1 FirstWrite 1}
		pool1_out_2 {Type O LastRead -1 FirstWrite 1}
		pool1_out_3 {Type O LastRead -1 FirstWrite 1}
		pool1_out_4 {Type O LastRead -1 FirstWrite 1}
		pool1_out_5 {Type O LastRead -1 FirstWrite 1}
		pool1_out_6 {Type O LastRead -1 FirstWrite 1}
		pool1_out_7 {Type O LastRead -1 FirstWrite 1}
		pool1_out_8 {Type O LastRead -1 FirstWrite 1}
		pool1_out_9 {Type O LastRead -1 FirstWrite 1}
		pool1_out_10 {Type O LastRead -1 FirstWrite 1}
		pool1_out_11 {Type O LastRead -1 FirstWrite 1}
		pool1_out_12 {Type O LastRead -1 FirstWrite 1}
		pool1_out_13 {Type O LastRead -1 FirstWrite 1}
		pool1_out_14 {Type O LastRead -1 FirstWrite 1}
		pool1_out_15 {Type O LastRead -1 FirstWrite 1}
		pool1_out_16 {Type O LastRead -1 FirstWrite 1}
		pool1_out_17 {Type O LastRead -1 FirstWrite 1}
		pool1_out_18 {Type O LastRead -1 FirstWrite 1}
		pool1_out_19 {Type O LastRead -1 FirstWrite 1}
		pool1_out_20 {Type O LastRead -1 FirstWrite 1}
		pool1_out_21 {Type O LastRead -1 FirstWrite 1}
		pool1_out_22 {Type O LastRead -1 FirstWrite 1}
		pool1_out_23 {Type O LastRead -1 FirstWrite 1}
		pool1_out_24 {Type O LastRead -1 FirstWrite 1}
		pool1_out_25 {Type O LastRead -1 FirstWrite 1}
		pool1_out_26 {Type O LastRead -1 FirstWrite 1}
		pool1_out_27 {Type O LastRead -1 FirstWrite 1}
		pool1_out_28 {Type O LastRead -1 FirstWrite 1}
		pool1_out_29 {Type O LastRead -1 FirstWrite 1}
		pool1_out_30 {Type O LastRead -1 FirstWrite 1}
		pool1_out_31 {Type O LastRead -1 FirstWrite 1}
		conv1_out {Type I LastRead 1 FirstWrite -1}}
	cnn_gesture_top_Pipeline_VITIS_LOOP_92_1_VITIS_LOOP_93_2_VITIS_LOOP_96_3 {
		conv2_out {Type O LastRead -1 FirstWrite 55}
		pool1_out {Type I LastRead 1 FirstWrite -1}
		pool1_out_1 {Type I LastRead 1 FirstWrite -1}
		pool1_out_2 {Type I LastRead 1 FirstWrite -1}
		pool1_out_3 {Type I LastRead 1 FirstWrite -1}
		pool1_out_4 {Type I LastRead 1 FirstWrite -1}
		pool1_out_5 {Type I LastRead 1 FirstWrite -1}
		pool1_out_6 {Type I LastRead 1 FirstWrite -1}
		pool1_out_7 {Type I LastRead 1 FirstWrite -1}
		pool1_out_8 {Type I LastRead 1 FirstWrite -1}
		pool1_out_9 {Type I LastRead 1 FirstWrite -1}
		pool1_out_10 {Type I LastRead 1 FirstWrite -1}
		pool1_out_11 {Type I LastRead 1 FirstWrite -1}
		pool1_out_12 {Type I LastRead 1 FirstWrite -1}
		pool1_out_13 {Type I LastRead 1 FirstWrite -1}
		pool1_out_14 {Type I LastRead 1 FirstWrite -1}
		pool1_out_15 {Type I LastRead 1 FirstWrite -1}
		pool1_out_16 {Type I LastRead 1 FirstWrite -1}
		pool1_out_17 {Type I LastRead 1 FirstWrite -1}
		pool1_out_18 {Type I LastRead 1 FirstWrite -1}
		pool1_out_19 {Type I LastRead 1 FirstWrite -1}
		pool1_out_20 {Type I LastRead 1 FirstWrite -1}
		pool1_out_21 {Type I LastRead 1 FirstWrite -1}
		pool1_out_22 {Type I LastRead 1 FirstWrite -1}
		pool1_out_23 {Type I LastRead 1 FirstWrite -1}
		pool1_out_24 {Type I LastRead 1 FirstWrite -1}
		pool1_out_25 {Type I LastRead 1 FirstWrite -1}
		pool1_out_26 {Type I LastRead 1 FirstWrite -1}
		pool1_out_27 {Type I LastRead 1 FirstWrite -1}
		pool1_out_28 {Type I LastRead 1 FirstWrite -1}
		pool1_out_29 {Type I LastRead 1 FirstWrite -1}
		pool1_out_30 {Type I LastRead 1 FirstWrite -1}
		pool1_out_31 {Type I LastRead 1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_0 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_1 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_2 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_3 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_4 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_5 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_6 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_7 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_8 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_9 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_10 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_11 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_12 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_13 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_14 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_15 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_16 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_17 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_18 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_19 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_20 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_21 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_22 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_23 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_24 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_25 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_26 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_27 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_28 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_29 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_30 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_31 {Type I LastRead -1 FirstWrite -1}
		p_ZL16conv1d_1_param_0_32 {Type I LastRead -1 FirstWrite -1}
		conv1d_1_param_1 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_1_param_0 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_1_param_1 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_1_param_2 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_1_param_3 {Type I LastRead -1 FirstWrite -1}}
	cnn_gesture_top_Pipeline_VITIS_LOOP_126_1_VITIS_LOOP_127_2 {
		conv2_out {Type I LastRead 1 FirstWrite -1}
		pool2_out {Type O LastRead -1 FirstWrite 1}}
	cnn_gesture_top_Pipeline_VITIS_LOOP_142_1_VITIS_LOOP_143_2 {
		pool2_out {Type I LastRead 0 FirstWrite -1}
		flat {Type O LastRead -1 FirstWrite 1}}
	cnn_gesture_top_Pipeline_VITIS_LOOP_160_2 {
		sext_ln158_2 {Type I LastRead 0 FirstWrite -1}
		empty {Type I LastRead 0 FirstWrite -1}
		flat {Type I LastRead 2 FirstWrite -1}
		sum_9_out {Type O LastRead -1 FirstWrite 5}
		dense_param_0 {Type I LastRead -1 FirstWrite -1}}
	cnn_gesture_top_Pipeline_VITIS_LOOP_178_2 {
		sext_ln176_2 {Type I LastRead 0 FirstWrite -1}
		zext_ln178 {Type I LastRead 0 FirstWrite -1}
		fc1 {Type I LastRead 2 FirstWrite -1}
		sum_11_out {Type O LastRead -1 FirstWrite 5}
		dense_1_param_0 {Type I LastRead -1 FirstWrite -1}}
	cnn_gesture_top_Pipeline_VITIS_LOOP_191_1 {
		max_v {Type I LastRead 0 FirstWrite -1}
		logits {Type I LastRead 0 FirstWrite -1}
		max_v_1_out {Type O LastRead -1 FirstWrite 0}}
	cnn_gesture_top_Pipeline_VITIS_LOOP_197_2 {
		logits {Type I LastRead 0 FirstWrite -1}
		sext_ln198 {Type I LastRead 0 FirstWrite -1}
		max_v_1_reload {Type I LastRead 0 FirstWrite -1}
		exps {Type O LastRead -1 FirstWrite 11}
		sum_7_out {Type O LastRead -1 FirstWrite 10}}
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
	{"Name" : "Latency", "Min" : "237898", "Max" : "237898"}
	, {"Name" : "Interval", "Min" : "237899", "Max" : "237899"}
]}

set PipelineEnableSignalInfo {[
]}

set Spec2ImplPortList { 
	input_0 { ap_memory {  { input_0_address0 mem_address 1 9 }  { input_0_ce0 mem_ce 1 1 }  { input_0_q0 mem_dout 0 16 }  { input_0_address1 MemPortADDR2 1 9 }  { input_0_ce1 MemPortCE2 1 1 }  { input_0_q1 MemPortDOUT2 0 16 } } }
	input_1 { ap_memory {  { input_1_address0 mem_address 1 9 }  { input_1_ce0 mem_ce 1 1 }  { input_1_q0 mem_dout 0 16 }  { input_1_address1 MemPortADDR2 1 9 }  { input_1_ce1 MemPortCE2 1 1 }  { input_1_q1 MemPortDOUT2 0 16 } } }
	output_0 { ap_vld {  { output_0 out_data 1 16 }  { output_0_ap_vld out_vld 1 1 } } }
	output_1 { ap_vld {  { output_1 out_data 1 16 }  { output_1_ap_vld out_vld 1 1 } } }
	output_2 { ap_vld {  { output_2 out_data 1 16 }  { output_2_ap_vld out_vld 1 1 } } }
	output_3 { ap_vld {  { output_3 out_data 1 16 }  { output_3_ap_vld out_vld 1 1 } } }
	output_4 { ap_vld {  { output_4 out_data 1 16 }  { output_4_ap_vld out_vld 1 1 } } }
	output_5 { ap_vld {  { output_5 out_data 1 16 }  { output_5_ap_vld out_vld 1 1 } } }
}

set maxi_interface_dict [dict create]

# RTL port scheduling information:
set fifoSchedulingInfoList { 
}

# RTL bus port read request latency information:
set busReadReqLatencyList { 
}

# RTL bus port write response latency information:
set busWriteResLatencyList { 
}

# RTL array port load latency information:
set memoryLoadLatencyList { 
}
