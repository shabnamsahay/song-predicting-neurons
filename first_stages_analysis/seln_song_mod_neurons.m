% folder names

data_f = "./Data_Arka/";
mouse_dat = ["190516","190521","190523","NA","NA","NA";
             "190705","190708","190709","190711","190716","190724";
             "191217","191223","NA","NA","NA","NA";
             "200917","200919","NA","NA","NA","NA"];

% file names

behav_file = "BehavioralTimings.mat";
clust_file = "clusterOutput.mat";
song_mod_neu_file = "SongModNeurons.mat";

% parameters to adjust

song_type = "motor"; % motor vs. auditory
n_mice = 4; % how many mice to process
alpha = 0.01; % significance threshold

% numbers to check

total_neurons = 0;
song_mod_neus = 0;

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
        
        % choosing window size based on shortest song duration

        song_durs = syll_times(:,2) - syll_times(:,1);
        window = min(song_durs);

        % loading the cluster output file

        load(data_f + m_dat(sess) + "/" + clust_file)
        n_neurons = length(clusters);
        total_neurons = total_neurons + n_neurons;

        song_mod_neurons = zeros(n_neurons, 1);

        for n = 1:n_neurons

            buff_t = 2; % extra time before/after song to include

            spike_times = clusters(n).spikeTimes;
            onset_rates = song_onset_firing_rates(syll_times, spike_times, ...
                                                  window, buff_t);
            offset_rates = song_offset_firing_rates(syll_times, spike_times, ...
                                                    window, buff_t);

            control_rates = baseline_firing_rates(syll_times, spike_times);

            [h_on,p_on] = ttest2(onset_rates,control_rates);
            [h_off,p_off] = ttest2(offset_rates,control_rates);

            p_combined = min([p_on p_off]) * 2;
            if p_combined > 0.01
                continue
            end
            song_mod_neurons(n, 1) = 1;
            song_mod_neus = song_mod_neus + 1;

        end

        disp("Mouse number: " + string(m))
        disp("Session: " + m_dat(sess))
        song_mod_neurons = find(song_mod_neurons == 1);

        disp(song_mod_neurons)
        save(data_f + m_dat(sess) + "/" + song_mod_neu_file,"song_mod_neurons")

    end
end

disp("Total neurons present: " + string(total_neurons))
disp("Song-modulated neurons found: " + string(song_mod_neus))