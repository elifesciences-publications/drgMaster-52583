function drgRunBatchLFPpar

%Ask user for the m file that contains information on what the user wants the analysis to be
%This file has all the information on what the user wants done, which files
%to process, what groups they fall into, etc
%
% An example of this file: drgbChoicesDanielPrelim
%
%

tic

[choiceFileName,choiceBatchPathName] = uigetfile({'drgbChoices*.m'},'Select the .m file with all the choices for analysis');
fprintf(1, ['\ndrgRunBatchLFP run for ' choiceFileName '\n\n']);

addpath(choiceBatchPathName)
eval(['handles=' choiceFileName(1:end-2) ';'])
handles.choiceFileName=choiceFileName;
handles.choiceBatchPathName=choiceBatchPathName;

new_no_files=handles.drgbchoices.no_files;
choicePathName=handles.drgbchoices.PathName;
choiceFileName=handles.drgbchoices.FileName;



%Very, very important!
handles.evTypeNo=handles.drgbchoices.referenceEvent;

%If you want to skip files that have already been processed enter the number of the first file
% first_file=handles.drgb.first_file;

%NOTE: For the moment because of parallel processing I am defaulting to
%start with file 1
first_file=1;

if first_file==1
    handles.drgb.lfpevpair_no=0;
    handles.drgb.lfp_per_exp_no=0;
    first_out=1;
else
    load([handles.drgb.outPathName handles.drgb.outFileName])
    handles.drgb=handles_drgb.drgb;
    %The user may add new files
    handles.drgbchoices.no_files=new_no_files;
    handles.drgbchoices.PathName=choicePathName;
    handles.drgbchoices.FileName=choiceFileName;
    first_out=0;
end

test_batch=handles.drgbchoices.test_batch;



%Parallel batch processing for each file
lfp_per_file=[];
all_files_present=1;
for filNum=first_file:handles.drgbchoices.no_files
    lfp_per_file(filNum).lfp_per_exp_no=0;
    lfp_per_file(filNum).lfpevpair_no=0;
    lfp_per_file(filNum).lfp_per_exp=[];
    lfp_per_file(filNum).lfpevpair=[];
    lfp_per_file(filNum).f=[];
    lfp_per_file(filNum).out_times=[];
    
    %Make sure that all the files exist
    jtFileName=handles.drgbchoices.FileName{filNum};
    jtPathName=handles.drgbchoices.PathName{filNum};
    if exist([jtPathName jtFileName])==0
        fprintf(1, ['Program will be terminated because file No %d, ' jtPathName jtFileName ' does not exist\n'],filNum);
        all_files_present=0;
    end
    
    if (exist( [jtPathName jtFileName(10:end-4) '.dg'])==0)&(exist( [jtPathName jtFileName(10:end-4) '.rhd'])==0)
        fprintf(1, ['Program will be terminated because neither dg or rhd files for file No %d, ' [jtPathName jtFileName(10:end-4)] ' does not exist\n'],filNum);
        all_files_present=0;
    end
    
end

