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

n_mice = 4;
reqdata = zeros(13, 4); %rows: sessions, cols: total, mod, pred, common
ct = 1;

for m = 1:n_mice
    m_dat = mouse_dat(m,:);
    m_dat = m_dat(m_dat~="NA"); % removing dummy NA entries

    % looping over all sessions for this mouse

    for sess = 1 : length(m_dat)

        % loading the song modulated neuron numbers

        load(data_f + m_dat(sess) + "/" + clust_file)
        load(data_f + m_dat(sess) + "/" + song_mod_neu_file)
        load(data_f + m_dat(sess) + "/" + song_pred_neu_file)

        n_neurons = length(clusters);
        n_mod = 0;
        n_pred = 0;
        n_common = 0;

        if isempty(song_mod_neurons)
            n_mod = 0;
        else
            n_mod = length(song_mod_neurons);
        end

        if isempty(song_pred_neurons)
            n_pred = 0;
        else
            n_pred = length(song_pred_neurons);
        end

        if isempty(song_mod_neurons) | isempty(song_pred_neurons)
            n_common = 0;
        else
            common_neus = intersect(song_mod_neurons, song_pred_neurons);
            n_common = length(common_neus);
        end

        reqdata(ct,1:4) = [n_neurons, n_mod, n_pred, n_common];
        ct = ct + 1;

        disp("Mouse number: " + string(m))
        disp("Session: " + m_dat(sess))

    end
end

fig = figure;
bar(reqdata);
ylabel('Number of neurons');
set(gca,'XTickLabel',{"190516", "190521", "190523", "190705", ...
                      "190708", "190709", "190711", "190716", ...
                      "190724", "191217", "191223", "200917", "200919"});
legend('Total','Song-mod', 'Song-pred', 'Common')

saveas(fig, data_f + "/neuron_type_counts.png")
close(fig);