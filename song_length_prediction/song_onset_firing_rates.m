function f = song_onset_firing_rates(song_intvs, spike_ts, wdw, buff)
    
    n_songs = length(song_intvs);
    firing_rates = zeros(n_songs,1);

    for i = 1:n_songs
        song_start = song_intvs(i, 1);
        
        spikes_within = spike_ts(spike_ts >= song_start - buff);
        spikes_within = spikes_within(spikes_within <= song_start + wdw);

        firing_rates(i,1) = length(spikes_within)/(buff + wdw);
    end

    f = firing_rates;
end