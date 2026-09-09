function receipt = stage3_gain_time_compact(cfg)
    % Cache-only export organization; preserve the full audit-bearing MAT.
    file=fullfile(cfg.resultsRoot,'gain_time','gain_time.mat');
    backup=fullfile(cfg.cacheRoot,'gain_time','gain_time_with_checks.mat');
    assert(~isfile(backup),'Compaction already completed.');
    s=load(file,'result'); original=s.result; assert(strcmp(original.status,'PASS'));
    audit=jsondecode(fileread(fullfile(cfg.manifestRoot,'GAIN_TIME_AUDIT.json')));
    assert(numel(audit.checks)==numel(original.checks));
    result=rmfield(original,'checks');
    originalHash=sha256_file(file);
    [ok,message]=movefile(file,backup); assert(ok,'%s',message);
    assert(strcmp(originalHash,sha256_file(backup)));
    save(file,'result','-v7');
    saved=load(file,'result'); assert(isequaln(result,saved.result));
    receipt=struct('status','PASS','metricsUnchanged',true,'checksInJSON',numel(audit.checks), ...
        'retainedFullMAT',backup,'retainedSHA256',originalHash,'compactMAT',file, ...
        'compactSHA256',sha256_file(file));
    stage3_write_json(fullfile(cfg.manifestRoot,'GAIN_TIME_COMPACT_EXPORT.json'),receipt);
end
