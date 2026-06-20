[[insert sun o))) file - reconstuction]]
[[sun o))) recon to Arpeggiator]]
(
s.boot;

~soundPath = "C:/Users/Acer/Desktop/movies-series-music/Sunn O))) - Kannon (2015) (Southern Lord) WEB FLAC 24/ΟνομαΑρχείου.flac";

SynthDef(\player, { |bufnum, amp=0.8|
    var sig = PlayBuf.ar(
        numChannels: 2,
        bufnum:      bufnum,
        rate:        BufRateScale.kr(bufnum),
        loop:        0,
        doneAction:  2
    );
    Out.ar(0, sig * amp);
}).add;

s.waitForBoot({
    ~buf = Buffer.read(s, ~soundPath, action: { |b|
        "✓ Buffer φορτώθηκε!".postln;
        "Channels: ".post; b.numChannels.postln;
        "Duration: ".post; b.duration.postln;
    });
});
)

Κάθε φορά που ανοίγεις το αρχείο κάνεις **Ctrl+A** και μετά **Ctrl+Enter** — και μετά περιμένεις να δεις στο Post Window:

```
✓ Buffer φορτώθηκε!
Channels: 2
Duration: 187.4...
```

Και μετά παίζεις με αυτή τη γραμμή ξεχωριστά:

supercollider

```supercollider
~player = Synth(\player, [bufnum: ~buf, amp: 0.8]);
```

---

Το `s.waitForBoot` είναι καλύτερο από απλό `s.boot` γιατί **περιμένει** να ξεκινήσει ο server πριν φορτώσει το αρχείο —