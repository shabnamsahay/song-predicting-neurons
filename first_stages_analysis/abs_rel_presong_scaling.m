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

% to store the calculated variance values

abs_rel_vars = zeros(100, 2); % 200 as a placeholder for total songpredneus
neu_ct = 1;


% looping over all mice to be processed

for m = 1:n_mice
    m_dat = mouse_dat(m,:);
    m_dat = m_dat(m_dat~="NA"); % removing dummy NA entries

    % looping over all sessions for this mouse

    for sess = 1 : length(m_dat)

        % loading the song predicted neuron numbers
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

        % choosing window size based on shortest song duration

        song_durs = syll_times(:,2) - syll_times(:,1);
        min_song_len = min(song_durs);
        st_buffer = 1; % seconds before song start to keep as buffer
        min_presong_wdw = 7; % min presong window to consider

        % loading the cluster output file

        load(data_f + m_dat(sess) + "/" + clust_file)

        disp("Mouse number: " + string(m))
        disp("Session: " + m_dat(sess))
        disp(song_pred_neurons)

        n_samps = get_n_samples(0, min_presong_wdw, samp_interval);
        abs_psths = zeros(n_samps, nrows(syll_times));
        rel_psths = zeros(n_samps, nrows(syll_times));

        for i = 1:n_neurons

            n = song_pred_neurons(i,1);
            spike_times = clusters(n).spikeTimes;

            abs_psths(:,:) = presong_conv_firing_rates(syll_times, spike_times, ...
                                                       -1*(st_buffer + min_presong_wdw), ...
                                                       -1*st_buffer, samp_interval);

            rel_psths(:,:) = presong_warp_firing_rates(syll_times, spike_times, ...
                                                       st_buffer, n_samps, ...
                                                       min_song_len, min_presong_wdw);

            abs_rel_vars(neu_ct, 1) = get_psth_variance(abs_psths);
            abs_rel_vars(neu_ct, 2) = get_psth_variance(rel_psths);
            neu_ct = neu_ct + 1;

        end
    end
end

rows = find(abs_rel_vars(:,1)<1e5 & abs_rel_vars(:,2)<1e5);
arvars = abs_rel_vars(rows,:);

disp(arvars(1:10,:))

fig_path_scatt = data_f + "/presong_abs_rel_var_scatter_1_7.png";
visualize_var_scatter(arvars(1:neu_ct-1, :), fig_path_scatt);