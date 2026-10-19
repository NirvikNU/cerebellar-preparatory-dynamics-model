function spec=pf_noise_grid
    % Prespecified Fig6g,h one-at-a-time grid; primary illustration noise stays .10/.10.
    spec.levels=[.05 .10 .15 .20 .25 .30 .35 .40];
    spec.fixedOtherNoise=.05;
    spec.pairs=[spec.levels(:) .05*ones(8,1);.05*ones(7,1) spec.levels(2:end).'];
    spec.pairIndex=[(1:8).' [1 9:15].'];
    spec.policies=[1 4];spec.networks=1:10;spec.trialsPerCase=240;
    spec.primaryNoise=[.1 .1];
    assert(size(unique(spec.pairs,'rows'),1)==15&&spec.pairIndex(1,1)==spec.pairIndex(1,2));
end
