function value = published_movement_input(time, model)
    rise = model.movTauRise;
    decay = model.movTauDecay;
    peakTime = log(decay / rise) * decay * rise / (decay - rise);
    bump = @(t) exp(-t / decay) - exp(-t / rise);
    value = model.movAmplitude / bump(peakTime) * bump(time);
end
