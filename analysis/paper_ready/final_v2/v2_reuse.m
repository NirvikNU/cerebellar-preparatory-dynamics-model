function reused=v2_reuse(selection,p)
    % Intact eta=0 field cancels xB exactly. Full Block only if xB is unchanged.
    reused=p==1 || (p==4 && selection.alpha==.5 && selection.betaNormalized==1);
end
