>[[Compine sun o))) reconstruction + drum loop]]] 


s.options.memSize = 65536 * 8;
s.boot;

~soundPath = "C:/Users/Acer/Desktop/movies-series-music/Sunn O))) - Kannon (2015) (Southern Lord) WEB FLAC 24/01. Kannon 1.flac";
~bpm = 120;

(
// ── SYNTHDEFS: ΚΟΜΜΑΤΙ 1 (dark wave / She Past Away aesthetic) ──

SynthDef(\fmDrone, {
    |out=0, freq=55, ratio=2.02, depth=80, amp=0.3, atk=8, rel=2|
    var mod, carrier, sig;
    mod     = SinOsc.kr(ratio).range(0.01, depth);
    carrier = SinOsc.ar(freq + mod, 0, amp);
    sig     = carrier * EnvGen.kr(Env.linen(atk, 0, rel), doneAction: 2);
    sig     = FreeVerb.ar(sig, 0.6, 0.75);
    sig     = Limiter.ar(sig, 0.3);
    Out.ar(out, sig ! 2);
}).add;

// Kick: βαρύ, distorted, με κοντό punch — drum machine χαρακτήρας
SynthDef(\kick, {
    |out=0, amp=0.4|
    var env, envD, sig, click;
    env  = EnvGen.kr(Env.perc(0.001, 0.35), doneAction: 2);
    envD = EnvGen.kr(Env.perc(0.001, 0.08));
    sig  = SinOsc.ar(XLine.kr(90, 28, 0.35)) * env * amp;
    click = WhiteNoise.ar() * envD * 0.15;  // transient click
    sig  = sig + click;
    sig  = (sig * 2.5).tanh;  // distortion
    sig  = HPF.ar(sig, 28);
	sig = RLPF.ar(sig, LFSaw.kr(1.15).range(80, 800), 0.3);
    sig  = Limiter.ar(sig, 0.9);
    Out.ar(out, sig ! 2);
}).add;

// Snare: ξερό, metallic, με έντονο gated reverb — χαρακτηριστικό dark wave
SynthDef(\snare, {
    |out=0, amp=0.5|
    var env, sig, tone, noise;
    env   = EnvGen.kr(Env.perc(0.001, 0.28), doneAction: 2);  // πιο μακρύ decay
    noise = WhiteNoise.ar() * env * amp;
    tone  = SinOsc.ar(200) * EnvGen.kr(Env.perc(0.001, 0.06)) * 0.6;
    sig   = noise + tone;
    sig   = BPF.ar(sig, 1200, 0.9) + (sig * 0.4);
    sig   = HPF.ar(sig, 180);
    sig   = (sig * 1.2).tanh * 0.8;  // λιγότερο aggressive clip
	sig = RLPF.ar(sig, LFSaw.kr(0.15).range(100, 3000), 0.6);
    sig   = GVerb.ar(sig, 55, 3.5, 0.7, drylevel: 0.4);  // μεγάλο δωμάτιο, περισσότερο wet
    Out.ar(out, sig ! 2);
}).add;

// Hihat: harsh, metallic click — minimal και ξερό
SynthDef(\hihat, {
    |out=0, amp=0.3, dur=0.06|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.001, dur), doneAction: 2);
    sig = Mix(SinOsc.ar([3200, 4800, 6400, 9600]) * [0.4, 0.3, 0.2, 0.1]);
    sig = sig + (WhiteNoise.ar() * 0.3);
    sig = HPF.ar(sig, 6000);
    sig = sig * env * amp;
	sig = HPF.ar(sig, LFSaw.kr(0.15).range(2000, 19000), 0.6);
    sig = Limiter.ar(sig, 0.7);
    Out.ar(out, sig ! 2);
}).add;



// ── SYNTHDEFS: ΚΟΜΜΑΤΙ 2 (παραλλαγή για combined) ──

// Αυτό είναι one-shot: trigger-άρεται από τη drum Routine σε κάθε beat
SynthDef(\kannonBeat, { |bufnum, amp = 0.5, pos = 0.0, dur = 0.4|
    var env, sig, wet;
    env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    sig = PlayBuf.ar(2, bufnum,
        rate: BufRateScale.kr(bufnum) * 0.6,
        startPos: pos * BufFrames.kr(bufnum),
        loop: 0
    );
    sig = HPF.ar(sig, 40);
    sig = RLPF.ar(sig, 400, 0.7);
    sig = (sig * 2.0).tanh;
    sig = sig * env * amp;
    wet = GVerb.ar(sig[0], 100, 8) * 0.5 + (sig * 0.5);
    sig = Splay.ar(wet);
    sig = Limiter.ar(sig, 0.85);
    Out.ar(0, sig);
}).add;

