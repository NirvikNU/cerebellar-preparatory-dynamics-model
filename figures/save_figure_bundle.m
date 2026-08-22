function files = save_figure_bundle(figureHandle, basePath, params)
    outputDirectory = fileparts(basePath);
    if ~isfolder(outputDirectory)
        mkdir(outputDirectory);
    end
    figFile = [basePath, '.fig'];
    pngFile = [basePath, '.png'];
    savefig(figureHandle, figFile);
    exportgraphics(figureHandle, pngFile, ...
        'Resolution', params.plot.resolution, 'BackgroundColor', 'white');
    files = {figFile, pngFile};
    close(figureHandle);
end
