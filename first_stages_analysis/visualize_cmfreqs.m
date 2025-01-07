function f = visualize_cmfreqs(s_corr_mat, ns_corr_mat, f_path)

    s_corr_vals = get_upper_tri_vals(s_corr_mat);
    ns_corr_vals = get_upper_tri_vals(ns_corr_mat);

    fig = figure;
    hold on
    
    c1 = cdfplot(s_corr_vals, 'r');
    set(c1,'color','r') 

    c2 = cdfplot(ns_corr_vals, 'r');
    set(c2,'color','k') 

    xlabel('Correlation coefficient');
    ylabel('Cumulative frequency');

    legend('Singing','Nonsinging')

    hold off

    saveas(fig, f_path)
    close(fig);
end