// Αυτό τρέχει συνεχόμενο σαν drone background (χωρίς pulse)
SynthDef(\kannonDrone, { |bufnum, amp = 0.25|
    var sig, dronePos, droneRate, droneSig;
    dronePos = LFNoise1.kr(0.01).range(0.1, 0.8);
    droneRate = LFNoise1.kr(0.02).range(0.5, 0.7);
    droneSig = PlayBuf.ar(2, bufnum,
        rate: BufRateScale.kr(bufnum) * droneRate,
        startPos: dronePos * BufFrames.kr(bufnum),
        loop: 1
    );
    droneSig = HPF.ar(droneSig, 40);
    droneSig = RLPF.ar(droneSig, 200, 0.5);
    droneSig = (droneSig * 1.5).tanh;
    droneSig = GVerb.ar(droneSig[0], 100, 8) * 0.5 + (droneSig * 0.5);
    droneSig = Splay.ar(droneSig);
    droneSig = Limiter.ar(droneSig * amp, 0.5);
    Out.ar(0, droneSig);
}).add;

// droneBurst: one-shot, trigger-άρεται από τη drum Routine, χωρίς arpeggiator
SynthDef(\droneBurst, { |bufnum, amp = 0.8, pos = 0.2, dur = 0.5|
    var env, sig, wet;
    env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    sig = PlayBuf.ar(2, bufnum,
        rate: BufRateScale.kr(bufnum) * 0.5,
        startPos: pos * BufFrames.kr(bufnum),
        loop: 0
    );
    sig = HPF.ar(sig, 40);
    sig = LPF.ar(sig, 6660);
    sig = (sig * 2.0).tanh;
    wet = GVerb.ar(sig[0], 60, 4) * 0.4 + (sig * 0.6);
    sig = Splay.ar(wet);
    sig = sig * env * amp;
    sig = Limiter.ar(sig, 0.85);
    Out.ar(0, sig);
}).add;

// ── ΕΚΚΙΝΗΣΗ ──

s.waitForBoot({
    var beat = 60 / ~bpm;

    s.sync;

    Routine({
        Synth(\fmDrone, [freq: 55, ratio: 2.02, depth: 80, atk: 8, rel: 2, amp: 1.25]);
    }).play;

    Buffer.read(s, ~soundPath, action: { |b|

        // Drone background συνεχόμενο
        Synth(\kannonDrone, [\bufnum, b, \amp, 0.25]);

        // Drum loop: She Past Away style — minimal, hypnotic, syncopated
        Routine({
            var pos = 0.0;
            var halfBeat = beat * 0.5;
            loop {
                // Beat 1: kick
                Synth(\kick, [amp: 0.2]);
                Synth(\kannonBeat, [\bufnum, b, \amp, 0.5, \pos, pos, \dur, beat * 0.9]);
                halfBeat.wait;
                Synth(\hihat, [amp: 0.25, dur: 0.04]);
                halfBeat.wait;

                // Beat 2: hihat
                Synth(\hihat, [amp: 0.25, dur: 0.05]);
                Synth(\kannonBeat, [\bufnum, b, \amp, 0.3, \pos, pos, \dur, beat * 0.9]);
                halfBeat.wait;
                halfBeat.wait;

                // Beat 3: kick + snare
                Synth(\kick, [amp: 0.1]);
                Synth(\snare, [amp: 0.03]);
                Synth(\kannonBeat, [\bufnum, b, \amp, 0.5, \pos, pos, \dur, beat * 0.9]);
                halfBeat.wait;
                Synth(\hihat, [amp: 0.2, dur: 0.03]);
                halfBeat.wait;

                // Beat 4: snare
                Synth(\snare, [amp: 0.01]);
                Synth(\kannonBeat, [\bufnum, b, \amp, 0.3, \pos, pos, \dur, beat * 0.9]);
                halfBeat.wait;
                Synth(\hihat, [amp: 0.3, dur: 0.06]);
                halfBeat.wait;

                pos = (pos + 0.001).wrap(0.0, 0.9);
            }
        }).play;

        // droneBurst: trigger-άρεται κάθε 2 μέτρα, συγχρονισμένο με το drum loop
        Routine({
            var pos = 0.3;
            loop {
                (beat * 8).wait;  // κάθε 2 μέτρα (8 beats)
                Synth(\droneBurst, [
                    \bufnum, b,
                    \amp, rrand(0.15, 0.25),
                    \pos, pos,
                    \dur, beat * rrand(3.0, 6.0)
                ]);
                pos = (pos + rrand(0.05, 0.15)).wrap(0.2, 0.9);
            }
        }).play;
    });
});
)

