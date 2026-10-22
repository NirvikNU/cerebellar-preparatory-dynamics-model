function report=submission_null_summaries(repo,source,dest)
    assert(~isfolder(dest));mkdir(dest);addpath(fullfile(repo,'analysis/paper_ready/final_v3/production'));
    labels={'Control_initial','Control_temporal','Block_temporal'};items=cell(10,1);
    for n=1:10
        z=load(fullfile(source,sprintf('null_network_%02d.mat',n)));assert(numel(z.results)==23);
        items{n}=z.results;
    end
    cases=vertcat(items{:});assert(numel(cases)==230);R=cases(1).repeats;assert(mod(R,4)==0);
    caseRows=cell(230,1);ranks=zeros(230,2);
    for j=1:230
        c=cases(j);assert(c.repeats==R&&strcmp(c.status,'PASS')&&isequal(c.R2,1-c.SSE./c.SST));
        assert(isequal(sort(c.permutations,1),repmat(uint16((1:240).'),1,R)));
        same=items{c.network};assert(isequal(c.permutations,same(1).permutations));ranks(j,:)=c.ranks;
        caseRows{j}=struct('network',c.network,'pairID',c.pairID,'policy',c.policy,'initialNoise',c.initialNoise, ...
            'temporalNoise',c.temporalNoise,'shuffles',R,'medianR2',median(c.R2),'meanR2',mean(c.R2), ...
            'SDR2',std(c.R2),'minimumR2',min(c.R2),'maximumR2',max(c.R2),'negativeCount',sum(c.R2<0), ...
            'medianSSE',median(c.SSE),'medianSST',median(c.SST),'prepRank',c.ranks(1),'movementRank',c.ranks(2));
    end
    subsets={1:R,1:R/2,R/2+1:R,1:R/4,R/4+1:R/2,R/2+1:3*R/4,3*R/4+1:R};
    estimates=zeros(3,7,2);networkValues=zeros(10,3);levelRows=cell(240,1);networkRows=cell(30,1);at=0;
    for group=1:3
        if group==1,pairs=1:8;else,pairs=[1 9:15];end
        if group==3,policy=4;else,policy=1;end
        for subset=1:7
            matrix=zeros(10,8);
            for n=1:10
                for level=1:8
                    idx=find([cases.network]==n&[cases.pairID]==pairs(level)&[cases.policy]==policy);assert(isscalar(idx));
                    matrix(n,level)=median(cases(idx).R2(subsets{subset}));
                    if subset==1
                        at=at+1;levelRows{at}=struct('summary',labels{group},'network',n,'level',level, ...
                            'amplitude',.05*level,'pairID',pairs(level),'medianShuffledR2',matrix(n,level));
                    end
                end
            end
            medians=median(matrix,2);estimates(group,subset,:)=[mean(medians),std(medians)/sqrt(10)];
            if subset==1
                networkValues(:,group)=medians;
                for n=1:10,networkRows{(group-1)*10+n}=struct('summary',labels{group},'network',n,'medianAcrossEightLevels',medians(n));end
            end
        end
    end
    rows=cell(3,1);pass=true;
    for group=1:3
        meanSE=reshape(estimates(group,1,:),1,2);halves=squeeze(estimates(group,2:3,:));batches=squeeze(estimates(group,4:7,:));
        rounding=all(round(halves,3)==round(meanSE,3),'all');mcSE=std(batches,0,1)/2;precision=rounding&&all(mcSE<.000125);pass=pass&&precision;
        rows{group}=struct('summary',labels{group},'networks',10,'levels',8,'shufflesPerCase',R,'meanR2',meanSE(1), ...
            'SEM',meanSE(2),'meanMonteCarloSE',mcSE(1),'SEMMonteCarloSE',mcSE(2),'halfRoundingStable',rounding,'precisionPass',precision);
    end
    report=struct('status','PASS','repeats',R,'distinctCases',230,'caseFits',230*R,'summaries',{vertcat(rows{:})}, ...
        'precisionFullHalvesBatches',estimates,'networkMedians',networkValues,'negativeValuesRetained',true, ...
        'sharedControlAnchorComputedOnce',true,'seedFormula','352000000+100000*network+repeat', ...
        'estimator','Median shuffles within case; median eight levels within network; mean and sample SEM of ten network medians', ...
        'maximumPrepRank',max(ranks(:,1)),'maximumMovementRank',max(ranks(:,2)));
    if ~pass,report.status='PRECISION_EXTENSION_REQUIRED';end
    pf_json(fullfile(dest,'null_summary.json'),report);
    writeRows(fullfile(dest,'null_case_values.csv'),vertcat(caseRows{:}));
    writeRows(fullfile(dest,'null_level_values.csv'),vertcat(levelRows{:}));
    writeRows(fullfile(dest,'null_network_values.csv'),vertcat(networkRows{:}));
    writeRows(fullfile(dest,'null_summaries.csv'),vertcat(rows{:}));
    save(fullfile(dest,'null_summary.mat'),'report','-v7');
    fprintf('NULL PRECISION %s at %d shuffles/case\n',report.status,R);
end
function writeRows(file,rows)
    fields=fieldnames(rows);fid=fopen(file,'w');assert(fid>0);guard=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',strjoin(fields,','));
    for j=1:numel(rows)
        values=cell(1,numel(fields));
        for k=1:numel(fields)
            value=rows(j).(fields{k});if ischar(value),values{k}=value;else,values{k}=sprintf('%.17g',value);end
        end
        fprintf(fid,'%s\n',strjoin(values,','));
    end
end
