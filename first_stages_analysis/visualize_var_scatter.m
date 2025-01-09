function visualize_var_scatter(vars_mat, f_path)

    disp(length(vars_mat))
    disp(nnz(vars_mat(:,1) < vars_mat(:,2)))
   
    abs_var_vals = vars_mat(:,1);
    rel_var_vals = vars_mat(:,2);

    disp(mean(abs_var_vals))
    disp(mean(rel_var_vals))

    [h,p] = ttest(rel_var_vals, abs_var_vals);
    disp(p)

    fig = figure;

    scatter(abs_var_vals, rel_var_vals, 'filled');
    set(gca,'xscale','log','yscale','log')

    xlim([0.005 1])
    ylim([0.005 1])

    x = linspace(1e-4,max(vars_mat,[],"all") + 1000);
    y = x;
    line(x,y,'Color','black','LineStyle','--')

    xlabel('Explained variance - absolute time');
    ylabel('Explained variance - relative time');
    % title(['p = ' num2str(p)])

    saveas(fig, f_path)
    close(fig);

end