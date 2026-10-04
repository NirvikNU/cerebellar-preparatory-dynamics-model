function audit=pf_validate_sources(source)
    folder=fullfile(source,'tables'); audit=struct('status','PASS','dTrials',64,'efTrialsPerCondition',15,'insetTrialsPerCondition',30);
    chosen=readmatrix(fullfile(folder,'Fig6d_selected_trials.csv'));
    paths=readmatrix(fullfile(folder,'Fig6d_displayed_native_paths.csv'));
    means=readmatrix(fullfile(folder,'Fig6d_same_four_phase_means.csv'));
    idsI=[20 7 28 32;27 4 41 32;38 8 17 16;15 14 7 3;6 30 29 23;41 10 23 31;39 20 13 8;8 38 25 28];
    idsB=[55 185 94 49;187 56 136 178;388 110 342 379;2867 518 4931 1860;2361 2002 681 2360;26 67 61 8;2237 1043 2136 2765;95 129 272 39];
    frozen={idsI,idsB}; audit.phaseMeanMaxError=0;
    assert(size(chosen,1)==64 && all(chosen(:,1)==3) && all(chosen(:,2)==18003) && all(chosen(:,3)==8));
    for p=1:2
        for q=1:8
            t=chosen(chosen(:,4)==p & chosen(:,5)==q,:); assert(isequal(t(:,8).',frozen{p}(q,:)));
            phase=zeros(101,2,4);
            for j=1:4
                xy=paths(paths(:,2)==p & paths(:,3)==q & paths(:,4)==t(j,8),:);
                rows=xy(:,5)>=t(j,11) & xy(:,5)<=t(j,12);
                phase(:,:,j)=interp1(linspace(0,1,nnz(rows)).',xy(rows,6:7),linspace(0,1,101).');
            end
            m=means(means(:,3)==p & means(:,4)==q,6:7);
            audit.phaseMeanMaxError=max(audit.phaseMeanMaxError,max(abs(mean(phase,3)-m),[],'all'));
        end
    end
    assert(audit.phaseMeanMaxError<1e-12);
    selected=readmatrix(fullfile(folder,'Fig6ef_selected_trials.csv'));
    raw=readmatrix(fullfile(folder,'Fig6e_raw_thin_traces.csv'));
    support=readmatrix(fullfile(folder,'Fig6e_median_support.csv'));
    inset=readmatrix(fullfile(folder,'Fig6f_all30_inset.csv'));
    hist=readmatrix(fullfile(folder,'Fig6f_histogram_counts.csv'));
    frozen={ [10 3 41 33 38 20 7 15 19 9 31 42 14 28 29], [67 102 28 78 22 88 96 49 9 29 2 56 47 58 61] };
    audit.rawMedianMaxError=0; audit.gaussianMaxError=0; audit.insetDistanceMaxError=0;
    operator=smoothdata(eye(151),1,'gaussian',50); kernel=operator(76,:); offsets=find(kernel>0)-76; weights=kernel(kernel>0);
    for p=1:2
        ids=selected(selected(:,3)==p,6).'; assert(isequal(ids,frozen{p}));
        speed=nan(600,15);
        for j=1:15
            rows=raw(raw(:,1)==p & raw(:,2)==ids(j),:); assert(isequal(rows(:,3),(0:599).')); speed(:,j)=rows(:,4);
        end
        nActive=sum(isfinite(speed),2); medianRaw=median(speed,2,'omitnan'); last=find(nActive>0,1,'last'); cut=find(nActive>=8,1,'last');
        t=support(support(:,1)==p,:); assert(isequal(t(:,3),nActive) && max(nActive)==15 && cut<last);
        audit.rawMedianMaxError=max(audit.rawMedianMaxError,max(abs(t(:,4)-medianRaw),[],'omitnan'));
        smoothed=nan(600,1);
        for j=1:last
            indices=j+offsets; keep=indices>=1 & indices<=last;
            smoothed(j)=sum(weights(keep).*medianRaw(indices(keep)).')/sum(weights(keep));
        end
        audit.gaussianMaxError=max(audit.gaussianMaxError,max(abs(t(:,5)-smoothed),[],'omitnan'));
        assert(isequaln(t(1:cut,6),t(1:cut,5)) && all(isnan(t(cut+1:end,6))));
        points=inset(inset(:,3)==p,:); assert(size(points,1)==30);
        xy=points(:,9:10); distances=sqrt(sum((xy-median(xy,1)).^2,2));
        audit.insetDistanceMaxError=max(audit.insetDistanceMaxError,max(abs(distances-points(:,11))));
        counts=histcounts(distances,[hist(:,1).' hist(end,2)]).'; assert(isequal(counts,hist(:,2+p)) && sum(counts)==30);
    end
    assert(audit.rawMedianMaxError<1e-14 && audit.gaussianMaxError<1e-12 && audit.insetDistanceMaxError<1e-12);
    values=jsondecode(fileread(fullfile(folder,'Fig6gh_values.json')));
    rows=readmatrix(fullfile(folder,'Fig6gh_network_values.csv'));
    assert(isequal(values.levels(:),[.05;.1;.15;.2])); audit.quantitativeValueMaxError=0;
    for j=1:size(rows,1)
        n=rows(j,1); sweep=rows(j,2); level=find(values.levels==rows(j,3));
        exact=[values.RI(n,level,sweep) values.RB(n,level,sweep) values.loss(n,level,sweep)];
        audit.quantitativeValueMaxError=max(audit.quantitativeValueMaxError,max(abs(exact-rows(j,4:6))));
    end
    assert(audit.quantitativeValueMaxError<1e-14);
    assert(max(abs(100*(values.RI-values.RB)./values.RI-values.loss),[],'all')<1e-12);
    experimental=readtable(fullfile(folder,'ED7bc_experiment.csv'));
    for name={'ED7b','ED7c'}
        z=load(fullfile(source,[name{1} '_graphics.mat'])); c=0;
        for j=1:numel(z.recipe.axes{1}.objects)
            o=z.recipe.axes{1}.objects{j};
            if strcmp(o.type,'errorbar')
                c=c+1; row=experimental(strcmp(experimental.panel,name{1}) & experimental.conditionIndex==c,:);
                assert(row.value==o.properties.YData(1) && row.standardDeviation==o.properties.YPositiveDelta(1));
            end
        end
        assert(c==2);
    end
    audit.experimentalSourceRows=height(experimental);
    audit.noNewStatistics=true; audit.noSelection=true;
end
