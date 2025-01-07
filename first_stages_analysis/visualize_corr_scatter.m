function visualize_corr_scatter(s_corr_avgs, ns_corr_avgs, f_path)

    s_corr_avgs = reshape(s_corr_avgs,1,[]);
    ns_corr_avgs = reshape(ns_corr_avgs,1,[]);
    
    s_corr_avgs = s_corr_avgs(s_corr_avgs~=0);
    ns_corr_avgs = ns_corr_avgs(ns_corr_avgs~=0);

    fig = figure;
    hold on

    scatter(ns_corr_avgs, s_corr_avgs, "filled");

    x = linspace(0,1);
    y = x;
    line(x,y,'Color','black','LineStyle','--')

    xlabel('Avg correlation (Nonsinging epochs)');
    ylabel('Avg correlation (Singing epochs)');

    hold off

    saveas(fig, f_path)
    close(fig);

end