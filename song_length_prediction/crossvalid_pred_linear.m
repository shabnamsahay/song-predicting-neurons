function f = crossvalid_pred_linear(song_intvs, clusts_var, ...
                                    song_pred_neus, ...
                                    bin_st_time, bin_dur)

    n_songs = length(song_intvs);
    n_neurons = length(song_pred_neus);

    A = gen_model_matrix(song_intvs, clusts_var, ...
                         song_pred_neus, bin_st_time, bin_dur);
    slens = song_intvs(:,2) - song_intvs(:,1);

    cv_pred_err = zeros(n_songs, 1);

    for i = 1:n_songs % exclude each song once

        model_mat = [A(1:i-1,:); A(i+1:n_songs,:)];
        slens_vec = [slens(1:i-1,:); slens(i+1:n_songs, :)];

        mdl = fitlm(model_mat,slens_vec);
        coeff_ests = mdl.Coefficients.Estimate;

        bias_t = coeff_ests(1,1);
        W_vec = coeff_ests(2:length(coeff_ests), :);

        crt_song_dur = slens(i,1);
        crt_song_predlen = A(i,:)*W_vec + bias_t;
        % predlens_vec = model_mat*W_vec + bias_t;
        
        crt_song_pred_err = abs(crt_song_predlen - crt_song_dur);
        cv_pred_err(i,1) = crt_song_pred_err;
        
    end

    f = mean(cv_pred_err);

end


function f = gen_model_matrix(song_intvs, clusts_var, ...
                              song_pred_neus, bin_st_time, bin_dur)

    n_songs = length(song_intvs);
    n_neurons = length(song_pred_neus);

    res_mat = zeros(n_songs, n_neurons);

    for i = 1:n_songs

        song_start = song_intvs(i, 1);
        start_t = song_start - bin_st_time;
        end_t = start_t + bin_dur;

        for j = 1:n_neurons
            n = song_pred_neus(j,1);
            spike_ts = clusts_var(n).spikeTimes;
            
            spikes_within = spike_ts(spike_ts >= start_t);
            spikes_within = spikes_within(spikes_within <= end_t);
            res_mat(i,j) = length(spikes_within);
        end

    end

    f = res_mat;

end