clear;
projectRoot = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(genpath(projectRoot));
files = {
    fullfile(projectRoot, 'analysis', 'stage_2b_shared', ...
        'analyze_gate2_active_set_diagnostics.m');
    fullfile(projectRoot, 'figures', 'stage_2b_shared', ...
        'create_gate2_active_set_figures.m');
    mfilename('fullpath')};
for index = 1:numel(files)
    messages = checkcode(files{index}, '-id');
    assert(isempty(messages), 'Code Analyzer reported an issue in %s.', ...
        files{index});
end
report = analyze_gate2_active_set_diagnostics(projectRoot);
disp(report.summary);
fprintf(['GATE 2 ACTIVE-SET DIAGNOSTICS PASS: %d networks, %d targets, ' ...
    '%d diagnostic figures.\n'], report.summary.networkCount, ...
    report.summary.targetCount, report.summary.figureCount);
