function visualize_cverr_var_linear(bin_st_vec, var_expl_vec, ...
                                    f_path, f_title, num_neus, num_songs)

    fig = figure;

    plot(bin_st_vec,var_expl_vec,'-o')

    hold on
    x = linspace(5,10);
    y = zeros(size(x));
    line(x,y,'Color','red','LineStyle','--')
    hold off

    xlabel('Bin start time (before song onset)');
    ylabel('Variance explained');
    title(f_title + ": " + string(num_neus) + " neurons, " + ...
        string(num_songs) + " songs");

    saveas(fig, f_path)
    close(fig);

end