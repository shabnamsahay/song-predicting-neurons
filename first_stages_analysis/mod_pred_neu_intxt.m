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
song_pred_neu_file = "SongPredNeurons.mat";

for m = 1:n_mice
    m_dat = mouse_dat(m,:);
    m_dat = m_dat(m_dat~="NA"); % removing dummy NA entries

    % looping over all sessions for this mouse

    for sess = 1 : length(m_dat)

        % loading the song modulated neuron numbers
        % and skipping if there are none

        load(data_f + m_dat(sess) + "/" + song_mod_neu_file)
        load(data_f + m_dat(sess) + "/" + song_pred_neu_file)

        if isempty(song_mod_neurons) | isempty(song_pred_neurons)
            continue;
        end

        common_neus = intersect(song_mod_neurons, song_pred_neurons);

        disp("Mouse number: " + string(m))
        disp("Session: " + m_dat(sess))
        disp("Number of song modulating neurons: " + string(length(song_mod_neurons)))
        disp("Number of song predicting neurons: " + string(length(song_pred_neurons)))
        disp("Number of common neurons: " + string(length(common_neus)))
        disp("Common neurons are:")
        disp(common_neus)

    end
end