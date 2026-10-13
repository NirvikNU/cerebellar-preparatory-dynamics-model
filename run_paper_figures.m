function receipt=run_paper_figures(outputRoot)
    % Regenerate eleven publication panels (including static Fig6c) and two assemblies.
    root=fileparts(mfilename('fullpath'));
    if nargin<1, outputRoot=fullfile(root,'generated/paper_figures'); end
    old=path; cleaner=onCleanup(@()path(old));
    addpath(fullfile(root,'analysis/paper_ready/final_v3/production'));
    receipt=pf_figures(root,outputRoot);
end
