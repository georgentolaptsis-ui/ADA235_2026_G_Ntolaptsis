[[insert sun o))) file - reconstuction]]
[[sun o))) recon drone]]


(
s.boot;
s.options.memSize = 65536 * 8;

s.waitForBoot({

~soundPath = "C:/Users/Acer/Desktop/movies-series-music/Sunn O))) - Kannon (2015) (Southern Lord) WEB FLAC 24/01. Kannon 1.flac";

SynthDef(\kannonPulse, { |bufnum, amp = 0.7, bpm = 52|

    var sig, pulse;
    var master, rise, fall;
    var dronePos, droneRate, droneSig, droneEnv;
    var drive, collapse;
    var threshold, instability;

    // ── MASTER ──
    rise = LFSaw.kr(0.005).range(0.2, 1.0);
    fall = LFNoise1.kr(0.02).range(0.7, 1.0);
    master = (rise * fall).clip(0.2, 1.0);

    // ── BASE (background now) ──
    sig = PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum), loop: 1);
    sig = HPF.ar(sig, master.linexp(0.2, 1.0, 80, 40));
    sig = RLPF.ar(sig, 800, 0.9);

    drive = master.linlin(0.2, 1.0, 0.8, 2.5);
    sig = (sig * (drive * 0.4)).tanh * 0.3;

    // ── PULSE ──
    pulse = SinOsc.kr((bpm/60)*0.5).range(0.5, 1.0);
    sig = sig * pulse.linexp(0.5, 1.0, 0.3, 1.2) * amp;

    // ── DRONE (lighter) ──
    dronePos = LFNoise1.kr(0.01).range(0.1, 0.8);
    droneRate = 0.6 + (master * 0.25);

    droneSig = PlayBuf.ar(2, bufnum,
        rate: BufRateScale.kr(bufnum) * droneRate,
        startPos: dronePos * BufFrames.kr(bufnum),
        loop: 1
    );

    droneSig = HPF.ar(droneSig, 40);
    droneSig = RLPF.ar(droneSig, master.linexp(0.2, 1.0, 80, 400), 0.5);

    droneSig = (droneSig * 1.8).tanh; // λιγότερο aggressive
    droneEnv = master.squared;

    droneSig = droneSig * droneEnv * 0.4;

    // ── MIX ──
    sig = sig + droneSig;

    // ── COLLAPSE ──
    collapse = (1 - master).squared;
    sig = sig * (1 - collapse * 0.6);

    // ── INSTABILITY (πιο subtle) ──
    threshold = master < 0.35;
    instability = LFNoise2.ar(200) * 0.01;

    sig = Select.ar(threshold, [
        sig,
        sig + instability
    ]);

    // ── FINAL SPACE (ONE reverb only) ──
    sig = GVerb.ar(sig[0], 100, 8) * 0.5 + (sig * 0.5);

    sig = LPF.ar(sig, master.linexp(0.2, 1.0, 400, 8000));
    sig = Splay.ar(sig, master);

    sig = Limiter.ar(sig, 0.9);
    Out.ar(0, sig);

}).add;


SynthDef(\droneBurst, { |bufnum, amp = 0.8, pos = 0.2, dur = 8|

    var env, sig;
    var arp, freq;
    var wet;
    var fade;

    // ── MAIN ENVELOPE (missing before!) ──
    env = EnvGen.kr(
        Env([0, 1, 1, 0], [3.0, dur, 2.5], \sine),
        doneAction: 2
    );

    // ── FADE IN FOR ARP STRUCTURE ──
   fade = Lag.kr(
    LFSaw.kr(0.02).range(0.0, 1.0),
    5.0
);

    // ── ARPEGGIATOR ──
    arp = Demand.kr(
        Impulse.kr(0.7),
        0,
        Dseq([1, 0.75, 1.2, 0.5], inf)
    );

    freq = arp;

    sig = PlayBuf.ar(2, bufnum,
        rate: BufRateScale.kr(bufnum) * freq * 0.4,
        startPos: pos * BufFrames.kr(bufnum),
        loop: 1
    );

    sig = sig * fade;

    sig = HPF.ar(sig, 40);
    sig = LPF.ar(sig, 6660);
    sig = (sig * 3).tanh;

    wet = GVerb.ar(sig, 60, 4);
    sig = (sig * 0.7) + (wet * 0.3);

    // ── FINAL CONTROL ──
    sig = sig * env * amp;

    Out.ar(0, sig);

}).add;

s.sync;

~buf = Buffer.read(s, ~soundPath, action: { |b|

    ~player = Synth(\kannonPulse, [\bufnum, b]);

    ~droneRoutine = Routine({
        var base = 16;

        loop {
            (base + rrand(-2.0,6.0)).wait;

            Synth(\droneBurst, [
                \bufnum, b,
                \amp, rrand(0.1,0.2),
                \pos, rrand(0.3,0.9),
                \dur, rrand(9.0,28.0)
            ]);
        }
    }).play;

});

});
)