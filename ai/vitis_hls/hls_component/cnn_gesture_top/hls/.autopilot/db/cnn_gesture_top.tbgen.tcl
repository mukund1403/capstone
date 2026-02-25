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
set cdfgNum 16
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
		input_stream_V_data_V {Type I LastRead 8 FirstWrite -1}
		input_stream_V_keep_V {Type I LastRead 8 FirstWrite -1}
		input_stream_V_strb_V {Type I LastRead 8 FirstWrite -1}
		input_stream_V_last_V {Type I LastRead 8 FirstWrite -1}
		output_stream_V_data_V {Type O LastRead -1 FirstWrite 1}
		output_stream_V_keep_V {Type O LastRead -1 FirstWrite 1}
		output_stream_V_strb_V {Type O LastRead -1 FirstWrite 1}
		output_stream_V_last_V {Type O LastRead -1 FirstWrite 1}
		p_ZL14conv1d_param_0_0 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_1 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_2 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_3 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_4 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_5 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_6 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_7 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_8 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_9 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_10 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_11 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_12 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_13 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_14 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_15 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_16 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_17 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_18 {Type I LastRead -1 FirstWrite -1}
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
	cnn_gesture_top_Pipeline_VITIS_LOOP_270_1_VITIS_LOOP_271_2 {
		input_r {Type O LastRead -1 FirstWrite 10}
		input_1 {Type O LastRead -1 FirstWrite 10}
		input_2 {Type O LastRead -1 FirstWrite 10}
		input_3 {Type O LastRead -1 FirstWrite 10}
		input_4 {Type O LastRead -1 FirstWrite 10}
		input_5 {Type O LastRead -1 FirstWrite 10}
		input_6 {Type O LastRead -1 FirstWrite 10}
		input_7 {Type O LastRead -1 FirstWrite 10}
		input_8 {Type O LastRead -1 FirstWrite 10}
		input_9 {Type O LastRead -1 FirstWrite 10}
		input_10 {Type O LastRead -1 FirstWrite 10}
		input_11 {Type O LastRead -1 FirstWrite 10}
		input_12 {Type O LastRead -1 FirstWrite 10}
		input_13 {Type O LastRead -1 FirstWrite 10}
		input_14 {Type O LastRead -1 FirstWrite 10}
		input_15 {Type O LastRead -1 FirstWrite 10}
		input_16 {Type O LastRead -1 FirstWrite 10}
		input_17 {Type O LastRead -1 FirstWrite 10}
		input_stream_V_data_V {Type I LastRead 8 FirstWrite -1}
		input_stream_V_keep_V {Type I LastRead 8 FirstWrite -1}
		input_stream_V_strb_V {Type I LastRead 8 FirstWrite -1}
		input_stream_V_last_V {Type I LastRead 8 FirstWrite -1}}
	cnn_gesture_core {
		input_0_0 {Type I LastRead 12 FirstWrite -1}
		input_0_1 {Type I LastRead 12 FirstWrite -1}
		input_0_2 {Type I LastRead 12 FirstWrite -1}
		input_0_3 {Type I LastRead 12 FirstWrite -1}
		input_0_4 {Type I LastRead 12 FirstWrite -1}
		input_0_5 {Type I LastRead 12 FirstWrite -1}
		input_1_0 {Type I LastRead 12 FirstWrite -1}
		input_1_1 {Type I LastRead 12 FirstWrite -1}
		input_1_2 {Type I LastRead 12 FirstWrite -1}
		input_1_3 {Type I LastRead 12 FirstWrite -1}
		input_1_4 {Type I LastRead 12 FirstWrite -1}
		input_1_5 {Type I LastRead 12 FirstWrite -1}
		input_2_0 {Type I LastRead 12 FirstWrite -1}
		input_2_1 {Type I LastRead 12 FirstWrite -1}
		input_2_2 {Type I LastRead 12 FirstWrite -1}
		input_2_3 {Type I LastRead 12 FirstWrite -1}
		input_2_4 {Type I LastRead 12 FirstWrite -1}
		input_2_5 {Type I LastRead 12 FirstWrite -1}
		output_r {Type O LastRead -1 FirstWrite 30}
		p_ZL14conv1d_param_0_0 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_1 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_2 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_3 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_4 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_5 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_6 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_7 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_8 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_9 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_10 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_11 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_12 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_13 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_14 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_15 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_16 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_17 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_18 {Type I LastRead -1 FirstWrite -1}
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
	cnn_gesture_core_Pipeline_VITIS_LOOP_62_1_VITIS_LOOP_63_2 {
		input_0_0 {Type I LastRead 12 FirstWrite -1}
		input_1_0 {Type I LastRead 12 FirstWrite -1}
		input_2_0 {Type I LastRead 12 FirstWrite -1}
		input_0_1 {Type I LastRead 12 FirstWrite -1}
		input_1_1 {Type I LastRead 12 FirstWrite -1}
		input_2_1 {Type I LastRead 12 FirstWrite -1}
		input_0_2 {Type I LastRead 12 FirstWrite -1}
		input_1_2 {Type I LastRead 12 FirstWrite -1}
		input_2_2 {Type I LastRead 12 FirstWrite -1}
		input_0_3 {Type I LastRead 12 FirstWrite -1}
		input_1_3 {Type I LastRead 12 FirstWrite -1}
		input_2_3 {Type I LastRead 12 FirstWrite -1}
		input_0_4 {Type I LastRead 12 FirstWrite -1}
		input_1_4 {Type I LastRead 12 FirstWrite -1}
		input_2_4 {Type I LastRead 12 FirstWrite -1}
		input_0_5 {Type I LastRead 12 FirstWrite -1}
		input_1_5 {Type I LastRead 12 FirstWrite -1}
		input_2_5 {Type I LastRead 12 FirstWrite -1}
		conv1_out {Type O LastRead -1 FirstWrite 52}
		p_ZL14conv1d_param_0_0 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_1 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_2 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_3 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_4 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_5 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_6 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_7 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_8 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_9 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_10 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_11 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_12 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_13 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_14 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_15 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_16 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_17 {Type I LastRead -1 FirstWrite -1}
		p_ZL14conv1d_param_0_18 {Type I LastRead -1 FirstWrite -1}
		conv1d_param_1 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_param_0 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_param_1 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_param_2 {Type I LastRead -1 FirstWrite -1}
		batch_normalization_param_3 {Type I LastRead -1 FirstWrite -1}}
	cnn_gesture_core_Pipeline_VITIS_LOOP_100_1_VITIS_LOOP_101_2 {
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
	cnn_gesture_core_Pipeline_VITIS_LOOP_115_1_VITIS_LOOP_116_2_VITIS_LOOP_119_3 {
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
	cnn_gesture_core_Pipeline_VITIS_LOOP_149_1_VITIS_LOOP_150_2 {
		conv2_out {Type I LastRead 1 FirstWrite -1}
		pool2_out {Type O LastRead -1 FirstWrite 1}}
	cnn_gesture_core_Pipeline_VITIS_LOOP_165_1_VITIS_LOOP_166_2 {
		pool2_out {Type I LastRead 0 FirstWrite -1}
		flat {Type O LastRead -1 FirstWrite 1}}
	cnn_gesture_core_Pipeline_VITIS_LOOP_183_2 {
		sext_ln181_2 {Type I LastRead 0 FirstWrite -1}
		empty {Type I LastRead 0 FirstWrite -1}
		flat {Type I LastRead 2 FirstWrite -1}
		sum_9_out {Type O LastRead -1 FirstWrite 5}
		dense_param_0 {Type I LastRead -1 FirstWrite -1}}
	cnn_gesture_core_Pipeline_VITIS_LOOP_201_2 {
		sext_ln199_2 {Type I LastRead 0 FirstWrite -1}
		zext_ln201 {Type I LastRead 0 FirstWrite -1}
		fc1 {Type I LastRead 2 FirstWrite -1}
		sum_11_out {Type O LastRead -1 FirstWrite 5}
		dense_1_param_0 {Type I LastRead -1 FirstWrite -1}}
	cnn_gesture_core_Pipeline_VITIS_LOOP_214_1 {
		max_v {Type I LastRead 0 FirstWrite -1}
		logits {Type I LastRead 0 FirstWrite -1}
		max_v_1_out {Type O LastRead -1 FirstWrite 0}}
	cnn_gesture_core_Pipeline_VITIS_LOOP_220_2 {
		logits {Type I LastRead 0 FirstWrite -1}
		sext_ln221 {Type I LastRead 0 FirstWrite -1}
		max_v_1_reload {Type I LastRead 0 FirstWrite -1}
		exps {Type O LastRead -1 FirstWrite 11}
		sum_7_out {Type O LastRead -1 FirstWrite 10}}
	cnn_gesture_core_Pipeline_VITIS_LOOP_225_3 {
		exps {Type I LastRead 0 FirstWrite -1}
		sext_ln225 {Type I LastRead 0 FirstWrite -1}
		output_r {Type O LastRead -1 FirstWrite 30}}
	cnn_gesture_top_Pipeline_VITIS_LOOP_281_3 {
		output_r {Type I LastRead 0 FirstWrite -1}
		output_stream_V_data_V {Type O LastRead -1 FirstWrite 1}
		output_stream_V_keep_V {Type O LastRead -1 FirstWrite 1}
		output_stream_V_strb_V {Type O LastRead -1 FirstWrite 1}
		output_stream_V_last_V {Type O LastRead -1 FirstWrite 1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "225730", "Max" : "225730"}
	, {"Name" : "Interval", "Min" : "225731", "Max" : "225731"}
]}

set PipelineEnableSignalInfo {[
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
