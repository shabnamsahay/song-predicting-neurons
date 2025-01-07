function visualize_corr_mat(corr_mat, f_path, f_title, epoch_lab)

    fig = figure;

    h = heatmap(corr_mat, 'Title', f_title, 'XLabel',epoch_lab, 'YLabel',epoch_lab, ...
                'CellLabelColor','none', 'ColorLimits',[-1 1]);
    
    colormap(h, "parula")

    hs = struct(h);

    hs.Colorbar.Ticks = [-1, 0, 1];
    hs.Colorbar.TickLabels = {'-1', '0', '1'};
    ylabel(hs.Colorbar, "Correlation");

    saveas(fig, f_path)
    close(fig);
end