if all_files_present==1
    
    gcp;
    no_files=handles.drgbchoices.no_files;
    parfor filNum=first_file:no_files
        
        %         for filNum=first_file:handles.drgbchoices.no_files
        
        file_no=filNum
        handlespf=struct();
        handlespf=handles;
        
        %read the jt_times file
        jtFileName=handles.drgbchoices.FileName{filNum};
        jtPathName=handles.drgbchoices.PathName{filNum};
        
        drgRead_jt_times(jtPathName,jtFileName);
        FileName=[jtFileName(10:end-4) '_drg.mat'];
        fullName=[jtPathName,FileName];
        my_drg={'drg'};
        S=load(fullName,my_drg{:});
        handlespf.drg=S.drg;
        
        if handles.read_entire_file==1
            handlespf=drgReadAllDraOrDg(handlespf);
        end
        
        switch handlespf.drg.session(handlespf.sessionNo).draq_p.dgordra
            case 1
            case 2
                handlespf.drg.drta_p.fullName=[jtPathName jtFileName(10:end-4) '.dg'];
            case 3
                handlespf.drg.drta_p.fullName=[jtPathName jtFileName(10:end-4) '.rhd'];
        end
        
        %Set the last trial to the last trial in the session
        handlespf.lastTrialNo=handlespf.drg.session(handlespf.sessionNo).events(2).noTimes;
        
        %Run the analysis for each window
        for winNo=1:handles.drgbchoices.noWindows
            
            
            lfp_per_file(filNum).lfp_per_exp_no=lfp_per_file(filNum).lfp_per_exp_no+1;
            
            lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).fileNo=filNum;
            lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).referenceEvent=handles.drgbchoices.referenceEvent;
            lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).timeWindow=winNo;
            lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).timeStart=handles.drgbchoices.timeStart(winNo);
            lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).timeEnd=handles.drgbchoices.timeEnd(winNo);
            
            
            if sum(handles.drgbchoices.analyses==2)>0
                lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).allPower=[];
                lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).all_Power_ref=[];
                lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).which_eventLFPPower=[];
                lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).perCorrLFPPower=[];
            end
            
            if sum(handles.drgbchoices.analyses==1)>0
                for ii=1:handles.no_PACpeaks
                    lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).no_trials=0;
                    lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).meanVectorLength=[];
                    lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).meanVectorAngle=[];
                    lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).peakAngle=[];
                    lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).mod_indx=[];
                    lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).all_phase_histo=[];
                    lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).perCorrPAC=[];
                    lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).which_eventPAC=[];
                end
            end
            
            %Now run the analysis for each lfp
            for lfpNo=1:handles.drgbchoices.no_LFP_elect
                
                
                handlespf.peakLFPNo=lfpNo;
                handlespf.burstLFPNo=lfpNo;
                handlespf.referenceEvent=handles.drgbchoices.referenceEvent;
                
                %Run the analysis for each time window
                
                %First prepare the spectrogram
                %Get LFP power per trial
                if sum(handles.drgbchoices.analyses==2)>0
                    
                    %Subtracting and adding handles.window/2 gives the correct
                    %times
                    handlespf.time_start=min(handles.drgbchoices.timeStart-handles.time_pad-handles.window/2);
                    handlespf.time_end=max(handles.drgbchoices.timeEnd+handles.time_pad+handles.window/2); %2.2 for Shane
                    
                    handlespf.burstLowF=handlespf.LFPPowerSpectrumLowF;
                    handlespf.burstHighF=handlespf.LFPPowerSpectrumHighF;
                    handlespf.lastTrialNo=handlespf.drg.session(handlespf.sessionNo).events(handlespf.referenceEvent).noTimes;
                    handlespf.trialNo=1;
                    all_Power=[];
                    all_Power_timecourse=[];
                    all_Power_ref=[];
                    perCorr=[];
                    which_event=[];
                    
                    %Please note this is the same function called in drgMaster
                    %when you choose LFP Power Timecourse Trial Range, which calls drgLFPspectTimecourse
                    [t,f,all_Power,all_Power_ref, all_Power_timecourse, this_trialNo, perCorr,which_event]=drgGetLFPPowerForThisEvTypeNo(handlespf);
                    
                    
                    lfp_per_file(filNum).f=f;
                    
                end
                
                fprintf(1, 'File number: %d, window number: %d, lfp number: %d\n',filNum,winNo,lfpNo);
                
                handlespf.time_start=handles.drgbchoices.timeStart(winNo)-handles.time_pad;
                handlespf.time_end=handles.drgbchoices.timeEnd(winNo)+handles.time_pad; %2.2 for Shane
                
                
                lfp_per_file(filNum).lfpevpair_no=lfp_per_file(filNum).lfpevpair_no+1;
                lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).fileNo=filNum;
                lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).elecNo=lfpNo;
                lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).referenceEvent=handles.drgbchoices.referenceEvent;
                lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).timeWindow=winNo;
                lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).timeStart=handles.drgbchoices.timeStart(winNo);
                lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).timeEnd=handles.drgbchoices.timeEnd(winNo);
                
                
                
                %Get PAC, percent correct and percent lick per trial
                if sum(handles.drgbchoices.analyses==1)>0
                    for ii=1:handles.no_PACpeaks
                        handlespf.n_peak=ii;
                        handlespf.peakLowF=handles.PACpeakLowF;
                        handlespf.peakHighF=handles.PACpeakHighF;
                        handlespf.burstLowF=handles.PACburstLowF(ii);
                        handlespf.burstHighF=handles.PACburstHighF(ii);
                        
                        
                        %Please note this is the same function called by
                        %drgMaster when the user chooses Phase Amplitude
                        %Coupling
                        handlespf=drgThetaAmpPhaseTrialRange(handlespf);
                        
                        
                        %Enter the per LFP values
                        lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).PAC(ii).no_trials=handlespf.drgb.PAC.no_trials;
                        lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).PAC(ii).meanVectorLength=handlespf.drgb.PAC.meanVectorLength;
                        lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).PAC(ii).meanVectorAngle=handlespf.drgb.PAC.meanVectorAngle;
                        lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).PAC(ii).peakAngle=handlespf.drgb.PAC.peakAngle;
                        lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).PAC(ii).mod_indx=handlespf.drgb.PAC.mod_indx;
                        lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).PAC(ii).all_phase_histo=handlespf.drgb.PAC.all_phase_histo;
                        lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).PAC(ii).perCorrPAC=handlespf.drgb.PAC.perCorr;
                        lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).PAC(ii).which_eventPAC=handlespf.drgb.PAC.which_event;
                        
                        
                        %Enter the per experiment values
                        lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).no_trials=lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).no_trials+handlespf.drgb.PAC.no_trials;
                        lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).meanVectorLength=[lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).meanVectorLength handlespf.drgb.PAC.meanVectorLength];
                        lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).meanVectorAngle=[lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).meanVectorAngle handlespf.drgb.PAC.meanVectorAngle];
                        lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).peakAngle=[lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).peakAngle handlespf.drgb.PAC.peakAngle];
                        lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).mod_indx=[lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).mod_indx handlespf.drgb.PAC.mod_indx];
                        lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).all_phase_histo=[lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).all_phase_histo handlespf.drgb.PAC.all_phase_histo'];
                        lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).perCorrPAC=[lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).perCorrPAC handlespf.drgb.PAC.perCorr];
                        lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).which_eventPAC=[lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).PAC(ii).which_eventPAC handlespf.drgb.PAC.which_event];
                        
                    end
                end
                
                %Get LFP power per trial
                if sum(handles.drgbchoices.analyses==2)>0
                    sz_all_power=size(all_Power);
                    this_all_power=zeros(sz_all_power(1),sz_all_power(2));
                    this_all_power(:,:)=mean(all_Power_timecourse(:,:,(t>=handles.drgbchoices.timeStart(winNo))&(t<=handles.drgbchoices.timeEnd(winNo))),3);
                    
                    %Enter the per LFP values
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).allPower=this_all_power;
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).which_eventLFPPower=which_event;
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).perCorrLFPPower=perCorr;
                    
                    %Enter the per experiment values
                    lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).allPower=[lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).allPower this_all_power'];
                    lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).which_eventLFPPower=[lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).which_eventLFPPower which_event];
                    lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).perCorrLFPPower=[lfp_per_file(filNum).lfp_per_exp(lfp_per_file(filNum).lfp_per_exp_no).perCorrLFPPower perCorr];
                    
                    
                end
                
                %Do the event-related LFP analysis
                if sum(handles.drgbchoices.analyses==3)>0
                    %This was written to answer a reviewer's question on
                    %lick-related theta LFP. Because of this I am defaulting
                    %the bandwidth of the phase to theta
                    handlespf.peakLowF=6;
                    handlespf.peakHighF=12;
                    handlespf.burstLowF=6;
                    handlespf.burstHighF=12;
                    
                    handlespf.peakLFPNo=19; %These are licks
                    [log_P_t,no_trials_w_event,which_event,f,out_times,times,phase_per_trial,no_trials,no_events_per_trial,t_per_event_per_trial,trial_map,perCorr,no_ref_evs_per_trial]=drgEventRelatedAnalysis(handlespf);
                    
                    lfp_per_file(filNum).out_times=out_times;
                    
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).no_trials_w_eventERP=no_trials_w_event;
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).which_eventERP=which_event;
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).fERP=f;
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).log_P_tERP=log_P_t;
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).phase_per_trialERP=phase_per_trial;
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).no_trials=no_trials;
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).no_events_per_trial=no_events_per_trial;
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).t_per_event_per_trial=t_per_event_per_trial;
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).trial_map=trial_map;
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).perCorr=perCorr;
                    lfp_per_file(filNum).lfpevpair(lfp_per_file(filNum).lfpevpair_no).no_ref_evs_per_trial=no_ref_evs_per_trial;
                    
                    
                end
            end
            
        end
        
        
        
    end
    
    
    %Now enter the results in the output structures
    %Initialize lfpevpair
    
    handles.drgb.lfpevpair=[];
    handles.drgb.lfpevpair_no=0;
    
    if (sum(handles.drgbchoices.analyses==3)>0)
        handles.drgb.lfpevpair.out_times=lfp_per_file(1).out_times;
    end
    
    for filNum=first_file:handles.drgbchoices.no_files
        
        
        jtFileName=handles.drgbchoices.FileName{filNum};
        jtPathName=handles.drgbchoices.PathName{filNum};
        
        %Save information for this file
        handles.drgb.filNum=filNum;
        handles.drgb.file(filNum).FileName=[jtFileName(10:end-4) '_drg.mat'];
        handles.drgb.file(filNum).PathName=jtPathName;
        
        %Save LFP power structures
        if (sum(handles.drgbchoices.analyses==2)>0)||(sum(handles.drgbchoices.analyses==1)>0)
            handles.drgb.freq_for_LFPpower=lfp_per_file(filNum).f;
        end
        
        for ii=1:lfp_per_file(filNum).lfpevpair_no
            handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).fileNo=...
                lfp_per_file(filNum).lfpevpair(ii).fileNo;
            handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).elecNo=...
                lfp_per_file(filNum).lfpevpair(ii).elecNo;
            handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).referenceEvent=...
                lfp_per_file(filNum).lfpevpair(ii).referenceEvent;
            handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).timeWindow=...
                lfp_per_file(filNum).lfpevpair(ii).timeWindow;
            handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).timeStart=...
                lfp_per_file(filNum).lfpevpair(ii).timeStart;
            handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).timeEnd=...
                lfp_per_file(filNum).lfpevpair(ii).timeEnd;
            
            %LFP power
            if (sum(handles.drgbchoices.analyses==2)>0)
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).allPower=...
                    lfp_per_file(filNum).lfpevpair(ii).allPower;
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).which_eventLFPPower=...
                    lfp_per_file(filNum).lfpevpair(ii).which_eventLFPPower;
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).perCorrLFPPower=...
                    lfp_per_file(filNum).lfpevpair(ii).perCorrLFPPower;
            end
            
            %LFP PAC
            if (sum(handles.drgbchoices.analyses==1)>0)
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).PAC=...
                    lfp_per_file(filNum).lfpevpair(ii).PAC;
            end
            
            %LFP ERP
            if (sum(handles.drgbchoices.analyses==3)>0)
                
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).no_trials_w_eventERP=...
                    lfp_per_file(filNum).lfpevpair(ii).no_trials_w_eventERP;
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).which_eventERP=...
                    lfp_per_file(filNum).lfpevpair(ii).which_eventERP;
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).fERP=...
                    lfp_per_file(filNum).lfpevpair(ii).fERP;
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).log_P_tERP=...
                    lfp_per_file(filNum).lfpevpair(ii).log_P_tERP;
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).phase_per_trialERP=...
                    lfp_per_file(filNum).lfpevpair(ii).phase_per_trialERP;
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).no_trials=...
                    lfp_per_file(filNum).lfpevpair(ii).no_trials;
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).no_events_per_trial=...
                    lfp_per_file(filNum).lfpevpair(ii).no_events_per_trial;
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).t_per_event_per_trial=...
                    lfp_per_file(filNum).lfpevpair(ii).t_per_event_per_trial;
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).trial_map=...
                    lfp_per_file(filNum).lfpevpair(ii).trial_map;
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).perCorr=...
                    lfp_per_file(filNum).lfpevpair(ii).perCorr;
                handles.drgb.lfpevpair(handles.drgb.lfpevpair_no+ii).no_ref_evs_per_trial=...
                    lfp_per_file(filNum).lfpevpair(ii).no_ref_evs_per_trial;
            end
            
            
        end
        
        handles.drgb.lfpevpair_no=lfp_per_file(filNum).lfpevpair_no+handles.drgb.lfpevpair_no;
        
    end
    
    
    %Save output file
    handles_drgb=handles;
    if isfield(handles,'data_dg')
        handles_drgb=rmfield(handles_drgb,'data_dg');
    end
    save([handles.drgb.outPathName handles.drgb.outFileName],'handles_drgb','-v7.3')
    
    fprintf(1, 'Total processing time %d hours\n',toc/(60*60));
    
end





