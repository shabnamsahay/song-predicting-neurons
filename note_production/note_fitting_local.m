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

for m = 1:1 %1:n_mice
    m_dat = mouse_dat(m,:);
    m_dat = m_dat(m_dat~="NA"); % removing dummy NA entries

    % looping over all sessions for this mouse

    for sess = 1:1 %1 : length(m_dat)

        % loading the behavioural timings file
        % and note start and stop times

        load(data_f + m_dat(sess) + "/" + behav_file)

        n_songs = length(T_Motor);
        syll_start_stop = SyllStartStopTimes;

        for song_n = 1:2 %1:n_songs

            all_note_ons = syll_start_stop(song_n).Ons;
            note_offs = syll_start_stop(song_n).Offs;

            

            n_note_starts = length(all_note_ons) - 1;

            note_ons = all_note_ons(1:n_note_starts);
            delta_ts = diff(all_note_ons);

            disp(note_ons(1:10))
            disp(delta_ts(1:10))

            polyModel = @(p, x) - (p(1) + x) + sqrt((p(1) + x).^2 + p(2));
            init_guess = [-0.08, 1.2];

            [p, resnorm] = lsqcurvefit(polyModel, init_guess, note_ons, delta_ts);
            fn_fit = polyModel(p, note_ons);

            fig_path_plt = data_f + m_dat(sess) + "/song_" + string(song_n) + "_local_note_fitting.png";

            visualize_note_fitting(note_ons, delta_ts, fn_fit, fig_path_plt);
            
            disp('Fitted parameters c and D:')
            disp(p)

        end

    end
end



function visualize_note_fitting(orig_x, orig_y, pred_y, fpath)

    fig = figure;

    scatter(orig_x, orig_y, 'filled', 'DisplayName', 'Original Data');
    hold on;

    plot(orig_x, pred_y, '-r', 'LineWidth', 2, 'DisplayName', 'Fitted Polynomial');
    hold off;

    xlabel('t0');
    ylabel('Delta T');
    title('Fitting Note Start and Gap Data');
    legend('show');

    saveas(fig, fpath)
    close(fig);

end