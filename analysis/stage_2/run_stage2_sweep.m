function run_stage2_sweep(cfg)
    if isfolder(cfg.cacheRoot)
        prior=dir(fullfile(cfg.cacheRoot,'network_*.mat'));
        assert(isempty(prior),'Existing network caches: inspect and preserve; do not overwrite.');
        assert(~isfile(fullfile(cfg.resultsRoot,'simulation_audit.json')));
    else
        mkdir(cfg.cacheRoot);
    end
    configHash = sha256_file(fullfile(cfg.projectRoot,'config','stage_2_config.m'));
    preregHash = sha256_file(fullfile(cfg.projectRoot,'artifacts','manifests', ...
        'stage2_lambda_sweep','PREREGISTRATION.md'));
    write_json(fullfile(cfg.resultsRoot,'configuration.json'),cfg);
    protectedRoots = ["results/stage_1" "plots/stage_1" "src/published_generator" ...
        "analysis/published_generator" "figures/published_generator" ...
        "config/published_generator_config.m" "config/stage_1_gate1_config.m" ...
        "config/require_kao_reference.m" "figures/apply_plot_style.m" "figures/save_figure_bundle.m"];
    before = hash_tree(cfg.projectRoot,protectedRoots);
    before = before(~endsWith(lower(before.relative_path),'desktop.ini'),:);
    baselinePath=fullfile(cfg.resultsRoot,'protected_before.csv');
    if isfile(baselinePath)
        original=readtable(baselinePath,'TextType','string');
        assert(isequal(before,original),'Protected baseline differs from previous attempt.');
    else
        writetable(before,baselinePath);
    end
    tests = test_stage2(cfg);
    write_json(fullfile(cfg.resultsRoot,'preflight_tests.json'),tests);
    perturbStream = RandStream('mt19937ar','Seed',cfg.perturbationSeed);
    startedUTC = char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd HH:mm:ss'));
    for member = 1:10
        s = load(fullfile(cfg.ensembleRoot,sprintf('network_%02d.mat',member)),'model');
        model = s.model;
        assert(model.dt==cfg.dt && model.tau==cfg.tau && model.samplingDt==cfg.savedDt);
        net = struct('member',member,'configHash',configHash,'preregHash',preregHash);
        net.movementSavedSamples = model.nSamples;
        net.rates = zeros(cfg.preparationMs+model.nSamples,200,8,8);
        net.sourceCost = zeros(501,8,8);
        net.stateCost = zeros(501,8,8);
        net.effort = zeros(1,8);
        net.controller = cell(1,8);
        net.hand = cell(1,8);
        net.demoHand = cell(1,4);
        for l = 1:8
            ctl = stage2_controller(model,cfg.lambda(l));
            prep = stage2_prepare(model,ctl,cfg);
            move = simulate_published_cortex(model,squeeze(prep.states(end,:,:)),true);
            [~,hand] = simulate_published_arm(model,move.torque);
            assert(all(isfinite(move.rates),'all') && all(isfinite(hand),'all'));
            net.rates(:,:,:,l) = cat(1,prep.rates(1:500,:,:),move.rates);
            net.sourceCost(:,:,l) = prep.sourceCost;
            net.stateCost(:,:,l) = prep.stateCost;
            net.effort(l) = prep.effort;
            net.controller{l} = ctl;
            net.hand{l} = hand;
            if l==1
                if member==1
                    for d = 1:4
                        release = squeeze(prep.states(cfg.demoMs(d)+1,:,:));
                        demonstration = simulate_published_cortex(model,release,false);
                        [~,net.demoHand{d}] = simulate_published_arm(model,demonstration.torque);
                        assert(all(isfinite(net.demoHand{d}),'all'));
                    end
                    net.targetHand = model.targetHand;
                end
                net.perturbation = stage2_perturb(model,ctl,cfg,perturbStream);
            end
        end
        save(fullfile(cfg.cacheRoot,sprintf('network_%02d.mat',member)),'net','-v7.3');
        fprintf('Completed network %02d: all eight lambda conditions and fixed perturbation protocol.\n',member);
    end
    after = hash_tree(cfg.projectRoot,protectedRoots);
    after = after(~endsWith(lower(after.relative_path),'desktop.ini'),:);
    assert(isequal(before,after),'Protected Stage-1 hashes changed.');
    writetable(after,fullfile(cfg.resultsRoot,'protected_after.csv'));
    assert(configHash==sha256_file(fullfile(cfg.projectRoot,'config','stage_2_config.m')));
    audit = struct('status','PASS','startedUTC',startedUTC,'completedUTC', ...
        char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd HH:mm:ss')), ...
        'networks',10,'lambdaConditions',8,'targetConditions',640, ...
        'perturbationTrials',8000,'protectedFilesUnchanged',height(before), ...
        'configHash',configHash,'preregHash',preregHash,'finiteTrajectories',true);
    write_json(fullfile(cfg.resultsRoot,'simulation_audit.json'),audit);
end

function write_json(path,value)
    fid=fopen(path,'w'); assert(fid>0); clean=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',jsonencode(value,PrettyPrint=true));
end
