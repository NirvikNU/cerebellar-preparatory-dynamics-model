function receipt=pf_replay_illustrations(root,outputRoot)
    % Replay only frozen displayed/inset IDs. No success search or reselection.
    source=fullfile(root,'data/paper_ready/final_v3'); z=load(fullfile(source,'network_08.mat'));
    s=load(fullfile(source,'illustration_constants.mat'));
    cfg=struct('seedBase',610000000,'seedConditionStride',1000000,'seedTargetStride',10000, ...
        'flags',[1 1;0 0],'targetXY',s.targetXY,'targetRadius',.015,'policy',[1 4]);
    d=readmatrix(fullfile(source,'tables/Fig6d_selected_trials.csv'));
    paths=readmatrix(fullfile(source,'tables/Fig6d_displayed_native_paths.csv'));
    inset=readmatrix(fullfile(source,'tables/Fig6f_all30_inset.csv'));
    if ~isfolder(outputRoot), mkdir(outputRoot); end
    receipt=struct('status','RUNNING','maxPathError',0,'maxPeakError',0,'trials',0,'selectionPerformed',false);
    for p=1:2
        for q=1:8
            ids=d(d(:,4)==p & d(:,5)==q,8).';
            if q==6, ids=unique([ids inset(inset(:,3)==p,5).'],'stable'); end
            raw=pf_visualization_replay(z.model,z.controller,z.definition,cfg,p,q,ids);
            assert(all(raw.success));
            for j=1:numel(ids)
                xy=raw.hand(:,[1 3],j)-raw.hand(1,[1 3],j);
                saved=paths(paths(:,2)==p & paths(:,3)==q & paths(:,4)==ids(j),:);
                if ~isempty(saved)
                    last=raw.entryMs(j)+1;
                    assert(size(saved,1)==last && isequal(saved(:,5),(0:last-1).'));
                    receipt.maxPathError=max(receipt.maxPathError,max(abs(saved(:,6:7)-xy(1:last,:)),[],'all'));
                end
                if q==6
                    row=inset(inset(:,3)==p & inset(:,5)==ids(j),:);
                    if ~isempty(row)
                        [peak,ix]=max(raw.speed(1:raw.entryMs(j)+1,j));
                        xy=100*(raw.hand(ix,[1 3],j)-raw.hand(1,[1 3],j));
                        receipt.maxPeakError=max([receipt.maxPeakError abs(peak-row(8)) max(abs(xy-row(9:10)))]);
                    end
                end
            end
            assert(receipt.maxPathError<1e-10 && receipt.maxPeakError<1e-9,'Frozen illustrative source mismatch; stop without reselection.');
            file=fullfile(outputRoot,sprintf('illustration_policy%d_target%d.mat',p,q)); assert(~isfile(file)); save(file,'raw','-v7');
            receipt.trials=receipt.trials+numel(ids);
        end
    end
    receipt.status='PASS'; pf_json(fullfile(outputRoot,'validation.json'),receipt);
end
