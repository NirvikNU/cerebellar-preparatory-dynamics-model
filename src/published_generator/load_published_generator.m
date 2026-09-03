function model = load_published_generator(cfg)
    required = {'w_rec.tsv','spontaneous.tsv','baseline_drive_h.tsv', ...
        'xstars.tsv','c_full.tsv','c_readout_excitatory.tsv','gamma.tsv', ...
        'a_movement.tsv','prospective_q.tsv','native_metadata.tsv'};
    for index = 1:numel(required)
        path = fullfile(cfg.dataRoot, required{index});
        assert(isfile(path), 'Missing published artifact: %s', path);
    end
    model.W = readmatrix(fullfile(cfg.dataRoot, 'w_rec.tsv'), 'FileType', 'text');
    model.spontaneous = readmatrix(fullfile(cfg.dataRoot, 'spontaneous.tsv'), 'FileType', 'text');
    model.h = readmatrix(fullfile(cfg.dataRoot, 'baseline_drive_h.tsv'), 'FileType', 'text');
    model.xstar = readmatrix(fullfile(cfg.dataRoot, 'xstars.tsv'), 'FileType', 'text');
    model.C = readmatrix(fullfile(cfg.dataRoot, 'c_full.tsv'), 'FileType', 'text');
    model.Ce = readmatrix(fullfile(cfg.dataRoot, 'c_readout_excitatory.tsv'), 'FileType', 'text');
    model.gamma = readmatrix(fullfile(cfg.dataRoot, 'gamma.tsv'), 'FileType', 'text');
    model.A = readmatrix(fullfile(cfg.dataRoot, 'a_movement.tsv'), 'FileType', 'text');
    model.Qnative = readmatrix(fullfile(cfg.dataRoot, 'prospective_q.tsv'), 'FileType', 'text');
    metadata = readcell(fullfile(cfg.dataRoot, 'native_metadata.tsv'), ...
        'FileType', 'text', 'Delimiter', '\t');
    for row = 2:size(metadata, 1)
        key = matlab.lang.makeValidName(string(metadata{row, 1}));
        raw = string(metadata{row, 2});
        value = str2double(raw);
        if isnan(value)
            model.metadata.(key) = char(raw);
        else
            model.metadata.(key) = value;
        end
    end
    model.n = model.metadata.n;
    model.nE = model.metadata.n_e;
    model.nI = model.metadata.n_i;
    model.nMovements = model.metadata.n_movements;
    model.dt = model.metadata.dt_s;
    model.samplingDt = model.metadata.sampling_dt_s;
    model.tau = model.metadata.tau_s;
    model.nInternalSteps = model.metadata.n_internal_steps;
    model.nSamples = model.metadata.n_saved_samples;
    model.movTauRise = model.metadata.movement_input_tau_rise_s;
    model.movTauDecay = model.metadata.movement_input_tau_decay_s;
    model.movAmplitude = model.metadata.movement_input_amplitude;
    model.arm = struct('L1', model.metadata.arm_L1_m, ...
        'L2', model.metadata.arm_L2_m, 'I1', model.metadata.arm_I1, ...
        'I2', model.metadata.arm_I2, 'M1', model.metadata.arm_M1_kg, ...
        'M2', model.metadata.arm_M2_kg, ...
        'B', [model.metadata.arm_B11, model.metadata.arm_B12; ...
              model.metadata.arm_B21, model.metadata.arm_B22], ...
        'S1', model.metadata.arm_S1_m, 'S2', model.metadata.arm_S2_m, ...
        'theta1', model.metadata.arm_initial_theta1_rad);
    allValues = [model.W(:); model.spontaneous(:); model.h(:); ...
        model.xstar(:); model.C(:); model.A(:)];
    assert(all(isfinite(allValues)), 'Imported published model is nonfinite.');
    assert(isequal(size(model.W), [200, 200]));
    assert(isequal(size(model.xstar), [200, 8]));
    assert(isequal(size(model.C), [2, 200]));
    assert(norm(model.A - (model.W - eye(model.n)), 'fro') < 1e-12);
end
