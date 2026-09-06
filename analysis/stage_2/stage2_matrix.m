function X = stage2_matrix(rates)
    % Input time x neuron x target. Each output column is ONE neuron.
    X = reshape(permute(rates,[1 3 2]),[],size(rates,2));
end
