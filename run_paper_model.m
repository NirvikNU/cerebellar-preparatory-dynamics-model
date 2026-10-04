function receipt=run_paper_model(mode,outputRoot)
    % Frozen-model replay only. Never selects or tunes a parameter.
    if nargin<1, mode='check'; end
    root=fileparts(mfilename('fullpath'));
    if nargin<2, outputRoot=fullfile(root,'generated/paper_model',mode); end
    old=path; cleaner=onCleanup(@()path(old));
    addpath(fullfile(root,'analysis/paper_ready/final_v3/production'),fullfile(root,'src/published_generator'));
    switch mode
        case {'check','stochastic'}, receipt=pf_model(root,mode,outputRoot);
        case 'lambda', receipt=pf_replay_lambda(root,outputRoot);
        case 'geometry', receipt=pf_replay_geometry(root,outputRoot);
        case 'illustrations', receipt=pf_replay_illustrations(root,outputRoot);
        case 'all'
            receipt=struct();
            receipt.lambda=pf_replay_lambda(root,fullfile(outputRoot,'lambda'));
            receipt.geometry=pf_replay_geometry(root,fullfile(outputRoot,'geometry'));
            receipt.stochastic=pf_model(root,'stochastic',fullfile(outputRoot,'stochastic'));
            receipt.illustrations=pf_replay_illustrations(root,fullfile(outputRoot,'illustrations'));
            receipt.status='PASS'; pf_json(fullfile(outputRoot,'validation.json'),receipt);
        otherwise, error('Unknown reproduction mode.');
    end
end
