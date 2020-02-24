%paired_data_resampling.m
%
%this is a resampling programme
%it does a randomisation and bootstrapping test for paired data (paired
%t-test data if done parametrically)
%written by AP 
%v1.01 29.1.2017

%NB there is a small bug fix needed to make the randomization work propoerly
% it doesn't work perfectl at the moment

%the first few lines of code are general for all Matlab programmes
%first we need to set the random number seed so that we get the same
%randomisation sequence each time we run the programme
%here we set it so that the sequence is the one you get if you first
%started up Matlab
rng('default'); %rng = Random Number Generator

clc; %this clears the command window at the start of the programme
clear variables; %this clears any variables from memory

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Below we describe the scenario to which this programme relates.
% these are data taken from Howell chapter 18
% see the lecture slides for a full description
% the differences are endorphin levels in patients just before surgery
% (high stress) minus the endorphin levels 12 hours after surgery (low
% stress).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%data -- a set of 19 differences
%a positive difference means more endoprhins at time of high stress
diffs=[10 7.5 5.5 6 9.5 -2.5 13 3 -0.1 0.2 20.3 4 8 25 7.2 35 -3.5 -1.9 0.1]; %this is the real data
totalN=size(diffs,2); %use size to find the number of observations

%compute a relevant statistic from our data and display reslt
ourresult= median(diffs); %get the median as a vraible ourresult
%and we use num2str to turn the number into a string for displaying
disp(['The median difference found in our data sample = ' num2str(ourresult)]); 
disp('Resampling ...')

%now set up the "urn" of both sets of diffs from which we will draw randomly
%it is twice the size of the original data of course
plusminus=[ones(1,totalN) -1.*ones(1,totalN)]; %this creates a set of plus ones and minus ones

nresamples=10000;
%set up the arrays to record the medians of the resampled samples of each kind
bootsample_med2 = zeros(nresamples,1);
randsample_med1 = zeros(nresamples,1);

for i=1:nresamples
    
    %randomisation
    %we draw half the data in plusminus randomly without replacement
    %so that on average the results will be equally often 1 and -1
    %but the nmbers will vary randomly from trial to trial
    %and will be in a different random order each time
    mysigns=datasample(plusminus, totalN, 'Replace', false);
    %and then we multiply the actual diffs by the resampled mix of 1s and -1s 
    %thus randomising out any effect that might be present in the diffs
    myresample=diffs.*mysigns; %notice we use elementwise (.*) multiplication here
    randsample_med1(i,1) = median(myresample); 
    
    %bootstrapping
    %sample from diffs with replacement, leaving signs as in data
    %this leaves in the orginila effct as present in diffs
    bootsample_med2(i,1) = median(datasample(diffs, totalN, 'Replace', true)); 
    
end

%first evaluate the randomisation results
%do it two tailed
ourlowtail= -1*ourresult; %imagine that the results had been the other way around
low_count = sum(randsample_med1 <= ourlowtail); %how may results in the randomisation sample at or below our result if -ve
hi_count  = sum(randsample_med1 >= ourresult);  %how many results in the randomisation sample at or above our result 
rand_prob= (low_count + hi_count)./nresamples;
disp(['The mean of the randomised median differences = ' num2str(mean(randsample_med1))]) 
disp(['The probability of a randomised median diff. as different from zero as our observed median diff. = ' num2str(rand_prob)]) 
%histogram of the randomisation results
hist(randsample_med1); 
ylabel('Frequency');
xlabel('Median difference');
title('Randomisation resampling results')

%next evaluate bootstrapped results
alpha = 0.05;
alpha100_l=100*alpha/2;
alpha100_h=100*(1-alpha/2);
CLalpha = prctile(bootsample_med2,[alpha100_l alpha100_h]);
disp(' ') %insert a blank line in the output text
disp(['The mean of the bootstrapped median differences = ' num2str(mean(bootsample_med2))]) 
disp(['The ' num2str(alpha100_l) '% and ' num2str(alpha100_h) '% confidence limits on the bootstrapped median difference, are as follows: ' num2str(CLalpha) ])
%if the sign of the CLalpha limit values are both positive then the lower limit is above 0
%if the sign of the CLalpha limit values are both negative then the upper limit is below 0
%if the signs of the CL alpha limit values are opposite (they sum to zero), then the confidence limits include 0
messg=' IS NOT ';
if sum(sign(CLalpha)) == 0
    %rewrite messg in this condition
    messg=' IS ';
end
disp(['A zero median difference' messg 'within the ' num2str(alpha100_l) '% and ' num2str(alpha100_h) '% confidence limits of the bootsrapped sampling distribution.'])    
%histogram of bootstrapped results
figure; %draw a new figure
hist(bootsample_med2); 
ylabel('Frequency');
xlabel('Median difference');
title('Bootstrapped resampling results')
%and the next bit just puts vertical lines on the histogram in key positions
hold on; %so we draw the next command on the previous figure
xpoints=[ourresult,ourresult]; %create x values for start and end of line
ypoints=[0,nresamples.*0.2]; %create y values for start and end of line
obsval = plot(xpoints,ypoints,'-ro'); %draws red r vertical line for obs median diff
xlpoints=[CLalpha(1), CLalpha(1)]; %create x values for start and end of line
xhpoints=[CLalpha(2), CLalpha(2)]; %create x values for start and end of line
lowCL = plot(xlpoints,ypoints,'-bx'); %draws blue b vertical line for low alpha percentile
hiCL = plot(xhpoints,ypoints,'-bx'); %draws blue b vertical line for high alpha percentile
hold off;
%in the previous line we assigned a handle variable obsval for the plot so we could
%relate the legend specifically to that part of the figure
legend([obsval, lowCL],'Observed median diff.',[num2str(alpha100_l) ' ; ' num2str(alpha100_h) ' percentiles']); %we add a legend for the observed difference and the %iles
