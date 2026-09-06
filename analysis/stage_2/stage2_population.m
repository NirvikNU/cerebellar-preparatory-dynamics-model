function out = stage2_population(rates, cfg, member)
    % rates: time (-500 through frozen movement samples) x neuron x target x lambda.
    fullIdx = cfg.fullReferenceMs+cfg.preparationMs+1;
    reference = rates(fullIdx,:,:,1);
    out.scale = max(std(stage2_matrix(reference),0,1),cfg.floor);
    scaled = rates ./ reshape(out.scale,1,[],1,1);
    centered = scaled-mean(scaled,3);
    prepIdx = cfg.prepEpochMs+cfg.preparationMs+1;
    moveIdx = cfg.moveEpochMs+cfg.preparationMs+1;
    out.pr = zeros(8,2);
    out.captured15 = zeros(8,2);
    bases = cell(8,2);
    covariances = cell(8,2);
    out.svdPRError = 0;
    out.svdCapturedError = 0;
    for l = 1:8
        for epoch = 1:2
            if epoch==1, rows=prepIdx; else, rows=moveIdx; end
            X = stage2_matrix(centered(rows,:,:,l));
            C = (X.'*X)/(size(X,1)-1);
            [V,d] = eig((C+C.')/2,'vector');
            [d,order] = sort(max(d,0),'descend');
            bases{l,epoch} = V(:,order(1:cfg.pcCount));
            covariances{l,epoch} = C;
            out.pr(l,epoch) = sum(d)^2/sum(d.^2);
            out.captured15(l,epoch) = sum(d(1:cfg.pcCount))/sum(d);
            sv = svd(X,'econ').^2/(size(X,1)-1);
            out.svdPRError = max(out.svdPRError,abs(out.pr(l,epoch)-sum(sv)^2/sum(sv.^2)));
            out.svdCapturedError = max(out.svdCapturedError, ...
                abs(out.captured15(l,epoch)-sum(sv(1:cfg.pcCount))/sum(sv)));
        end
    end
    Cref = covariances{1,1};
    Uref = bases{1,1};
    denominator = trace(Uref.'*Cref*Uref);
    Xref = stage2_matrix(centered(prepIdx,:,:,1));
    directDen = norm(Xref*Uref,'fro')^2;
    out.observed = zeros(1,8);
    out.directAlignmentError = 0;
    for l = 1:8
        U = bases{l,1};
        out.observed(l) = trace(U.'*Cref*U)/denominator;
        out.directAlignmentError = max(out.directAlignmentError, ...
            abs(out.observed(l)-norm(Xref*U,'fro')^2/directDen));
    end
    U = bases{1,2};
    out.prepMove = trace(U.'*Cref*U)/denominator;
    out.directAlignmentError = max(out.directAlignmentError, ...
        abs(out.prepMove-norm(Xref*U,'fro')^2/directDen));
    Xfull = stage2_matrix(centered(fullIdx,:,:,1));
    Cfull = Xfull.'*Xfull/(size(Xfull,1)-1);
    out.null = stage2_null(Cfull,Cref,denominator,cfg.pcCount,cfg.nullDraws, ...
        cfg.nullSeedBase+member);
    out.expected = mean(out.null);
    assert(abs(out.observed(1)-1)<1e-10 && out.svdPRError<1e-8);
    assert(out.directAlignmentError<1e-10 && out.svdCapturedError<1e-10);
end
