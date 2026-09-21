function receipt = paper95_source_data(root)
    % Compact panel provenance from saved numerical outputs only.
    dest=fullfile(root,'results','paper_ready','alignment95');
    s=load(fullfile(root,'results','stage_2','current','neural_geometry_r2','analysis.mat'),'out'); stage2=s.out;
    assert(~isfile(fullfile(dest,'stage2_panels_ab.mat')));
    save(fullfile(dest,'stage2_panels_ab.mat'),'stage2');
    rows=cell(80,1); row=0;
    for n=1:10
        for k=1:8
            row=row+1;
            rows{row}=table(n,stage2.cfg.lambda(k),stage2.pr(n,k),stage2.observed(n,k),stage2.expected(n,k), ...
                'VariableNames',{'network','lambda','PR','observed','expected'});
        end
    end
    writetable(vertcat(rows{:}),fullfile(dest,'stage2_panels_ab.csv'));
    s=load(fullfile(dest,'controls.mat'),'result'); controls=s.result;
    rows=cell(40,1); row=0;
    for n=1:10
        for p=1:4
            row=row+1;
            rows{row}=array2table([n p reshape(controls.policy(n,p,:),1,10) reshape(controls.reliability(n,p,:),1,6)], ...
                'VariableNames',{'network','policy','PR','observed','expected','deficit','normalizedResidualVariance', ...
                'meanEndpointRmsMM','medianMOms','medianPeakMs','medianPeakMps','separationToScatter', ...
                'half1PR','half2PR','half1CaptureControlK','half2CaptureControlK','half1OntoHalf2','halfNull'});
        end
    end
    writetable(vertcat(rows{:}),fullfile(dest,'policy_source.csv'));
    receipt=struct('stage2Source','results/stage_2/current/neural_geometry_r2/analysis.mat', ...
        'stage2NumericalChanges',false,'stage2CopyVerified',false,'predictionRun',false);
    s=load(fullfile(dest,'stage2_panels_ab.mat'),'stage2'); assert(isequaln(s.stage2,stage2));
    receipt.stage2CopyVerified=true;
    paper_json(fullfile(dest,'SOURCE_DATA.json'),receipt);
end
