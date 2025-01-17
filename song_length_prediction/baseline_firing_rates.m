function f = baseline_firing_rates(song_intvs, spike_ts)
    
    n_songs = nrows(song_intvs);
    firing_rates = zeros(n_songs,1);

    off_wdw_start = 10; % time after song stop when control window starts
    req_durn = 60; % total required duration of control

    % creating buffered song intervals for checking overlap w baseline
    buffd_song_intvs = song_intvs;
    buffd_song_intvs(:,1) = song_intvs(:,1) - off_wdw_start;
    buffd_song_intvs(:,2) = song_intvs(:,2) + off_wdw_start;

    for i = 1:n_songs

        song_stop = song_intvs(i, 2);

        control_start_time = song_stop + off_wdw_start;
        spikes_within = count_control_spikes(buffd_song_intvs, spike_ts, ...
                                             control_start_time, req_durn);

        firing_rates(i,1) = spikes_within/(req_durn);

    end

    f = firing_rates;
end

function f = count_control_spikes(song_intvs, spike_ts, abs_start_time, durn_rem)

    f = 0;
    n_songs = nrows(song_intvs);
    
    if n_songs == 0
        return
    end

    flag = false; % is recursion required?
    abs_end_time = abs_start_time + durn_rem;

    for i = 1:n_songs

        if durn_rem == 0
            break;
        end

        crt_song_start = song_intvs(i, 1);
        crt_song_stop = song_intvs(i, 2);

        if (abs_start_time>crt_song_start && abs_start_time<crt_song_stop)

            flag = true;

            new_start_time = crt_song_stop;
            f = f + count_control_spikes(song_intvs(i+1:n_songs,:), spike_ts, ...
                                         new_start_time, durn_rem);

        elseif ((abs_end_time>crt_song_start && abs_end_time < crt_song_stop) || ...
                (abs_start_time<crt_song_start && abs_end_time>crt_song_stop))

            flag = true;

            durn_can_be_used = crt_song_start - abs_start_time;
            spikes_within = spike_ts(spike_ts >= abs_start_time);
            spikes_within = spikes_within(spikes_within <= crt_song_start);
            f = f + nrows(spikes_within);

            durn_rem = durn_rem - durn_can_be_used;
            new_start_time = crt_song_stop;
            f = f + count_control_spikes(song_intvs(i+1:n_songs,:), spike_ts, ...
                                         new_start_time, durn_rem);

        end
    end

    if ~flag
        spikes_within = spike_ts(spike_ts >= abs_start_time);
        spikes_within = spikes_within(spikes_within <= abs_end_time);
        f = f + nrows(spikes_within);
    end

    
end