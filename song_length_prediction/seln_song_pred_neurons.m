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

song_type = "motor"; % motor vs. auditory
n_mice = 4; % how many mice to process
alpha = 0.01; % significance threshold

% numbers to check

total_neurons = 0;
song_pred_neus = 0;

% looping over all mice to be processed

for m = 1:n_mice
    m_dat = mouse_dat(m,:);
    m_dat = m_dat(m_dat~="NA"); % removing dummy NA entries

    % looping over all sessions for this mouse

    for sess = 1 : length(m_dat)

        % loading the behavioural timings file
        % and extracting times of song_type into a matrix

        load(data_f + m_dat(sess) + "/" + behav_file)
        syll_times = T_Motor;

        % loading the cluster output file

        load(data_f + m_dat(sess) + "/" + clust_file)
        n_neurons = length(clusters);
        total_neurons = total_neurons + n_neurons;

        song_pred_neurons = zeros(n_neurons, 1);

        for n = 1:n_neurons

            buff_t = 10; % time before song start to include
            window = 0; % time after song onset to include

            spike_times = clusters(n).spikeTimes;
            onset_rates = song_onset_firing_rates(syll_times, spike_times, ...
                                                  window, buff_t);

            control_rates = baseline_firing_rates(syll_times, spike_times);

            [h,p] = ttest2(onset_rates,control_rates);
            if p > 0.05
                continue
            end

            song_pred_neurons(n, 1) = 1;
            song_pred_neus = song_pred_neus + 1;

        end

        disp("Mouse number: " + string(m))
        disp("Session: " + m_dat(sess))
        song_pred_neurons = find(song_pred_neurons == 1);

        disp(song_pred_neurons)
        save(data_f + m_dat(sess) + "/" + song_pred_neu_file,"song_pred_neurons")

    end
end

disp("Total neurons present: " + string(total_neurons))
disp("Song-predicting neurons found: " + string(song_pred_neus))