set ModuleHierarchy {[{
"Name" : "cnn_gesture_top", "RefName" : "cnn_gesture_top","ID" : "0","Type" : "sequential",
"SubInsts" : [
	{"Name" : "grp_tiny_classifier_fu_126", "RefName" : "tiny_classifier","ID" : "1","Type" : "sequential",
		"SubInsts" : [
		{"Name" : "grp_tiny_classifier_Pipeline_VITIS_LOOP_74_2_VITIS_LOOP_75_3_fu_149", "RefName" : "tiny_classifier_Pipeline_VITIS_LOOP_74_2_VITIS_LOOP_75_3","ID" : "2","Type" : "sequential",
			"SubLoops" : [
			{"Name" : "VITIS_LOOP_74_2_VITIS_LOOP_75_3","RefName" : "VITIS_LOOP_74_2_VITIS_LOOP_75_3","ID" : "3","Type" : "pipeline"},]},
		{"Name" : "grp_tiny_classifier_Pipeline_VITIS_LOOP_85_4_fu_167", "RefName" : "tiny_classifier_Pipeline_VITIS_LOOP_85_4","ID" : "4","Type" : "sequential",
			"SubLoops" : [
			{"Name" : "VITIS_LOOP_85_4","RefName" : "VITIS_LOOP_85_4","ID" : "5","Type" : "pipeline"},]},
		{"Name" : "grp_tiny_classifier_Pipeline_VITIS_LOOP_90_5_fu_183", "RefName" : "tiny_classifier_Pipeline_VITIS_LOOP_90_5","ID" : "6","Type" : "sequential",
			"SubLoops" : [
			{"Name" : "VITIS_LOOP_90_5","RefName" : "VITIS_LOOP_90_5","ID" : "7","Type" : "pipeline"},]},
		{"Name" : "grp_tiny_classifier_Pipeline_VITIS_LOOP_33_1_fu_208", "RefName" : "tiny_classifier_Pipeline_VITIS_LOOP_33_1","ID" : "8","Type" : "sequential",
			"SubLoops" : [
			{"Name" : "VITIS_LOOP_33_1","RefName" : "VITIS_LOOP_33_1","ID" : "9","Type" : "pipeline"},]},
		{"Name" : "grp_tiny_classifier_Pipeline_VITIS_LOOP_39_2_fu_215", "RefName" : "tiny_classifier_Pipeline_VITIS_LOOP_39_2","ID" : "10","Type" : "sequential",
			"SubLoops" : [
			{"Name" : "VITIS_LOOP_39_2","RefName" : "VITIS_LOOP_39_2","ID" : "11","Type" : "pipeline"},]},
		{"Name" : "grp_tiny_classifier_Pipeline_VITIS_LOOP_45_3_fu_223", "RefName" : "tiny_classifier_Pipeline_VITIS_LOOP_45_3","ID" : "12","Type" : "sequential",
			"SubLoops" : [
			{"Name" : "VITIS_LOOP_45_3","RefName" : "VITIS_LOOP_45_3","ID" : "13","Type" : "pipeline"},]},]},],
"SubLoops" : [
	{"Name" : "VITIS_LOOP_112_1","RefName" : "VITIS_LOOP_112_1","ID" : "14","Type" : "pipeline"},]
}]}