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
set cdfgNum 10
set C_modelName {cnn_gesture_top}
set C_modelType { void 0 }
set ap_memory_interface_dict [dict create]
set C_modelArgList {
	{ input_stream_V_data_V int 32 regular {axi_s 0 volatile  { input_stream Data } }  }
	{ input_stream_V_keep_V int 4 regular {axi_s 0 volatile  { input_stream Keep } }  }
	{ input_stream_V_strb_V int 4 regular {axi_s 0 volatile  { input_stream Strb } }  }
	{ input_stream_V_last_V int 1 regular {axi_s 0 volatile  { input_stream Last } }  }
	{ output_stream_V_data_V int 32 regular {axi_s 1 volatile  { output_stream Data } }  }
	{ output_stream_V_keep_V int 4 regular {axi_s 1 volatile  { output_stream Keep } }  }
	{ output_stream_V_strb_V int 4 regular {axi_s 1 volatile  { output_stream Strb } }  }
	{ output_stream_V_last_V int 1 regular {axi_s 1 volatile  { output_stream Last } }  }
}
set hasAXIMCache 0
set l_AXIML2Cache [list]
set AXIMCacheInstDict [dict create]
set C_modelArgMapList {[ 
	{ "Name" : "input_stream_V_data_V", "interface" : "axis", "bitwidth" : 32, "direction" : "READONLY"} , 
 	{ "Name" : "input_stream_V_keep_V", "interface" : "axis", "bitwidth" : 4, "direction" : "READONLY"} , 
 	{ "Name" : "input_stream_V_strb_V", "interface" : "axis", "bitwidth" : 4, "direction" : "READONLY"} , 
 	{ "Name" : "input_stream_V_last_V", "interface" : "axis", "bitwidth" : 1, "direction" : "READONLY"} , 
 	{ "Name" : "output_stream_V_data_V", "interface" : "axis", "bitwidth" : 32, "direction" : "WRITEONLY"} , 
 	{ "Name" : "output_stream_V_keep_V", "interface" : "axis", "bitwidth" : 4, "direction" : "WRITEONLY"} , 
 	{ "Name" : "output_stream_V_strb_V", "interface" : "axis", "bitwidth" : 4, "direction" : "WRITEONLY"} , 
 	{ "Name" : "output_stream_V_last_V", "interface" : "axis", "bitwidth" : 1, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 32
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst_n sc_in sc_logic 1 reset -1 active_low_sync } 
	{ input_stream_TDATA sc_in sc_lv 32 signal 0 } 
	{ input_stream_TVALID sc_in sc_logic 1 invld 3 } 
	{ input_stream_TREADY sc_out sc_logic 1 inacc 3 } 
	{ input_stream_TKEEP sc_in sc_lv 4 signal 1 } 
	{ input_stream_TSTRB sc_in sc_lv 4 signal 2 } 
	{ input_stream_TLAST sc_in sc_lv 1 signal 3 } 
	{ output_stream_TDATA sc_out sc_lv 32 signal 4 } 
	{ output_stream_TVALID sc_out sc_logic 1 outvld 7 } 
	{ output_stream_TREADY sc_in sc_logic 1 outacc 7 } 
	{ output_stream_TKEEP sc_out sc_lv 4 signal 5 } 
	{ output_stream_TSTRB sc_out sc_lv 4 signal 6 } 
	{ output_stream_TLAST sc_out sc_lv 1 signal 7 } 
	{ s_axi_CTRL_AWVALID sc_in sc_logic 1 signal -1 } 
	{ s_axi_CTRL_AWREADY sc_out sc_logic 1 signal -1 } 
	{ s_axi_CTRL_AWADDR sc_in sc_lv 4 signal -1 } 
	{ s_axi_CTRL_WVALID sc_in sc_logic 1 signal -1 } 
	{ s_axi_CTRL_WREADY sc_out sc_logic 1 signal -1 } 
	{ s_axi_CTRL_WDATA sc_in sc_lv 32 signal -1 } 
	{ s_axi_CTRL_WSTRB sc_in sc_lv 4 signal -1 } 
	{ s_axi_CTRL_ARVALID sc_in sc_logic 1 signal -1 } 
	{ s_axi_CTRL_ARREADY sc_out sc_logic 1 signal -1 } 
	{ s_axi_CTRL_ARADDR sc_in sc_lv 4 signal -1 } 
	{ s_axi_CTRL_RVALID sc_out sc_logic 1 signal -1 } 
	{ s_axi_CTRL_RREADY sc_in sc_logic 1 signal -1 } 
	{ s_axi_CTRL_RDATA sc_out sc_lv 32 signal -1 } 
	{ s_axi_CTRL_RRESP sc_out sc_lv 2 signal -1 } 
	{ s_axi_CTRL_BVALID sc_out sc_logic 1 signal -1 } 
	{ s_axi_CTRL_BREADY sc_in sc_logic 1 signal -1 } 
	{ s_axi_CTRL_BRESP sc_out sc_lv 2 signal -1 } 
	{ interrupt sc_out sc_logic 1 signal -1 } 
}
set NewPortList {[ 
	{ "name": "s_axi_CTRL_AWADDR", "direction": "in", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "CTRL", "role": "AWADDR" },"address":[{"name":"cnn_gesture_top","role":"start","value":"0","valid_bit":"0"},{"name":"cnn_gesture_top","role":"continue","value":"0","valid_bit":"4"},{"name":"cnn_gesture_top","role":"auto_start","value":"0","valid_bit":"7"}] },
	{ "name": "s_axi_CTRL_AWVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "CTRL", "role": "AWVALID" } },
	{ "name": "s_axi_CTRL_AWREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "CTRL", "role": "AWREADY" } },
	{ "name": "s_axi_CTRL_WVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "CTRL", "role": "WVALID" } },
	{ "name": "s_axi_CTRL_WREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "CTRL", "role": "WREADY" } },
	{ "name": "s_axi_CTRL_WDATA", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "CTRL", "role": "WDATA" } },
	{ "name": "s_axi_CTRL_WSTRB", "direction": "in", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "CTRL", "role": "WSTRB" } },
	{ "name": "s_axi_CTRL_ARADDR", "direction": "in", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "CTRL", "role": "ARADDR" },"address":[{"name":"cnn_gesture_top","role":"start","value":"0","valid_bit":"0"},{"name":"cnn_gesture_top","role":"done","value":"0","valid_bit":"1"},{"name":"cnn_gesture_top","role":"idle","value":"0","valid_bit":"2"},{"name":"cnn_gesture_top","role":"ready","value":"0","valid_bit":"3"},{"name":"cnn_gesture_top","role":"auto_start","value":"0","valid_bit":"7"}] },
	{ "name": "s_axi_CTRL_ARVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "CTRL", "role": "ARVALID" } },
	{ "name": "s_axi_CTRL_ARREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "CTRL", "role": "ARREADY" } },
	{ "name": "s_axi_CTRL_RVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "CTRL", "role": "RVALID" } },
	{ "name": "s_axi_CTRL_RREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "CTRL", "role": "RREADY" } },
	{ "name": "s_axi_CTRL_RDATA", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "CTRL", "role": "RDATA" } },
	{ "name": "s_axi_CTRL_RRESP", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "CTRL", "role": "RRESP" } },
	{ "name": "s_axi_CTRL_BVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "CTRL", "role": "BVALID" } },
	{ "name": "s_axi_CTRL_BREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "CTRL", "role": "BREADY" } },
	{ "name": "s_axi_CTRL_BRESP", "direction": "out", "datatype": "sc_lv", "bitwidth":2, "type": "signal", "bundle":{"name": "CTRL", "role": "BRESP" } },
	{ "name": "interrupt", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "CTRL", "role": "interrupt" } }, 
 	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst_n", "role": "default" }} , 
 	{ "name": "input_stream_TDATA", "direction": "in", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "input_stream_V_data_V", "role": "default" }} , 
 	{ "name": "input_stream_TVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "invld", "bundle":{"name": "input_stream_V_last_V", "role": "default" }} , 
 	{ "name": "input_stream_TREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "inacc", "bundle":{"name": "input_stream_V_last_V", "role": "default" }} , 
 	{ "name": "input_stream_TKEEP", "direction": "in", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "input_stream_V_keep_V", "role": "default" }} , 
 	{ "name": "input_stream_TSTRB", "direction": "in", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "input_stream_V_strb_V", "role": "default" }} , 
 	{ "name": "input_stream_TLAST", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "input_stream_V_last_V", "role": "default" }} , 
 	{ "name": "output_stream_TDATA", "direction": "out", "datatype": "sc_lv", "bitwidth":32, "type": "signal", "bundle":{"name": "output_stream_V_data_V", "role": "default" }} , 
 	{ "name": "output_stream_TVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "output_stream_V_last_V", "role": "default" }} , 
 	{ "name": "output_stream_TREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "outacc", "bundle":{"name": "output_stream_V_last_V", "role": "default" }} , 
 	{ "name": "output_stream_TKEEP", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "output_stream_V_keep_V", "role": "default" }} , 
 	{ "name": "output_stream_TSTRB", "direction": "out", "datatype": "sc_lv", "bitwidth":4, "type": "signal", "bundle":{"name": "output_stream_V_strb_V", "role": "default" }} , 
 	{ "name": "output_stream_TLAST", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "output_stream_V_last_V", "role": "default" }}  ]}

set ArgLastReadFirstWriteLatency {
	cnn_gesture_top {
		input_stream_V_data_V {Type I LastRead 1 FirstWrite -1}
		input_stream_V_keep_V {Type I LastRead 1 FirstWrite -1}
		input_stream_V_strb_V {Type I LastRead 1 FirstWrite -1}
		input_stream_V_last_V {Type I LastRead 1 FirstWrite -1}
		output_stream_V_data_V {Type O LastRead -1 FirstWrite 4}
		output_stream_V_keep_V {Type O LastRead -1 FirstWrite 4}
		output_stream_V_strb_V {Type O LastRead -1 FirstWrite 4}
		output_stream_V_last_V {Type O LastRead -1 FirstWrite 4}
		B {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_5 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_4 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_3 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_2 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_1 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W {Type I LastRead -1 FirstWrite -1}}
	tiny_classifier {
		input_stream_V_data_V {Type I LastRead 1 FirstWrite -1}
		input_stream_V_keep_V {Type I LastRead 1 FirstWrite -1}
		input_stream_V_strb_V {Type I LastRead 1 FirstWrite -1}
		input_stream_V_last_V {Type I LastRead 1 FirstWrite -1}
		output_probs {Type O LastRead -1 FirstWrite 5}
		B {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_5 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_4 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_3 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_2 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_1 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W {Type I LastRead -1 FirstWrite -1}}
	tiny_classifier_Pipeline_VITIS_LOOP_74_2_VITIS_LOOP_75_3 {
		input_stream_V_data_V {Type I LastRead 1 FirstWrite -1}
		input_stream_V_keep_V {Type I LastRead 1 FirstWrite -1}
		input_stream_V_strb_V {Type I LastRead 1 FirstWrite -1}
		input_stream_V_last_V {Type I LastRead 1 FirstWrite -1}
		feature_sum_load_out {Type O LastRead -1 FirstWrite 3}
		feature_sum_1_load_out {Type O LastRead -1 FirstWrite 3}
		feature_sum_2_load_out {Type O LastRead -1 FirstWrite 3}
		feature_sum_3_load_out {Type O LastRead -1 FirstWrite 3}
		feature_sum_4_load_out {Type O LastRead -1 FirstWrite 3}
		feature_sum_5_load_out {Type O LastRead -1 FirstWrite 3}}
	tiny_classifier_Pipeline_VITIS_LOOP_85_4 {
		feature_sum_load_reload {Type I LastRead 0 FirstWrite -1}
		feature_sum_1_load_reload {Type I LastRead 0 FirstWrite -1}
		feature_sum_2_load_reload {Type I LastRead 0 FirstWrite -1}
		feature_sum_3_load_reload {Type I LastRead 0 FirstWrite -1}
		feature_sum_4_load_reload {Type I LastRead 0 FirstWrite -1}
		feature_sum_5_load_reload {Type I LastRead 0 FirstWrite -1}
		mux_case_52547_out {Type O LastRead -1 FirstWrite 2}
		mux_case_42343_out {Type O LastRead -1 FirstWrite 2}
		mux_case_32139_out {Type O LastRead -1 FirstWrite 2}
		mux_case_21935_out {Type O LastRead -1 FirstWrite 2}
		mux_case_11731_out {Type O LastRead -1 FirstWrite 2}
		mux_case_01527_out {Type O LastRead -1 FirstWrite 2}}
	tiny_classifier_Pipeline_VITIS_LOOP_90_5 {
		mux_case_01527_reload {Type I LastRead 0 FirstWrite -1}
		mux_case_11731_reload {Type I LastRead 0 FirstWrite -1}
		mux_case_21935_reload {Type I LastRead 0 FirstWrite -1}
		mux_case_32139_reload {Type I LastRead 0 FirstWrite -1}
		mux_case_42343_reload {Type I LastRead 0 FirstWrite -1}
		mux_case_52547_reload {Type I LastRead 0 FirstWrite -1}
		logits {Type O LastRead -1 FirstWrite 28}
		B {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_5 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_4 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_3 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_2 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W_1 {Type I LastRead -1 FirstWrite -1}
		tiny_classifier_stream_axis_0_float_W {Type I LastRead -1 FirstWrite -1}}
	tiny_classifier_Pipeline_VITIS_LOOP_33_1 {
		max_v {Type I LastRead 0 FirstWrite -1}
		logits {Type I LastRead 0 FirstWrite -1}
		max_v_1_out {Type O LastRead -1 FirstWrite 1}}
	tiny_classifier_Pipeline_VITIS_LOOP_39_2 {
		logits {Type I LastRead 0 FirstWrite -1}
		max_v_1_reload {Type I LastRead 0 FirstWrite -1}
		exps {Type O LastRead -1 FirstWrite 12}
		sum_out {Type O LastRead -1 FirstWrite 14}}
	tiny_classifier_Pipeline_VITIS_LOOP_45_3 {
		exps {Type I LastRead 0 FirstWrite -1}
		inv {Type I LastRead 0 FirstWrite -1}
		output_probs {Type O LastRead -1 FirstWrite 5}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "737", "Max" : "737"}
	, {"Name" : "Interval", "Min" : "738", "Max" : "738"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	input_stream_V_data_V { axis {  { input_stream_TDATA in_data 0 32 } } }
	input_stream_V_keep_V { axis {  { input_stream_TKEEP in_data 0 4 } } }
	input_stream_V_strb_V { axis {  { input_stream_TSTRB in_data 0 4 } } }
	input_stream_V_last_V { axis {  { input_stream_TVALID in_vld 0 1 }  { input_stream_TREADY in_acc 1 1 }  { input_stream_TLAST in_data 0 1 } } }
	output_stream_V_data_V { axis {  { output_stream_TDATA out_data 1 32 } } }
	output_stream_V_keep_V { axis {  { output_stream_TKEEP out_data 1 4 } } }
	output_stream_V_strb_V { axis {  { output_stream_TSTRB out_data 1 4 } } }
	output_stream_V_last_V { axis {  { output_stream_TVALID out_vld 1 1 }  { output_stream_TREADY out_acc 0 1 }  { output_stream_TLAST out_data 1 1 } } }
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
