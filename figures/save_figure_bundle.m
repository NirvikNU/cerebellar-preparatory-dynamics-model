function [figFile, pngFile] = save_figure_bundle(figureHandle, name, params)
    if ~isfolder(params.plotsFigRoot)
        mkdir(params.plotsFigRoot);
    end
    if ~isfolder(params.plotsPngRoot)
        mkdir(params.plotsPngRoot);
    end
    figFile = fullfile(params.plotsFigRoot, [name, '.fig']);
    pngFile = fullfile(params.plotsPngRoot, [name, '.png']);
    savefig(figureHandle, figFile);
    exportgraphics(figureHandle, pngFile, ...
        'Resolution', params.plot.resolution, 'BackgroundColor', 'white');
    close(figureHandle);
end
