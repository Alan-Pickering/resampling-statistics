%chi2rand.m
%computes chi2 value from raw data
%and then does a randomisation test on the data

%the first few lines of code are general for all Matlab programmes
%first we need to set the random number seed so that we get the same
%randomisation sequence each time we run the programme
%here we set it so that the sequence is the one you get if you first
%started up Matlab
rng('default'); %rng = Random Number Generator
clear variables;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%these data are the smoking and parkinson's disease dataset we have used
%before. Column 1 is smoker(1) or not (2); Column 2 is parkinson's disease
%yes (1) or not (2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%sample data
obs=[
1	1;
1	1;
1	1;
1	0;
1	0;
1	0;
1	0;
1	0;
1	0;
1	0;
1	0;
1	0;
1	0;
1	0;
2	1;
2	1;
2	1;
2	1;
2	1;
2	1;
2	0;
2	0
];

N=size(obs,1);

%first work out the actual chi-squared test on the original data
disp('The original data give the following results...')
[TABLE,CHI2,P] = crosstab(obs(:,1),obs(:,2))

disp('Hit any key to begin resampling ....')
pause;

nresamps=5000;

chires=zeros(nresamps,1);

randobs=obs; %copy the raw data into the randomised observation data

for i=1:nresamps
    
    %now we can randomise the second column with respect to the first
    %randperm(N)' puts N integers in a random order in a column, cos of the
    %tarnspose operation '
    randobs(:,2)=obs(randperm(N)',2); %using the randperm variable to randomise the second column
    [TABLE,chires(i,1),P] = crosstab(randobs(:,1),randobs(:,2));
    
end

alpha=0.05; %standard type 1 error rate
histogram(chires); %plot a histogram
xlabel('Chi-sq. value');
ylabel('Frequency');
disp(['Mean value of resampled chi-sq. distribution= ' num2str(mean(chires))])
disp(['Std value of resampled chi-sq. distribution= ' num2str(std(chires))])
%the next line gives the value our chi-squared will have to exceed in order to be declared sig at alpha
critvalue=prctile(chires,100*(1-alpha));
disp(critvalue);
%the next line estimate the probability of our chi-sqaured observed value
%(CHI2) from the resampled (randomised distribution)
p_estimate=sum(chires>=CHI2)./nresamps;
disp(p_estimate);




