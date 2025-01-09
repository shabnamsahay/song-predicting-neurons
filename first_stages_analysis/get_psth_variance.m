function f = get_psth_variance(psth_mat)

    % mean_template = mean(psth_mat, 2);
    % sqd_diffs = (psth_mat - mean_template).^2;
    % mean_diffs = mean(sqd_diffs,"all");
    % 
    % res = (1 - mean_diffs)/var(psth_mat,1,"all");
    % f = res;

    % Calculate the mean across trials 
    mean_template = mean(psth_mat, 2); 
    % Calculate the squared differences from the mean 
    sqd_diffs = (psth_mat - mean_template).^2; 
    mean_diffs = mean(sqd_diffs, "all"); 
    
    % Calculate the variance 
    psth_var = var(psth_mat(:), 1); 
    
    % Compute the explained variance 
    res = 1 - (mean_diffs / psth_var); 
    f = res;
    
end