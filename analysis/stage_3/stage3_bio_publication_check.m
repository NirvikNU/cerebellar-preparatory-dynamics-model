function report = stage3_bio_publication_check
    % Independent saved arm-step and reopened figure/error-bar inspection.
    cfg=stage3_bio_paths; destination=fullfile(cfg.bioRoot,'publication_check.json'); assert(~isfile(destination));
    s=load(fullfile(cfg.bioRoot,'population.mat'),'result'); pop=s.result;
    s=load(fullfile(cfg.bioRoot,'movement.mat'),'result'); move=s.result;
    report=struct('status','PASS','checks',0,'maxAbsoluteError',0,'armRolloutsChecked',20,'figuresReopened',4);
    for n=1:10
        s=load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',n)),'model'); m=s.model;
        for policy=[1 4]
            s=load(fullfile(cfg.bioCache,sprintf('movement_n%02d_p%d.mat',n,policy)),'evidence'); e=s.evidence;
            for target=1:8
                x=e.theta(1:end-1,:,target); next=e.theta(2:end,:,target); torque=e.movement.torque(:,:,target);
                arm=m.arm; q2=x(:,3); d1=x(:,2); d2=x(:,4);
                constant=arm.I1+arm.I2+arm.M2*arm.L1^2;
                coupling=arm.M2*arm.L1*arm.S2;
                m22=arm.I2; m12=arm.I2+coupling*cos(q2); m11=constant+2*coupling*cos(q2);
                damping=[d1 d2]*arm.B.'; sine=coupling*sin(q2);
                rhs1=torque(:,1)+sine.*d2.*(2*d1+d2)-damping(:,1);
                rhs2=torque(:,2)-sine.*d1.^2-damping(:,2);
                determinant=m11*m22-m12.^2;
                acc1=(m22*rhs1-m12.*rhs2)./determinant;
                acc2=(m11.*rhs2-m12.*rhs1)./determinant;
                predicted=x+m.samplingDt*[d1 acc1 d2 acc2];
                check(next,predicted);
            end
        end
    end
    names={'result_1_preparation_and_movement','result_2_preparatory_geometry', ...
        'diagnostic_1_feasible_solution_map','diagnostic_2_component_removal'};
    for index=1:4
        f=openfig(fullfile(cfg.plotsFigRoot,[names{index} '.fig']),'invisible');
        assert(strcmp(f.UserData.task,'STAGE3-BIOLOGICAL-CONTROLLER-RESUME-02'));
        axesList=findall(f,'Type','axes');
        if index==1
            ax=findAxis(axesList,'C  Movement consequence');
            checkErrors(ax,move.statistics.earlyErrorMM);
        elseif index==2
            ax=findAxis(axesList,'B  Preparatory dimensionality'); checkErrors(ax,move.statistics.pr);
            ax=findAxis(axesList,'C  Directed alignment');
            checkErrors(ax,struct('median',100*move.statistics.alignment.median,'se',100*move.statistics.alignment.se));
        elseif index==3
            ax=findAxis(axesList,'B  Generality across the unchanged grid'); scatters=findall(ax,'Type','scatter');
            map=readtable(fullfile(cfg.bioRoot,'feasibility_map.csv')); expected=zeros(36,1);
            for j=1:36, expected(j)=sum(map.feasible & map.gridIndex==j)/30; end
            candidate=scatters(arrayfun(@(h)numel(h.CData)==36,scatters)); assert(isscalar(candidate));
            check(candidate.CData(:),expected);
        else
            fields={'fullDistanceStar','fullDistanceBlock','fullNormalizedEQ','pr','deficit'};
            titles={'A  Distance to movement-valid state','B  Distance to alternative block state', ...
                'C  Prospective motor error','D  Trailing-100-ms PR','E  Trailing-100-ms alignment deficit'};
            for panel=1:5
                ax=findAxis(axesList,titles{panel}); check(ax.XLim,[-600 0]);
                lines=findall(ax,'Type','line'); scale=1; if panel==5, scale=100; end
                for policy=1:4
                    h=lines(arrayfun(@(v)strcmp(v.DisplayName,cfg.policyNames{policy}),lines)); assert(isscalar(h));
                    expected=scale*median(squeeze(pop.(fields{panel})(:,policy,:)),1);
                    check(h.YData,expected);
                end
            end
        end
        close(f); pixels=imread(fullfile(cfg.plotsPngRoot,[names{index} '.png'])); assert(size(pixels,2)>1000);
    end
    stage3_write_json(destination,report);

    function ax=findAxis(axesList,titleText)
        matches=arrayfun(@(a)any(contains(string(a.Title.String),titleText)),axesList);
        ax=axesList(matches); assert(isscalar(ax));
    end

    function checkErrors(ax,summary)
        h=findall(ax,'Type','errorbar'); assert(numel(h)==2);
        for condition=1:2
            bar=h(arrayfun(@(v)v.XData==condition,h)); assert(isscalar(bar));
            check(bar.YData,summary.median(condition));
            check(bar.YNegativeDelta,summary.se(condition)); check(bar.YPositiveDelta,summary.se(condition));
        end
    end

    function check(actual,expected)
        assert(isequal(size(actual),size(expected)) && isequal(isnan(actual),isnan(expected)));
        finite=isfinite(expected); err=max(abs(actual(finite)-expected(finite)));
        if isempty(err), err=0; end
        assert(err<=1e-9+1e-10*max(abs(expected(finite))));
        report.checks=report.checks+1; report.maxAbsoluteError=max(report.maxAbsoluteError,err);
    end
end
