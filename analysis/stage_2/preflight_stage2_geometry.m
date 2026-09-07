function report = preflight_stage2_geometry(root)
    % Read-only cache audit; no controller simulation or replacement SDs.
    if nargin<1, root=fileparts(fileparts(fileparts(mfilename('fullpath')))); end
    addpath(fullfile(root,'analysis','published_generator'));
    base=fullfile(root,'results','stage_2','current');
    manifest=readtable(fullfile(base,'cache_manifest.csv'),'TextType','string');
    report=struct('task','STAGE2-LAMBDA-SWEEP-01-R2','status','AUDITING', ...
        'onsetMs',zeros(10,8,8),'peakSpeedMps',zeros(10,8,8), ...
        'referenceSD',zeros(10,200),'degeneracyTolerance',zeros(10,200), ...
        'windowMinGO',zeros(10,8,8),'windowMaxGO',zeros(10,8,8), ...
        'cacheHashesMatched',false(10,1));
    for member=1:10
        file=fullfile(base,'cache',sprintf('network_%02d.mat',member));
        report.cacheHashesMatched(member)=sha256_file(file)==manifest.SHA256(member);
        assert(report.cacheHashesMatched(member),'Cache hash mismatch.');
        saved=load(file,'net'); net=saved.net;
        assert(isequal(size(net.rates),[1099 200 8 8]));
        reference=zeros(102,200,8);
        for l=1:8
            hand=net.hand{l};
            assert(isequal(size(hand),[600 4 8]) && all(isfinite(hand),'all'));
            for target=1:8
                speed=hypot(hand(:,2,target),hand(:,4,target));
                peak=max(speed); assert(isfinite(peak) && peak>0);
                crossing=find(speed>=0.2*peak,1);
                assert(crossing>1 && speed(crossing-1)<0.2*peak);
                onset=crossing-1;
                report.onsetMs(member,target,l)=onset;
                report.peakSpeedMps(member,target,l)=peak;
                times=[-500:10:0 onset+(-50:10:450) -100:10:0 ...
                    -350:10:-50 onset+(-50:10:350)];
                report.windowMinGO(member,target,l)=min(times);
                report.windowMaxGO(member,target,l)=max(times);
                if l==1
                    idx=[-500:10:0 onset+(-50:10:450)]+501;
                    assert(all(idx>=1 & idx<=size(net.rates,1)),'Missing reference window.');
                    reference(:,:,target)=net.rates(idx,:,target,1);
                end
            end
        end
        X=stage2_matrix(reference);
        report.referenceSD(member,:)=std(X,0,1);
        report.degeneracyTolerance(member,:)=100*eps(max(1,max(abs(X),[],1)));
    end
    report.degenerate=~isfinite(report.referenceSD) | ...
        report.referenceSD<=report.degeneracyTolerance;
    report.allWindowsPresent=all(report.windowMinGO>=-500,'all') && ...
        all(report.windowMaxGO<=598,'all');
    report.rejectedNeuronCount=sum(report.degenerate,2);
    report.status='PASS';
    if any(report.degenerate,'all') || ~report.allWindowsPresent
        report.status='STOP: prerequisite failed; no population analysis run';
    end
    output=fullfile(base,'neural_geometry_r2');
    if ~isfolder(output), mkdir(output); end
    path=fullfile(output,'cache_preflight.json');
    assert(~isfile(path),'Preflight receipt already exists; inspect before rerunning.');
    fid=fopen(path,'w'); assert(fid>0); cleanup=onCleanup(@()fclose(fid));
    fprintf(fid,'%s\n',jsonencode(report,PrettyPrint=true));
    fprintf('R2 cache preflight: %s\n',report.status);
    fprintf('MO range: %g to %g ms; max requested GO time: %g ms\n', ...
        min(report.onsetMs,[],'all'),max(report.onsetMs,[],'all'),max(report.windowMaxGO,[],'all'));
    fprintf('Reference SD range: %.17g to %.17g; rejected counts:\n', ...
        min(report.referenceSD,[],'all'),max(report.referenceSD,[],'all'));
    disp(report.rejectedNeuronCount.');
    assert(~any(report.degenerate,'all'),'R2 requires stopping for zero/degenerate SD.');
    assert(report.allWindowsPresent,'R2 requires reporting missing saved windows.');
end
