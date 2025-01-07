% folder names

data_f = "./Data_Arka/";
mouse_dat = ["190516","190521","190523","NA","NA","NA";
             "190705","190708","190709","190711","190716","190724";
             "191217","191223","NA","NA","NA","NA";
             "200917","200919","NA","NA","NA","NA"];

% file names

behav_file = "BehavioralTimings.mat";
clust_file = "clusterOutput.mat";
song_pred_neu_file = "SongPredNeurons.mat";

% parameters to adjust

rng(0,'twister'); % making rand reproducible
song_type = "motor"; % motor vs. auditory
n_mice = 4; % how many mice to process
samp_interval = 0.2; % 200 ms

% matrices to store avg corr coeffs

avg_s_corrs = zeros(size(mouse_dat));
avg_ns_corrs = zeros(size(mouse_dat));

% looping over all mice to be processed

for m = 1:n_mice
    m_dat = mouse_dat(m,:);
    m_dat = m_dat(m_dat~="NA"); % removing dummy NA entries

    % looping over all sessions for this mouse

    for sess = 1 : length(m_dat)

        % loading the song predicting neuron numbers
        % and skipping if there are none

        load(data_f + m_dat(sess) + "/" + song_pred_neu_file)

        if isempty(song_pred_neurons)
            continue;
        end
        n_neurons = length(song_pred_neurons);

        % loading the behavioural timings file
        % and extracting times of song_type into a matrix

        load(data_f + m_dat(sess) + "/" + behav_file)
        syll_times = T_Motor;

        % loading the cluster output file

        load(data_f + m_dat(sess) + "/" + clust_file)

        disp("Mouse number: " + string(m))
        disp("Session: " + m_dat(sess))
        disp(song_pred_neurons)

        buff_t = -10; % signed time before song start to include
        window = 0; % time after song onset to include
        post_st = 10; % non-singing epoch - time after song end to start from
        post_end = 30; % non-singing epoch - time after song end to end at

        s_samps = get_n_samples(buff_t, window, samp_interval);
        ns_samps = get_n_samples(post_st, post_end, samp_interval);

        s_v = zeros(n_neurons*s_samps,length(syll_times));
        ns_v = zeros(n_neurons*ns_samps,length(syll_times));

        for i = 1:n_neurons

            n = song_pred_neurons(i,1);
            spike_times = clusters(n).spikeTimes;

            row_f_s = (i-1)*s_samps + 1;
            row_l_s = i*s_samps;

            row_f_ns = (i-1)*ns_samps + 1;
            row_l_ns = i*ns_samps;

            

            s_v(row_f_s:row_l_s, :) = convolved_firing_rates(syll_times, spike_times, ...
                                               buff_t, window, samp_interval, true);
            ns_v(row_f_ns:row_l_ns, :) = convolved_firing_rates(syll_times, spike_times, ...
                                                post_st, post_end, samp_interval, false);   
        end

        s_corrs = corrcoef(s_v);
        fig_path_s = data_f + m_dat(sess) + "/pred_singing_corrs.png";
        visualize_corr_mat(s_corrs, fig_path_s, m_dat(sess), "Pre-singing epoch index");

        ns_corrs = corrcoef(ns_v);
        fig_path_ns = data_f + m_dat(sess) + "/pred_nonsinging_corrs.png";
        visualize_corr_mat(ns_corrs, fig_path_ns, m_dat(sess), "Nonsinging epoch index");

        avg_s_corrs(m, sess) = mean(get_upper_tri_vals(s_corrs));
        avg_ns_corrs(m, sess) = mean(get_upper_tri_vals(ns_corrs));

        if mean(ns_corrs, "all") >= mean(s_corrs, "all")
            disp("Non-singing correlation greater in session "  + m_dat(sess))
        end

        fig_path_cmf = data_f + m_dat(sess) + "/predcmfreq_comp.png";
        visualize_cmfreqs(s_corrs, ns_corrs, fig_path_cmf);
    end
end

fig_path_scatt = data_f + "/pred_avg_corr_scatter.png";
visualize_corr_scatter(avg_s_corrs, avg_ns_corrs, fig_path_scatt);