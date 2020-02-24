%tvlive.m
%
%this is a resampling programme
%it does a randomisation test for binary probabilities in 2 groups
%written by AP and MG
%v1.01 6.1.2017

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
% Some students have been studying a course live, and some on TV.
% At the end, they are asked whether they would recommend the course.
% 24 watched it live.  Of these, 20 sould recommend it.
% 9 watched it on TV.  Of these, 6 would recommend it.
% Is the proportion of recommendations significantly different in the two conditions?
% We could investigate this with a chi-square test.
% But we are worried about how well the chi-squred test will work
% with such small groups
% So (using resampling) we could simply say
% Watching live, the proportion who would recommend is 0.833333
% Watching on TV, the proportion who would recommend is 0.666667
% The difference in proportions (live group minus tv group) is 0.16667
% Is this significantly different from 0 (expected under the null hypothesis
% that the mode of delivery makes no difference)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%next we specify the above scenario and data
%in this example we have 2 groups with sizes 24 and 9
g1n=24; %this is the live group size
g1_1s=20; %20 Ss in live grp recommended (outcome=1)
g2n=9;  %this is the tv group size
g2_1s=6; %6 Ss in the TV grp recommended (outcome=1)
totalN=g1n+g2n; %total N
total_1s=g1_1s+g2_1s; %total recommends across both groups
total_0s=totalN-total_1s; %ditto for 0s (not recommend)
obs_diff_prop=(g1_1s/g1n) - (g2_1s/g2n); %this is the actual observed difference in recommend proportions 

%the next line of code produces our 33 observations, 26 1s and 7 0s
%this doesn't worry about groups, as the resampling will create the groups
%randomly each time from these data.
%The data will be in a variable called urn with 1 row and 33 columns
urn = [ones(1,total_1s) zeros(1,total_0s)]; %the first total_1s points are 1s and the next total_0s are zeros 

n_resamples=5000; %we could put this under user control using the input command
alpha=0.05; %standard significance level / Type 1 error rate
myresults=zeros(n_resamples,1); %creates an empty vector for our results, to be filled later

%next is a loop for carrying out the resampling
for sample = 1:n_resamples
    %the next line of code is the key line in the programme
    %it takes a sample from urn without replacement
    shuffle_s = datasample(urn, totalN, 'Replace', false);
    live_s = shuffle_s(1:g1n); %this assigns some of the resampled data to the live group
    live_s_y = sum(live_s==1);  %and counts how many recommend outcomes (1s) there are in the live group
    live_s_prop = live_s_y/g1n; %and then computes this as a proportion
    tv_s = shuffle_s(g1n+1:totalN); %this repeats the above operations for the tv group
    tv_s_y = sum(tv_s==1);
    tv_s_prop = tv_s_y/g2n;
    diff_s = live_s_prop - tv_s_prop; %this is the resampled difference in proportion, live minus TV
    myresults(sample) = diff_s; %stores the resampled result in a myresults vector
end

%now work out the key info from the resampled results
%the next line of code counts how many times our resampled data
%show an observed difference of proportions which is as great or greater than
%the value seen in our real data
count=sum(myresults>=obs_diff_prop);
prob=count/n_resamples;

%now we report the results on screen
%in the next command line we use num2str to convert the numerical value of
%the variable obs_diff_prop into a string for displaying purposes
disp(['The observed difference in proportion = ' num2str(obs_diff_prop)])
disp(['The prob. of a resampled value as large as that in the observed data = ' num2str(prob)])
%next we work out what the critical difference in proportion would have had
%to be in order to get a significant result at prob level alpha
test_ptile=100*(1-alpha); %this is the percentile (eg 95th) that we want
%next we find the value of that percentile in our resampled proportion
%difference results (ie in my results), using Matlab's percentile command
critical_value=prctile(myresults,test_ptile); %prctile gives percentiles
disp(['For alpha = ' num2str(alpha) ','])
disp(['then the critical value from the resampled statistic distribution = ' num2str(critical_value)])

%now display the results in a table and a histogram
tabulate(myresults)   %trhe tabulate command does what you'd expect!
hist(myresults); %the histogram command does what you'd expect!
%the next 3 lines label the histogram appropriately
title('Resampled data for recommendation rates in 2 groups');
ylabel('Frequency');
xlabel('Difference in proportion recommending for live grp minus TV grp');
hold on; %so we draw the next command on the previous figure
xpoints=[obs_diff_prop,obs_diff_prop]; %create x values for start and end of line
ypoints=[0,n_resamples.*0.4]; %create y values for start and end of line
obsval = plot(xpoints,ypoints,'-r'); %draws red r vertical line for obs proportion diff
%in the previous line we assigned a handle variable obsval for the plot so we could
%relate the legend specifically to that part of the figure
legend(obsval,'Observed diff in proportion') %we add a legend for the observed difference
