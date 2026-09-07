function output = stage3_statistics(pr, ai, early, indices)
    output.pr=stage2_bootstrap(pr,indices); output.alignment=stage2_bootstrap(ai,indices);
    output.earlyErrorMM=stage2_bootstrap(early,indices);
    output.prTest=stage2_signflip(pr(:,2)-pr(:,1),indices);
    output.alignmentTest=stage2_signflip(ai(:,1)-ai(:,2),indices);
    output.earlyTest=stage2_signflip(early(:,2)-early(:,1),indices);
    output.geometryQ=stage2_bh([output.prTest.p,output.alignmentTest.p]);
    output.family='PR Block-Intact and AI Observed-Expected; early movement separate';
    output.independentN=10; output.bootstrapDraws=size(indices,1);
end
