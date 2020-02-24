% anova randomisation.m
%
%Adapted from Statistics the Easy Way", by Downing and Clark, p.224, problem 15.
%Perform an analysis-of-variance style test to see if the following
%sets of 11 numbers were selected from distributions with the same mean:

clc;
rng('default');
clear variables;

mydata= [18  9 15 10 16  8  7 20 13  8 12 ...
         17 13  9  8 10 13 16 17 12 11 17 ...
         15 13 13 14 15 20 15 14  9 16 12 ...
         16 12 13 12 14 11  8 13 17 15 14];
     
%group assignments, 4 groups
grandmean=mean(mydata);
ngps=4;
npergp=11;
totalN=ngps.*npergp;
group=ones(totalN,1);
for j=2:ngps
    s=(j-1).*npergp+1;
    e=s+npergp-1;
    group(s:e,1)=j;
end
alldata=[mydata' group];

%uses function to compute SSQDEV (fxn defined at end of this pgm)
[grpmeans, GpSumSqrDev] = SSQDEV(alldata, grandmean, ngps);

figure;
bar(grpmeans);
ylabel('Mean DV value');
xlabel('Group');
title('Means in the 4 groups');

%Now, create a distribution based on the null hypothesis.
%(NOTE: This is not an ANOVA computation. It is a
%demonstration of a simulation approach to solving a
%problem that would normally be solved using ANOVA.)

%do the resampling in the loop below
nresamps=10000;
dispevery=1000;
rand_resamples=zeros(nresamps,1);
boot_resamples=zeros(nresamps,1);
disp('Resampling ...');
for j=1: nresamps
    if mod(j,dispevery)==0
        disp(['Resample number ' num2str(j) ' completed.']);
    end
    %the next 2 lines show how you would bootstrap the data
    %this draws each row (data and gp value) with replacement from alldata
    %thus preserving the link between data point and group
    boot_data=datasample(alldata, totalN, 'Replace', true);
    [~, boot_resamples(j,1)]=SSQDEV(boot_data,mean(boot_data(:,1)),ngps);
    %on the next line we compute the reandomised data
    %if we use datasample with flase for replace then it will pick the rows
    %out of the alldata array, each row without replacement
    %this will NOT break the link in alldata between the score and the
    %group assignment
    rand_data=datasample(alldata, totalN, 'Replace', false);
    %so we need to restore the original group codes from alldata into rand_data
    %in order to randomise the group data associations in rand_data
    rand_data(:,2)=alldata(:,2);
    [~, rand_resamples(j,1)] = SSQDEV(rand_data,grandmean,ngps); %note the grandmean isn't changed by randomisation as all data pts are reused once in each resample

 end


%now evauate the results of the randomisation
figure;
histogram(rand_resamples);
ylabel('Frequency');
xlabel('SSQDEV statistic');
xpoints=[GpSumSqrDev,GpSumSqrDev]; %create x values for start and end of line
ypoints=[0,nresamps.*0.1]; %create y values for start and end of line
hold on; %so we draw the next command on the previous figure
obsval = plot(xpoints,ypoints,'-ro'); %draws red r vertical line for obs median diff
legend(obsval,'Observed SumSqDev');
disp('Computed test statistic -- Sum of Squared Deviations of group means from grand mean');
disp(['Value of this test statistics in actual data= ' num2str(GpSumSqrDev)]);
biggervals = sum(rand_resamples >= GpSumSqrDev);
myprob = biggervals / nresamps;
disp(['Randomization probability of a value as big as (or bigger than) that observed under H0= ' num2str(myprob)]);
alpha=0.05;
nullHypothesisAcceptanceInterval=prctile(rand_resamples,100*(1-alpha));  % note we just inspect one tail of our resampled distribution, as our statistic gets bigger as we reject the null hypothesis
disp(['Crit. value of test statistic which must be exceeded for significance (accepting ' num2str(100*alpha) '% Type 1 errors)= ' num2str(nullHypothesisAcceptanceInterval)]);
msg1='Conclusion: all groups are ';
if GpSumSqrDev > nullHypothesisAcceptanceInterval
	msg2= 'NOT ';
else
    msg2='';
end
disp([msg1 msg2 'from same population. Type 1 error rate= ' num2str(100*alpha) '%.']);

function [gpmeans, groupSumSqrDev] = SSQDEV(alldata, grandmean, ngps)

    gpmeans=zeros(ngps,1);
    groupSumSqrDev=0; %this statistic is the sum of the squared deviations
    %between the sample means and the grand mean
    %the bigger this value the more likely there are some real differences amongst the 4 means
    for j=1:ngps
        gpmeans(j,1)=mean(alldata(alldata(:,2)==j),1);
        groupSumSqrDev=groupSumSqrDev+(gpmeans(j,1)-grandmean).^2;
    end

end
