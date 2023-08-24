clear all;
close all;
clc;
rng('default'); %per togliere la casualità dalla ICA
[ALLEEG, EEG, CURRENTSET, ALLCOM]= eeglab;
EEG= pop_loadset('testeeglaboratorio.set');
% i singoli canali eeg sono contenuti in EEG.data 
eeglab redraw
eegplot(EEG.data, 'srate', 128, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 15, 'color', {'k'},'spacing',50);
eeglab redraw

%% BASELINE REMOVAL
% the average voltage values of each electrode are calculated within a time 
% interval and then this average is substracted from that time interval of the signal.
% Calcolo la media del voltaggio dell'eeg in un determinato intervallo e
% poi sottraggo quella media a quell'intervallo. 
media=zeros(19,1);
media(:)=mean(EEG.data(:,:),2);
EEG.data(:,:)=EEG.data(:,:)-media(:);
[ALLEEG, EEG, CURRENTSET]= pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EEG_FIL_BAS'); %2C
eeglab redraw;
eegplot(EEG.data, 'srate', 128, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 15, 'color', {'k'},'spacing',50,'title','EEG_BAS');

%% HIGH PASS FILTER E LOW PASS FILTER

EEG=pop_eegfilt(EEG,1,0); %(se la hicutoff=0)-> filtro PASSA ALTO
EEG.data = filterForwardBackward(EEG.data); %FILTRO passa basso FORWARD-BACKWARD

[ALLEEG, EEG, CURRENTSET]= pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EEG_FIL'); %3C
eeglab redraw;
eegplot(EEG.data, 'srate', 128, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 15, 'color', {'k'},'spacing',50, 'title', 'Filtrato');

%% RE-REFERENCING DEL DATO USANDO LA REFERENZA MEDIA
% new electrical potential at channel x
% Difference of potential respect to a mean value
% Tecnica dell'average reference 
% fa una media di tutti i potenziali e confronta un potenziale con questa media.
% media_potenziali=mean(EEG.data(:,:),'all'); media di tutti i potenziali di tutti i canali

EEG=pop_reref(EEG,[]);
[ALLEEG, EEG, CURRENTSET]= pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EEG_FIL_REREF'); %4C
eeglab redraw;
eegplot(EEG.data, 'srate', 128, 'eloc_file', EEG.chanlocs, 'events', EEG.event, 'winlength', 15, 'color', {'k'},'spacing',50, 'title','differenza media');

%% INTERPOLAZIONE CANALI
% non necessaria, è una tecnica che serve per rimuovere canali difettosi
% sostituendoli con una media dei canali adiacenti
% EEG=pop_interp(EEG,[4]); 

%% ICA 
% Scompone il segnale nelle sue componenti indipendenti per poterlo
% analizzare e rimuovere le componenti rumorose.
[EEG, com]=pop_runica(EEG,'icatype','fastica');
[ALLEEG, EEG, CURRENTSET]= pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EEG_FIL_REREF_INTER_ICA'); %5C
eeglab redraw;

% pop_eegplot (icacomp - type of rejection 0 = independent components)
pop_eegplot( EEG, 0, 0, 0); %visualizza le componenti indipendenti
eegplot(EEG.data,'srate',128,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',15,'color',{'k'}, 'title', 'ICACOMP');

% Plot the components maps in 2-D 
pop_topoplot(EEG, 0, 1:size(EEG.icawinv,2) ,'EEG_FIL_REREF_INTER_ICA',[4 5] ,0,'electrodes','on');

%% ICA denoising
% Visually identify components reflecting eyeblinks, movements, heartbeat,
% and other noises and then remove them using the function pop_subcomp
EEG = pop_subcomp(EEG, [2 9 5 17] , 0);  
% Visualize the ICs after removal
pop_eegplot(EEG, 0, 0, 0); 
% Update the EEGLAB window to view changes
eeglab redraw % CURRENTSET still = 5
% Plot the EEG after bad ICs removal
eegplot(EEG.data,'srate',128,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',15,'color',{'k'},'spacing',50,'title','ultimo'); 
%RICORDA DI SOVRASCRIVERE IL NUOVO DATASET

%% ESTRAZIONE EPOCHE 
% Divisione del tracciato in periodi legati allo svolgimento del task, si
% prendono 2s dopo l'esecuzione dello stesso, apertura e chiusura degli
% occhi.
EEG=pop_epoch(EEG, {'4' '2'}, [0 2], 'newname', 'EEG_epoch','epochinfo', 'yes');
[ALLEEG, EEG, CURRENTSET]= pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EEG_FIL_REREF_INTER_ICA_EPOCH'); %6C
eeglab redraw
eegplot(EEG.data,'srate',128,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',12,'color',{'k'},'spacing',80,'title','EPOCHE'); 

%% ESTRAZIONE EPOCA 2 
% dataset 7
% Evento di chiusura degli occhi
EEG=pop_selectevent(EEG,'type',2, 'deleteevents','on', 'deleteepochs','on');
[ALLEEG, EEG, CURRENTSET]= pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EEG_FIL_REREF_INTER_ICA_EPOCH_2'); %7C
eeglab redraw
eegplot(EEG.data,'srate',128,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',6,'color',{'k'},'spacing',80,'title','EPOCA 2'); 

%% ESTRAZIONE EPOCA 4
% dataset 8
% Evento di apertura degli occhi
EEG=pop_selectevent(ALLEEG(6),'type',4,'deleteevents','on', 'deleteepochs','on');
[ALLEEG, EEG, CURRENTSET]= pop_newset(ALLEEG, EEG, CURRENTSET, 'setname', 'EEG_FIL_REREF_INTER_ICA_EPOCH_4'); %8C
eeglab redraw
eegplot(EEG.data,'srate',128,'eloc_file',EEG.chanlocs,'events',EEG.event,'winlength',6,'color',{'k'},'spacing',80,'title','EPOCA 4'); 

%% POTENZA SPETTRALE EPOCA 2
% Si mostra la potenza spettrale del tracciato diviso in epoche, qui si
% prende in considerazione l'epoca 2, legata all'evento di chiusura occhi,
% si evidenziano i picchi in frequenza e si mostrano le mappe topografiche.
figure;
pop_spectopo(ALLEEG(7), 1,[0 1996], 'EEG','percent',100, 'freq', [5 11 22], 'freqrange',[2 25], 'electrodes','on','maplimits',[-8 8]);
title('occhi chiusi 2');

%% POTENZA SPETTRALE EPOCA 4
% Si mostra la potenza spettrale del tracciato diviso in epoche, qui si
% prende in considerazione l'epoca 4, legata all'evento di apertura occhi
figure;
pop_spectopo(ALLEEG(8), 1,[0 1996], 'EEG','percent',100, 'freq', [7 11 15 19 ], 'freqrange',[2 25], 'electrodes','on','maplimits',[-8 8]);
title('occhi aperti 4');




