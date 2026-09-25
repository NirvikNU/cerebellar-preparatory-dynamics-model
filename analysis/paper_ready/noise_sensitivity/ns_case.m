function result=ns_case(n,prep,move,scale,equilibrium,bounds,prior,grid)
    bounded=prep.rateMax<=bounds(1) && prep.stateMax<=bounds(2) && max(prep.componentMax)<=bounds(3);
    finite=all(isfinite(prep.states),'all') && all(isfinite(move.states),'all') && ...
        all(isfinite(move.hand),'all') && all(isfinite(move.theta),'all') && all(isfinite(prep.componentMax));
    if isempty(prior)
        assayMove=move;
        if ~bounded || ~finite, assayMove.missingWindow(:)=true; end
        result=eta_case(n,prep,assayMove,scale,equilibrium,[]); result.anchor=false;
    else
        result=prior; result.anchor=true;
    end
    result.bounds=bounds; result.scale=scale;
    result.evaluable=bounded && finite; result.predictionEvaluable=result.evaluable && ~any(move.missingWindow|move.nearZero);
    if result.predictionEvaluable, result.prediction=ns_controls(result.prediction,n,grid); end
    result.qc=struct('finite',finite,'prepBounds',bounded,'prepRateMax',prep.rateMax,'prepStateMax',prep.stateMax, ...
        'prepInputMax',max(prep.componentMax),'movementRateMax',move.rateMax,'movementStateMax',move.stateMax, ...
        'nearZero',sum(move.nearZero),'missingWindow',sum(move.missingWindow),'boundaryPeak',sum(move.boundaryPeak), ...
        'multiPeak',sum(move.multiPeakCount>=2),'allTrialsRetained',true);
    result.movement=rmfield(move,intersect(fieldnames(move),{'states','audit','go','finalState','torque','theta','hand','speed'}));
end
