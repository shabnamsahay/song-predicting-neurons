function visualize_cverr_var_linear(bin_st_vec, var_expl_vec, ...
                                    f_path, f_title)

    fig = figure;

    plot(bin_st_vec,var_expl_vec,'-o')

    xlabel('Bin start time (before song onset)');
    ylabel('Variance explained');
    title(f_title);

    saveas(fig, f_path)
    close(fig);

end