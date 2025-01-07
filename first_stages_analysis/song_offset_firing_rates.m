function f = song_offset_firing_rates(song_intvs, spike_ts, wdw, buff)
    
    n_songs = nrows(song_intvs);
    firing_rates = zeros(n_songs,1);

    for i = 1:n_songs
        song_stop = song_intvs(i, 2);
        
        spikes_within = spike_ts(spike_ts >= song_stop - wdw);
        spikes_within = spikes_within(spikes_within <= song_stop + buff);

        firing_rates(i,1) = nrows(spikes_within)/(wdw + buff);
    end

    f = firing_rates;
end