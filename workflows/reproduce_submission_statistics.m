function receipt=reproduce_submission_statistics(outputRoot,phase,networkIDs)
    % Independently reproduce frozen paired tests and complete trial-shuffle nulls.
    root=fileparts(fileparts(mfilename('fullpath')));
    if nargin<1,outputRoot=fullfile(root,'generated/submission_statistics');end
    if nargin<2,phase='all';end
    if nargin<3,networkIDs=1:10;end
    assert(ismember(phase,{'all','compute','validate'}));
    assert(numel(unique(networkIDs))==numel(networkIDs)&&all(ismember(networkIDs,1:10)));
    if ~strcmp(phase,'compute'),assert(isequal(networkIDs,1:10));end
    restoredefaultpath;addpath(fullfile(root,'analysis/paper_ready/final_v3/production'));
    code=fullfile(root,'analysis/paper_ready/final_v3/submission_statistics');addpath(code);
    source=fullfile(root,'data/paper_ready/final_v3/submission_statistics_20261021');
    manifest=jsondecode(fileread(fullfile(source,'source_manifest.json')));
    for j=1:numel(manifest.files)
        r=manifest.files(j);assert(strcmp(sha256(fullfile(root,r.path)),r.sha256), ...
            'Submission:SourceHash','Changed committed input/source: %s',r.path);
    end
    if ~isfolder(outputRoot),mkdir(outputRoot);end
    if ismember(phase,{'all','compute'})
        submission_null_network(root,fullfile(source,'inputs'),fullfile(outputRoot,'null'),networkIDs,2000);
    end
    receipt=struct('status','COMPUTATION_ONLY','networkIDs',networkIDs,'sourceHashesVerified',numel(manifest.files));
    if strcmp(phase,'compute'),return;end
    for n=1:10
        file=sprintf('null_network_%02d.mat',n);a=load(fullfile(source,'null',file));b=load(fullfile(outputRoot,'null',file));
        assert(isequaln(a.results,b.results),'Submission:NullMismatch', ...
            'Full shuffle statistics, loss grids or permutations differ for network %d',n);
    end
    paired=submission_stats(root,fullfile(outputRoot,'paired'));
    original=load(fullfile(source,'paired/paired_statistics.mat'),'out');
    assert(isequaln(paired,original.out),'Submission:PairedMismatch','Paired source statistics differ.');
    null=submission_null_summaries(root,fullfile(outputRoot,'null'),fullfile(outputRoot,'summary'));
    original=load(fullfile(source,'summary/null_summary.mat'),'report');
    assert(strcmp(null.status,'PASS')&&isequaln(null,original.report), ...
        'Submission:SummaryMismatch','Null summary or precision check differs.');
    exactTables=0;
    for group={'paired','summary'}
        listing=dir(fullfile(source,group{1},'*'));
        for j=1:numel(listing)
            [~,~,extension]=fileparts(listing(j).name);
            if ismember(extension,{'.csv','.json'})
                assert(strcmp(sha256(fullfile(source,group{1},listing(j).name)), ...
                    sha256(fullfile(outputRoot,group{1},listing(j).name))), ...
                    'Submission:TableMismatch','Committed source table differs: %s',listing(j).name);
                exactTables=exactTables+1;
            end
        end
    end
    export_null_audit(root,fullfile(outputRoot,'null'),fullfile(outputRoot,'independent_audit'));
    files=dir(fullfile(code,'*.m'));issues=cell(numel(files)+1,1);
    for j=1:numel(files)
        file=fullfile(files(j).folder,files(j).name);issues{j}=checkcode(file,'-id');
        assert(isempty(issues{j}),'Submission:CodeAnalyzer','Check %s',file);
        body=fileread(file);assert(isempty(regexp(body,'[A-Z]:[/\\]|genpath|local_explorations','once')));
    end
    issues{end}=checkcode(mfilename('fullpath'),'-id');assert(isempty(issues{end}));
    [mfiles,mexfiles]=inmem('-completenames');loaded=[mfiles(:);mexfiles(:)];
    assert(all(startsWith(loaded,root)|startsWith(loaded,matlabroot)), ...
        'Submission:Dependency','Code outside checkout or MATLAB installation');
    receipt=struct('status','PASS','distinctCases',230,'permutationsPerCase',2000,'totalNestedNullFits',460000, ...
        'allOriginalUnshuffledExact',true,'allFullNullOutputsExact',true,'pairedStatisticsExact',true, ...
        'threeSummariesAndPrecisionExact',true,'exactSourceTables',exactTables,'sourceHashesVerified',numel(manifest.files), ...
        'codeAnalyzerIssues',{issues},'loadedCode',{loaded},'matlab',version,'toolboxes',ver,'noNeuralSimulations',true);
    pf_json(fullfile(outputRoot,'validation.json'),receipt);
    fprintf('SUBMISSION STATISTICS PASS: eight paired tests, 460000 nested null fits, three precision-verified summaries.\n');
end

function hex=sha256(file)
    fid=fopen(file,'rb');assert(fid>=0);guard=onCleanup(@()fclose(fid));md=java.security.MessageDigest.getInstance('SHA-256');
    while ~feof(fid),data=fread(fid,8*1024*1024,'*uint8');md.update(data);end
    hex=upper(reshape(dec2hex(typecast(md.digest(),'uint8'),2).',1,[]));
end
