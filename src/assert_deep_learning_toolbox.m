function assert_deep_learning_toolbox()
    hasDlarray = ~isempty(which('dlarray'));
    hasDlgradient = ~isempty(which('dlgradient'));

    if ~(hasDlarray && hasDlgradient)
        error('IntactModel:MissingDeepLearningToolbox', ...
            ['Deep Learning Toolbox is required for the custom training ', ...
            'loop, but dlarray or dlgradient is unavailable.']);
    end
end
