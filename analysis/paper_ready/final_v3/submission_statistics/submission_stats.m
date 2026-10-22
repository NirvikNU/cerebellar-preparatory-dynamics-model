function out=submission_stats(repo,dest)
    assert(~isfolder(dest),'Submission:NoOverwrite','Preserve existing statistical evidence.');
    mkdir(dest);addpath(fullfile(repo,'analysis/paper_ready/final_v3/production'));
    tab=readtable(fullfile(repo,'data/paper_ready/final_v3/tables/Fig6gh_network_values.csv'));
    summaries=readtable(fullfile(repo,'data/paper_ready/final_v3/tables/Fig6gh_summaries.csv'));
    source=jsondecode(fileread(fullfile(repo,'data/paper_ready/final_v3/tables/Fig6gh_values.json')));
    levels=source.levels(:);assert(isequal(levels,(.05:.05:.40).')||max(abs(levels-(.05:.05:.40).'))<eps);
    delta=zeros(10,8);rowCells=cell(8,1);networkRows=zeros(80,5);
    for j=1:8
        t=sortrows(tab(tab.sweep_1initial_2temporal==2&abs(tab.amplitude-levels(j))<eps,:),'network');
        assert(isequal(t.network,(1:10).')&&all(t.initialNoise==.05)&&all(t.ControlWindows==240)&&all(t.BlockWindows==240));
        assert(isequal(t.ControlR2,source.RI(:,j,2))&&isequal(t.BlockR2,source.RB(:,j,2)));
        delta(:,j)=t.ControlR2-t.BlockR2;d=delta(:,j);
        [reject,adP,adStatistic,adCritical]=adtest(d,'Distribution','norm','Alpha',.05);
        if ~reject
            [~,p,ci,stats]=ttest(d,0,'Tail','both','Alpha',.05);
            testName='two-sided paired t-test';statistic=stats.tstat;df=stats.df;
        else
            [p,~,stats]=signrank(d,0,'Tail','both','Method','exact');
            testName='two-sided exact Wilcoxon signed-rank';statistic=stats.signedrank;df=NaN;ci=[NaN NaN];
        end
        ss=summaries(summaries.sweep_1initial_2temporal==2&abs(summaries.amplitude-levels(j))<eps,:);assert(height(ss)==1);
        rowCells{j}=struct('temporalNoise',levels(j),'initialNoise',.05,'n',10,'ADReject',logical(reject), ...
            'ADP',adP,'ADStatistic',adStatistic,'ADCritical05',adCritical,'testName',testName, ...
            'testStatistic',statistic,'df',df,'rawP',p,'BHq',NaN,'pairedMeanDeltaR2',mean(d), ...
            'pairedSampleSD',std(d,0),'pairedSEM',std(d,0)/sqrt(10),'pairedMedianDeltaR2',median(d), ...
            'pairedMeanCI95Low',ci(1),'pairedMeanCI95High',ci(2), ...
            'ControlMedianR2',ss.ControlR2Median,'ControlBootstrapSE',ss.ControlR2SE, ...
            'BlockMedianR2',ss.BlockR2Median,'BlockBootstrapSE',ss.BlockR2SE);
        networkRows((j-1)*10+(1:10),:)=[t.network,repmat(levels(j),10,1),t.ControlR2,t.BlockR2,d];
    end
    rows=vertcat(rowCells{:});
    p=[rows.rawP].';[sorted,order]=sort(p);adjusted=min(1,flipud(cummin(flipud(sorted*8./(1:8).'))));
    q=zeros(8,1);q(order)=adjusted;for j=1:8,rows(j).BHq=q(j);end
    medians=median(delta,2);
    out=struct('schemaVersion',1,'sourceCommit','7977e16de7c406210b6df7dd44d8e457670858d2', ...
        'statisticalUnit','Ten matched frozen networks; all 240 trials retained in each published case', ...
        'contrast','Control minus Block R2','family','Eight temporal-noise paired comparisons; one BH family', ...
        'normalityPolicy','MATLAB adtest composite normal, alpha=0.05; two-sided ttest if not rejected, exact signrank otherwise', ...
        'rows',rows,'networkIDs',(1:10).','networkMedianAcrossEightLevels',medians, ...
        'meanOfNetworkMedians',mean(medians),'sampleSDOfNetworkMedians',std(medians,0), ...
        'SEMOfNetworkMedians',std(medians,0)/sqrt(10),'maximumBHq',max(q), ...
        'existingFigureMediansAndBootstrapSEUnchanged',true,'matlabVersion',version,'status','COMPUTED_PENDING_GATES');
    pf_json(fullfile(dest,'paired_statistics.json'),out);
    save(fullfile(dest,'paired_statistics.mat'),'out','delta','networkRows','-v7');
    writeNumeric(fullfile(dest,'paired_network_differences.csv'),{'network','temporalNoise','ControlR2','BlockR2','ControlMinusBlockR2'},networkRows);
    writeNumeric(fullfile(dest,'network_median_differences.csv'),{'network','medianControlMinusBlockAcrossEightLevels'},[(1:10).',medians]);
    fields=fieldnames(rows);fid=fopen(fullfile(dest,'paired_tests.csv'),'w');assert(fid>0);guard=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',strjoin(fields,','));
    for j=1:8
        values=cell(1,numel(fields));
        for k=1:numel(fields)
            value=rows(j).(fields{k});if ischar(value),values{k}=value;else,values{k}=sprintf('%.17g',double(value));end
        end
        fprintf(fid,'%s\n',strjoin(values,','));
    end
    clear guard
    fprintf('Mean of network medians %.17g; SEM %.17g; max BH q %.17g\n',mean(medians),std(medians,0)/sqrt(10),max(q));
    for j=1:8,fprintf('%.2f AD %.17g reject %d t %.17g p %.17g q %.17g\n',levels(j),rows(j).ADP,rows(j).ADReject,rows(j).testStatistic,rows(j).rawP,rows(j).BHq);end
    assert(~any([rows.ADReject])&&max(q)<.001,'Submission:PreflightContradiction','MATLAB contradicts the authorized expected normality/significance preflight. Stop.');
    assert(abs(mean(medians)-.08732)<.00005&&abs(std(medians,0)/sqrt(10)-.00781)<.00005,'Submission:SummaryContradiction','Network-median summary differs from expected preflight.');
    pf_json(fullfile(dest,'matlab_gate.json'),struct('status','PASS','allEightNormalityNonrejections',true,'allEightBHBelow001',true,'summaryMatchesExpectedRounding',true));
end

function writeNumeric(path,header,values)
    fid=fopen(path,'w');assert(fid>0);guard=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',strjoin(header,','));
    for j=1:size(values,1)
        fprintf(fid,'%.17g',values(j,1));fprintf(fid,',%.17g',values(j,2:end));fprintf(fid,'\n');
    end
end
