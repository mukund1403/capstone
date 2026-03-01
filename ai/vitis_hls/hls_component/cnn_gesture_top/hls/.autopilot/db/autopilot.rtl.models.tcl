set SynModuleInfo {
  {SRCNAME tiny_classifier_Pipeline_VITIS_LOOP_74_2_VITIS_LOOP_75_3 MODELNAME tiny_classifier_Pipeline_VITIS_LOOP_74_2_VITIS_LOOP_75_3 RTLNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_74_2_VITIS_LOOP_75_3
    SUBMODULES {
      {MODELNAME cnn_gesture_top_sparsemux_13_3_32_1_1 RTLNAME cnn_gesture_top_sparsemux_13_3_32_1_1 BINDTYPE op TYPE sparsemux IMPL compactencoding_dontcare}
      {MODELNAME cnn_gesture_top_flow_control_loop_pipe_sequential_init RTLNAME cnn_gesture_top_flow_control_loop_pipe_sequential_init BINDTYPE interface TYPE internal_upc_flow_control INSTNAME cnn_gesture_top_flow_control_loop_pipe_sequential_init_U}
    }
  }
  {SRCNAME tiny_classifier_Pipeline_VITIS_LOOP_85_4 MODELNAME tiny_classifier_Pipeline_VITIS_LOOP_85_4 RTLNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_85_4}
  {SRCNAME tiny_classifier_Pipeline_VITIS_LOOP_90_5 MODELNAME tiny_classifier_Pipeline_VITIS_LOOP_90_5 RTLNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5
    SUBMODULES {
      {MODELNAME cnn_gesture_top_fadd_32ns_32ns_32_4_full_dsp_1 RTLNAME cnn_gesture_top_fadd_32ns_32ns_32_4_full_dsp_1 BINDTYPE op TYPE fadd IMPL fulldsp LATENCY 3 ALLOW_PRAGMA 1}
      {MODELNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_B_ROM_AUTO_1R RTLNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_B_ROM_AUTO_1R BINDTYPE storage TYPE rom IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_tiny_classifier_stream_axis_0_float_bkb RTLNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_tiny_classifier_stream_axis_0_float_bkb BINDTYPE storage TYPE rom IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_tiny_classifier_stream_axis_0_float_cud RTLNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_tiny_classifier_stream_axis_0_float_cud BINDTYPE storage TYPE rom IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_tiny_classifier_stream_axis_0_float_dEe RTLNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_tiny_classifier_stream_axis_0_float_dEe BINDTYPE storage TYPE rom IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_tiny_classifier_stream_axis_0_float_eOg RTLNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_tiny_classifier_stream_axis_0_float_eOg BINDTYPE storage TYPE rom IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_tiny_classifier_stream_axis_0_float_fYi RTLNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_tiny_classifier_stream_axis_0_float_fYi BINDTYPE storage TYPE rom IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_tiny_classifier_stream_axis_0_float_g8j RTLNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_90_5_tiny_classifier_stream_axis_0_float_g8j BINDTYPE storage TYPE rom IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
    }
  }
  {SRCNAME tiny_classifier_Pipeline_VITIS_LOOP_33_1 MODELNAME tiny_classifier_Pipeline_VITIS_LOOP_33_1 RTLNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_33_1}
  {SRCNAME tiny_classifier_Pipeline_VITIS_LOOP_39_2 MODELNAME tiny_classifier_Pipeline_VITIS_LOOP_39_2 RTLNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_39_2
    SUBMODULES {
      {MODELNAME cnn_gesture_top_fexp_32ns_32ns_32_8_full_dsp_1 RTLNAME cnn_gesture_top_fexp_32ns_32ns_32_8_full_dsp_1 BINDTYPE op TYPE fexp IMPL fulldsp LATENCY 7 ALLOW_PRAGMA 1}
    }
  }
  {SRCNAME tiny_classifier_Pipeline_VITIS_LOOP_45_3 MODELNAME tiny_classifier_Pipeline_VITIS_LOOP_45_3 RTLNAME cnn_gesture_top_tiny_classifier_Pipeline_VITIS_LOOP_45_3}
  {SRCNAME tiny_classifier MODELNAME tiny_classifier RTLNAME cnn_gesture_top_tiny_classifier
    SUBMODULES {
      {MODELNAME cnn_gesture_top_fdiv_32ns_32ns_32_9_no_dsp_1 RTLNAME cnn_gesture_top_fdiv_32ns_32ns_32_9_no_dsp_1 BINDTYPE op TYPE fdiv IMPL fabric LATENCY 8 ALLOW_PRAGMA 1}
      {MODELNAME cnn_gesture_top_fcmp_32ns_32ns_1_2_no_dsp_1 RTLNAME cnn_gesture_top_fcmp_32ns_32ns_1_2_no_dsp_1 BINDTYPE op TYPE fcmp IMPL auto LATENCY 1 ALLOW_PRAGMA 1}
      {MODELNAME cnn_gesture_top_faddfsub_32ns_32ns_32_4_full_dsp_1 RTLNAME cnn_gesture_top_faddfsub_32ns_32ns_32_4_full_dsp_1 BINDTYPE op TYPE fadd IMPL fulldsp LATENCY 3 ALLOW_PRAGMA 1}
      {MODELNAME cnn_gesture_top_fmul_32ns_32ns_32_3_max_dsp_1 RTLNAME cnn_gesture_top_fmul_32ns_32ns_32_3_max_dsp_1 BINDTYPE op TYPE fmul IMPL maxdsp LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME cnn_gesture_top_tiny_classifier_exps_RAM_AUTO_1R1W RTLNAME cnn_gesture_top_tiny_classifier_exps_RAM_AUTO_1R1W BINDTYPE storage TYPE ram IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
    }
  }
  {SRCNAME cnn_gesture_top MODELNAME cnn_gesture_top RTLNAME cnn_gesture_top IS_TOP 1
    SUBMODULES {
      {MODELNAME cnn_gesture_top_output_probs_RAM_AUTO_1R1W RTLNAME cnn_gesture_top_output_probs_RAM_AUTO_1R1W BINDTYPE storage TYPE ram IMPL auto LATENCY 2 ALLOW_PRAGMA 1}
      {MODELNAME cnn_gesture_top_CTRL_s_axi RTLNAME cnn_gesture_top_CTRL_s_axi BINDTYPE interface TYPE interface_s_axilite}
      {MODELNAME cnn_gesture_top_regslice_both RTLNAME cnn_gesture_top_regslice_both BINDTYPE interface TYPE adapter IMPL reg_slice}
    }
  }
}
