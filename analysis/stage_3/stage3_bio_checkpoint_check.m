function receipt = stage3_bio_checkpoint_check
    % Bounded, read-only current-result/figure check. Never dispatch science.
    cfg=stage3_bio_paths;
    a=jsondecode(fileread(fullfile(cfg.bioRoot,'independent_audit.json')));
    b=jsondecode(fileread(fullfile(cfg.bioRoot,'preparation_complete.json')));
    c=jsondecode(fileread(fullfile(cfg.bioRoot,'map_complete.json')));
    assert(strcmp(a.status,'PASS') && strcmp(b.status,'PASS') && c.primaryPass);
    s=load(fullfile(cfg.bioRoot,'population.mat'),'result'); pop=s.result;
    s=load(fullfile(cfg.bioRoot,'movement.mat'),'result'); move=s.result;
    assert(pop.primaryPass && move.nontrivialMovement && numel(pop.late)==10);
    assert(all(isnan(pop.pr(:,:,1:11)),'all') && all(isfinite(pop.pr(:,:,12:end)),'all'));
    assert(all(pop.K(:,4,end)==7));
    files={'result_1_preparation_and_movement','result_2_preparatory_geometry', ...
        'diagnostic_1_feasible_solution_map','diagnostic_2_component_removal'};
    for j=1:4
        f=openfig(fullfile(cfg.plotsFigRoot,[files{j} '.fig']),'invisible');
        assert(strcmp(f.UserData.task,'STAGE3-BIOLOGICAL-CONTROLLER-RESUME-02') && f.UserData.figureIndex==j);
        if j==2
            legends=findall(f,'Type','legend');
            assert(any(arrayfun(@(h)isequal(h.String,{'Intact','Block'}),legends)));
        elseif j==4
            legends=findall(f,'Type','legend');
            assert(any(arrayfun(@(h)isequal(h.String,cfg.policyNames),legends)));
            axesHandles=findall(f,'Type','axes');
            timeAxes=axesHandles(arrayfun(@(ax)isequal(ax.XLim,[-600 0]),axesHandles));
            assert(numel(timeAxes)==5);
        end
        close(f); info=imfinfo(fullfile(cfg.plotsPngRoot,[files{j} '.png'])); assert(info.Width>1000);
    end
    receipt=struct('status','PASS','figuresReopened',4,'nativePNGFiles',4,'scientificAcceptance','Pending user review');
end
