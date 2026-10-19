function audit=pf_validate_noise_sources(source)
    % Audit current noise sources without fitting models or generating random draws.
    folder=fullfile(source,'tables');spec=pf_noise_grid;
    v=jsondecode(fileread(fullfile(folder,'Fig6gh_values.json')));
    rows=readmatrix(fullfile(folder,'Fig6gh_network_values.csv'));
    summaries=readmatrix(fullfile(folder,'Fig6gh_summaries.csv'));
    cases=readmatrix(fullfile(folder,'Fig6gh_case_qc.csv'));
    tests=readmatrix(fullfile(folder,'Fig6gh_tests.csv'));
    assert(isequal(v.levels(:).',spec.levels)&&isequal(v.pairs,spec.pairs)&&isequal(v.pairIndex,spec.pairIndex));
    assert(isequal(size(rows),[160 19])&&isequal(size(summaries),[16 9])&&isequal(size(cases),[300 12])&&isequal(size(tests),[4 6]));
    assert(all(isfinite([rows(:);summaries(:);cases(:);tests(:)])));
    assert(all(abs(v.RI)>sqrt(eps),'all')&&isequal(v.loss,100*(v.RI-v.RB)./v.RI));
    z=load(fullfile(source,'noise_sensitivity_20261019/bootstrap_indices.mat'),'indices');indices=z.indices;
    assert(isequal(size(indices),[10000 10])&&all(ismember(indices,1:10),'all'));
    audit=struct('status','PASS','networkRows',160,'uniqueCases',300,'summaryRows',16,'tests',4, ...
        'quantitativeValueMaxError',0,'bootstrapMaxError',0,'sharedBaselineExact',true);
    for sweep=1:2
        for level=1:8
            pairID=spec.pairIndex(level,sweep);pair=spec.pairs(pairID,:);
            for n=1:10
                row=rows(rows(:,1)==n & rows(:,2)==sweep & rows(:,3)==spec.levels(level),:);assert(size(row,1)==1);
                exact=[v.RI(n,level,sweep) v.RB(n,level,sweep) v.loss(n,level,sweep) pair pairID ...
                    v.SSEI(n,level,sweep) v.SSTI(n,level,sweep) v.SSEB(n,level,sweep) v.SSTB(n,level,sweep)];
                assert(isequal(row(4:13),exact));
                for p=1:2
                    c=cases(cases(:,1)==n & cases(:,2)==pairID & cases(:,3)==spec.policies(p),:);assert(size(c,1)==1);
                    assert(isequal(c(4:5),pair)&&c(6)==row(3+p)&&c(6)==1-c(7)/c(8));
                    assert(c(7)>=0&&c(8)>0&&c(11)==240&&c(12)==(c(6)<0));
                    assert(isequal(c(7:8),row(8+2*p:9+2*p))&&isequal(c(9:10),row(12+2*p:13+2*p)));
                    assert(all(c(9:10)>=1)&&all(c(9:10)<=200));
                end
                assert(all(row(18:19)==240));
            end
            summary=summaries(summaries(:,1)==sweep & summaries(:,2)==spec.levels(level),:);assert(size(summary,1)==1&&summary(9)==10);
            fields={'RI','RB','loss'};
            for metric=1:3
                name=fields{metric};x=v.(name)(:,level,sweep);med=median(x);
                se=std(median(reshape(x(indices),10000,10),2));
                error=max(abs([med se]-summary(1+2*metric:2+2*metric)));
                audit.bootstrapMaxError=max(audit.bootstrapMaxError,error);
                assert(error<1e-12&&isequal(summary(1+2*metric:2+2*metric),[v.bootstrap.(name)(sweep).median(level) v.bootstrap.(name)(sweep).se(level)]));
            end
        end
        for metric=1:2
            if metric==1,x=v.RI(:,:,sweep);record=v.controlFriedman(sweep);else,x=v.loss(:,:,sweep);record=v.lossFriedman(sweep);end
            [chi,p]=friedmanAudit(x);row=tests(tests(:,1)==metric & tests(:,2)==sweep,:);
            assert(size(row,1)==1&&row(4)==7&&row(6)==10&&row(5)==record.rawP);
            assert(abs(row(5)-p)<eps+1e-12*p&&abs(row(3)-chi)<1e-12&&row(3)==record.chiSquare);
        end
    end
    for name={'RI','RB','loss','SSEI','SSEB','SSTI','SSTB'}
        x=v.(name{1});assert(isequal(x(:,1,1),x(:,1,2)));
    end
    assert(isequal(summaries(1,2:end),summaries(9,2:end)));
    for name={'Fig6g','Fig6h'}
        z=load(fullfile(source,[name{1} '_graphics.mat']),'recipe');r=z.recipe.axes{1};sweep=0;
        isControlSweeps=strcmp(name{1},'Fig6g');
        for j=1:numel(r.objects)
            o=r.objects{j};
            if strcmp(o.type,'errorbar')
                sweep=sweep+1;
                if isControlSweeps
                    summary=v.bootstrap.RI(sweep);
                else
                    fields={'RI','RB'};labels={'Control','Block'};colors=[86 180 233;213 94 0]/255;
                    summary=v.bootstrap.(fields{sweep})(2);
                    assert(strcmp(o.properties.DisplayName,labels{sweep})&&strcmp(o.properties.LineStyle,'-'));
                    assert(isequal(o.properties.Color,colors(sweep,:))&&isequal(o.properties.MarkerFaceColor,colors(sweep,:)));
                end
                assert(isequal(o.properties.XData,v.levels(:).')&&isequal(o.properties.YData,summary.median(:).'));
                assert(isequal(o.properties.YNegativeDelta,summary.se(:).')&&isequal(o.properties.YPositiveDelta,summary.se(:).'));
                assert(all(summary.median-summary.se>=r.properties.YLim(1))&&all(summary.median+summary.se<=r.properties.YLim(2)));
            elseif strcmp(o.type,'constantline')
                assert(o.properties.Value==.05&&strcmp(o.properties.Label,'Shared 0.05/0.05 anchor'));
            end
        end
        assert(sweep==2&&isequal(r.properties.XTick,spec.levels));
        if ~isControlSweeps
            assert(strcmp(r.xlabel,'Temporal noise amplitude (state units)')&&strcmp(r.ylabel,'Cross-validated R^2'));
            assert(isequal(r.legend.labels,{'Control','Block'}));
            g=load(fullfile(source,'Fig6g_graphics.mat'),'recipe');
            temporal=g.recipe.axes{1}.objects{2}.properties;control=r.objects{1}.properties;
            for field={'XData','YData','YNegativeDelta','YPositiveDelta'}
                assert(isequal(temporal.(field{1}),control.(field{1})),'Production:NoiseControlAnchor','Fig6g/h temporal Control values differ.');
            end
        end
    end
end
function [chi,p]=friedmanAudit(x)
    [n,k]=size(x);ranks=zeros(n,k);ties=0;
    for j=1:n
        [sorted,order]=sort(x(j,:));start=1;
        while start<=k
            last=start;while last<k&&sorted(last+1)==sorted(start),last=last+1;end
            ranks(j,order(start:last))=(start+last)/2;count=last-start+1;ties=ties+count^3-count;
            start=last+1;
        end
    end
    chi=(12/(n*k*(k+1))*sum(sum(ranks,1).^2)-3*n*(k+1))/(1-ties/(n*(k^3-k)));
    p=gammainc(chi/2,(k-1)/2,'upper');
end
