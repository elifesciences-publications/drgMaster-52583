# drgMaster
drgMaster

The code in GitHub/drgMaster was used to analyze the data in:

Learning improves decoding of odor identity with phase-referenced oscillations in the olfactory bulb 
Justin Losacco, Daniel Ramirez-Gordillo, Jesse Gilmer and Diego Restrepo
published in eLife in 2020 (https://doi.org/10.7554/eLife.52983).

The data have been deposited in the GigaScience Database, http://doi.org/10.5524/100699

You should install the following MATLAB toolboxes:

Wavelet
Statistics and Machine Learning
Bioinformatics toolbox (for the “suptitle” command)

In addition, you will need the following downloads:

Circular Statistics Toolbox (https://www.mathworks.com/matlabcentral/fileexchange/10676-circular-statistics-toolbox-directional-statistics)

ROC_calc (https://www.mathworks.com/matlabcentral/fileexchange/69883-roc_calc)

boundedline.m (https://www.mathworks.com/matlabcentral/fileexchange/27485-boundedline-m)

Below is a brief explanation of how the data for each of the figures in the Losacco, Ramirez-Gordillo et al. manuscript were analyzed using MATLAB code deposited here. 

The LFP data are found in Giga DB (http://gigadb.org/). The files included are raw data of LFP recordings for each go-no go session stored in two formats: 1) name.rhd files generated by INTAN RHD2000 or 2) name.dg files generated by Data Translation DT3010. Each of these files is accompanied by a header file jt_times_name .mat file information on events (odorant, date, trial time, trial numbers, event: S+ or S-, Hit, Miss, CR, FA, etc). We also deposited intermediary .mat data files. 

Figure 1-figure supplement 1 is generated with drgPID.m using 20180618_sharpie_spmc_PID_180618_160444.rhd

Figure 1-figure supplement 2 is generated by drgMaster by choosing either “PAC peak at 180, S+ High MI, S- lo…” or “8Hz, 40Hz, 20 dB” for the drop down menu entitled “Process data or simulation”.

Figure 2A,C-F is an example of phase amplitude coupling (PAC) calculated with drgMaster, a GUI to perform basic analysis of LFP data for each session. This file was generated opening jt_times_ M5_spm_iso_ace_170810_085523.mat in drgMaster and processing “Phase Amplitude Coupling” (a choice the third dropdown menu on the right in drgMaster) with the following choices in the GUI: Trial No: 1 to 99, phase reference frequency: 6-14 Hz (theta), amplitude frequency: 65-95 Hz (high gamma), start/end times: 0.5-2.5 sec, LFP channel (electrode number): 2, S+ or S-, all other choices default. 

Figure 2B is the behavioral performance for the same session. This file was generated opening jt_times_ M5_spm_iso_ace_170810_085523.mat in drgMaster and processing “Percent correct per tirial” (a choice the first dropdown menu on the right in drgMaster) with the following choices in the GUI: Trial No: 1 to 99, all other choices default. 

Figures 2G-H. First we batch-analyzed PAC parameters for all the files in Exp1 and Exp2 in separate runs of drgRunBatchLFPPar.m using the following choices/output files:

Exp1: 	drgbChoicesDanielOlfacEAPADRmod04202019.m
	Olfactorypaper04202019.mat

Exp2: 	drgbChoicesJustin_LFP_spm_PACpower04172019
	spm_LFP_PACpower04172019.mat

To generate Figure 2G we ran drgAnalysisBatchLFP with choices under drgLFPBatchAnalPars_spm_daniel_fig2g.m using the files for APEB forward.

Figure 2H is generated by drgSummaryBatchPAC.m

Figure 2-figure supplement 1 is an example of PAC generated using jt_times_T0_spm_iso_ace_180130_111647.mat with drgMaster as described above for Figure 2A, C-F.

Figure 2-figure supplement 2 is generated by drgSummaryBatchPAC.m

Figure 3A is an example of a wavelet broadband LFP spectrogram calculated with drgMaster. This file was generated opening jt_times_M5_spm_iso_ace_170810_085523.mat in drgMaster and processing “LFP phase-referenced wavelet power” (a choice the third dropdown menu on the right in drgMaster) with the following choices in the GUI: Trial No: 79 to 79, amplitude frequency: 4-100 Hz, start/end times: -2 to 5 sec, subtract reference on, Start/End reference (s):LFP channel (electrode number): 1, S+, all other choices default. 

Figure 3Ci is an example of phase-referenced power (PRP) obtained with the same settings in drgMaster with the exception that the Amplitude frequency was 65-95 Hz and PAC reference peak/trough angles were 108 and 0. Figure 3Cii is processed with the same settings except that we include all trials (1 to 97).

Figures 3D-F. First we batch-analyzed PAC parameters for all the files in Exp1 and Exp2 in separate runs of drgRunBatchLFPPar.m using the following choices/output files:

Exp1: 	drgbChoicesDanielOlfacEAPADRmod04202019.m
	Olfactorypaper04202019.mat

Exp2: 	drgbChoicesJustin_LFP_spm_wavephasepower04202019.m
	spm_LFP_wavephasepower04202019.mat

To generate Figure 3D we ran drgAnalysisBatchLFP with choices under drgLFPBatchAnalPars_Justin_spmwave_dr.musing the files for IAAP forward.

To generate Figures 3E-F we ran d drgSummaryBatchWavPwr.m that loads files with intermediary data generated by drgAnalysisBatchLFP.

Figure 4A is the behavioral performance for three sessions: Forward 4i and Reversed (4ii and 4iii). 

The figures can be generated by drgMaster and processing “Percent correct per tirial” (a choice the first dropdown menu on the right in drgMaster) using the following files:

Figure 4Ai: jt_times_T0_spm_iso_ace_180130_111647.mat
Figure 4Aii: jt_times_T0_spmr_ace_iso_180131_103513.mat
Figure 4Aiii: jt_times_T0_spmr_ace_iso_180201_104706.mat

Figures 4B and C are generated by drgSummaryBatchWavPwrRev.m using data generated by drgAnalysisBatchLFP.m

Figure 5. A batch analysis of LDA and PCA was performed by drgLFPDiscriminantBatch.m using the following choices files:

Exp1:
drgbChoicesDiscriminantDanielolfa_spmcall_PCA_LFP_iso42919.m
drgbChoicesDiscriminantDanielolfa_spmcall_PCA_LFP_EAPA42919.m
drgbChoicesDiscriminantDanielolfa_spmcall_PCA_LFP_Aceto42919.m

Exp2:
drgbChoicesDiscriminantJustin_spm_wavephase_04252019_IsoAA_mo.m
drgbChoicesDiscriminantJustin_spm_wavephase_05172019_IAAP.m
drgbChoicesDiscriminantJustin_spm_wavephase_04252019_EAPA.m

Output files for drgLFPDiscriminantBatch.m:

Exp1:
Discriminant_spmc_discriminantolfac_all_PCA_LFP_iso42919.mat
Discriminant_spmc_discriminantolfac_all_PCA_LFP_EAPA42919.mat
Discriminant_spmc_discriminantolfac_all_PCA_LFP_aceto42919.mat

Exp2:
Discriminant_spm_discriminant_LFP_wavephase_04252019_IsoAA_mo.mat
Discriminant_spm_discriminant_LFP_wavephase_05172019_IAAP.mat
Discriminant_spm_discriminant_LFP_wavephase_04252019_EAPA.mat

Figures 5A and B are generated from this output using drgAnalyzeLFPDiscriminantBatch.m using
Discriminant_spmc_discriminantolfac_all_PCA_LFP_aceto42919.mat

Figures 5C and D are generated from these output files using drgAnalyzeLFPDiscriminantMultiBatch.m and load drgbDiscParJustinDanielLDApeaktrough.m 

Figure 5E was generated by drgAnalyzeLFPDiscriminantMultiBatch with choices in drgbDiscParJustinDanielLDApeaktrough.m


Figure 6. Decision times.

drgLFPDiscriminantBatchAllMice was run using the following choices files:

Exp1:
drgbChoicesDiscriminantDanielolfa_spm_all_mice_iso06082019.m
drgbChoicesDiscriminantDanielolfa_spm_all_mice_EAPA06062019.m
drgbChoicesDiscriminantDanielolfa_sp_all_mice_Aceto42919.m

Exp2:
drgbChoicesDiscriminantJustin_spm_all_mouse_06102019_IsoAA_mo
.m
drgbChoicesDiscriminantJL_spm_wavep_allm_05312019_IAAP.m
drgbChoicesDiscriminantJL_spm_wavep_allm_06062019_EAPA.m

Output files for drgLFPDiscriminantBatchAllMice:

Exp1:
Discriminant_spm_discriminantolfac_all_mice_iso06082019.mat
Discriminant_spmc_discriminantolfac_all_mice_EAPA06062019.mat
Discriminant_spm_discriminantolfac_all_mice_aceto060519.mat

Exp2:
Discriminant_spm_discriminant_LFP_all_mouse_06102019_IsoAA_mo.mat
Discriminant_spm_discriminant_LFP_wp_all_mouse_05312019_IAAP.mat
Discriminant_spm_discriminantJL_spm_wavep_allm_06062019_EAPA.mat

These output files were then processed by drgLFPDiscriminantAllMiceSubset.m to generate the final output files:

Exp1:
Discriminant_2spm_discriminantolfac_all_mice_aceto060519.mat
Discriminant_2spmc_discriminantolfac_all_mice_EAPA06062019.mat
Discriminant_2spm_discriminantolfac_all_mice_iso06082019.mat

Exp2:
Discriminant_2spm_discriminantJL_spm_wavep_allm_06062019_EAPA.mat
Discriminant_2spm_discriminant_LFP_wp_all_mouse_05312019_IAAP.mat
Discriminant_2spm_discriminant_LFP_all_mouse_06102019_IsoAA_mo.mat

At that point  drgAnalyzeLFPDiscriminantAllMice does the final analysis of the data generated by drgLFPDiscriminantBatchAllMice/ drgLFPDiscriminantAllMiceSubset 

all_mouse_decision_time_summary.m generates the final summary figure

Figure 6-figure supplement 1 is also generated by all_mouse_decision_time_summary.m

Figure 7A is a PCA generated as described above for Figure 5A by running drgAnalyzeDimsLFPDiscriminantAllMice.m with Discriminant_2 inputs.

Figures 7B and C are generated from Discriminant_2 inputs using new_all_mouse_dim_summary.m


Figure 7-figure supplement 1A is generated by per_mouse_dim_summary.m

Figure 7-figure supplement 1B is generated by new_per_mouse_dim_summary.m
