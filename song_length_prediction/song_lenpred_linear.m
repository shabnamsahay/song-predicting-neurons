% folder names

data_f = "./Data_Arka/";
mouse_dat = ["190516","190521","190523","NA","NA","NA";
             "190705","190708","190709","190711","190716","190724";
             "191217","191223","NA","NA","NA","NA";
             "200917","200919","NA","NA","NA","NA"];
n_mice = 4; % how many mice to process

% file names

behav_file = "BehavioralTimings.mat";
clust_file = "clusterOutput.mat";
song_pred_neu_file = "SongPredNeurons.mat";

% pre-song time bin parameters

bin_start = 10; % 10s before the song onset
bin_duration = 5;
bin_increment = 0.5;

lowest_bin_start = bin_duration;
num_diff_bins = (bin_start - bin_duration)/bin_increment + 1;

bin_st_vals = linspace(bin_start,lowest_bin_start,num_diff_bins);

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

        % calculating variance of song length

        song_durs = syll_times(:,2) - syll_times(:,1);
        songlen_var = var(song_durs);
        n_songs = length(song_durs);

        % loading the cluster output file

        load(data_f + m_dat(sess) + "/" + clust_file)

        disp("Mouse number: " + string(m))
        disp("Session: " + m_dat(sess))
        disp(song_pred_neurons)

        % to store variance explained

        var_expl = zeros(1, num_diff_bins);

        for bin_n = 1:num_diff_bins

            crt_bin_st = bin_start - (bin_n - 1)*bin_increment;

            crossv_err = crossvalid_pred_linear(syll_times, clusters, ...
                                                song_pred_neurons, ...
                                                crt_bin_st, bin_duration);

            var_expl(1, bin_n) = 1 - crossv_err/songlen_var;
        end

        disp("Calculated values are")
        disp(songlen_var)
        disp(var_expl)
        disp(bin_st_vals)

        fig_path = data_f + m_dat(sess) + "/cverr_var_linear.png";
        visualize_cverr_var_linear(bin_st_vals, var_expl, ...
                                    fig_path, m_dat(sess), n_neurons, n_songs);

    end
end