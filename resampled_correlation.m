%resampled_correlation.m
%
%this is a resampling programme
%it does a resampling test of a correlation coefficient (but we aren't
%telling you which one!)
%written by AP 
%v1.01 29.1.2017

%the first few lines of code are general for all Matlab programmes
%first we need to set the random number seed so that we get the same
%randomisation sequence each time we run the programme
%here we set it so that the sequence is the one you get if you first
%started up Matlab
rng('default'); %rng = Random Number Generator

clc; %this clears the command window at the start of the programme
clear variables; %this clears any variables from memory

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The data are from 20 participants for whom we record a level of
% testosterone, in the vector called testo
% and their age called age
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

testo = [20    21    19    18    51    37    68    28    52    18    19    50    43    13    19    23    27    31    37    31];
age =   [43    38    36    35    29    27    27    26    25    58    25    22    19    44    34    30    29    26    25    22];

totalN=size(testo,2); %use size to work out size of data arrays; use 2 as it means number of colyumns

%note we have to turn the data from row vectors into column vectors using '
%in order to use the corr command
obs_corr=corr(testo', age'); 

%and we use num2str to turn the number into a string for displaying
disp(['The correlation between testosterone levels and age found in our data sample = ' num2str(obs_corr)]); 
disp('Resampling ...')

nresamples=10000;
%set up the arrays to record the 
resample_corr = zeros(nresamples,1);

for i=1:nresamples
    
    %resampling
    testo_r=datasample(testo, totalN, 'Replace', false); 
    
    %record data for each resampled correlation
    resample_corr(i,1) = corr(testo_r',age'); 
    
end

%first evaluate the randomisation results
mycount = sum(resample_corr <= obs_corr); %how many results in the resampling distribution are at or below our observed correlation
resamp_prob = mycount./nresamples;
%you might find it useful to uncomment the next line
%disp(['The mean of the resampled correlations = ' num2str(mean(resample_corr))]) 
disp(['The probability of a resampled correlation at least as negative as our observed corr = ' num2str(resamp_prob)]) 
%histogram of the results
hist(resample_corr); 
ylabel('Frequency');
xlabel('Correlation');
title('Resampling results')

