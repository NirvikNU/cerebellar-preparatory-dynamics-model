function output = simulate_stage2a_movements(model, goStates, storeRates)
    if nargin < 3
        storeRates = false;
    end
    cortex = simulate_published_cortex(model, goStates, storeRates);
    [theta, hand] = simulate_published_arm(model, cortex.torque);
    output.cortex = cortex;
    output.theta = theta;
    output.hand = hand;
end
