s.boot;
(
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

SynthDef(\kick, {
    |out=0, amp=0.4|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.01, 0.4), doneAction: 2);
    sig = SinOsc.ar(XLine.kr(120, 40, 0.4)) * env * amp;
    sig = Limiter.ar(sig, 0.9);
    Out.ar(out, sig ! 2);
}).add;

SynthDef(\snare, {
    |out=0, amp=0.5|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.01, 0.18), doneAction: 2);
    sig = PinkNoise.ar() * env * amp;
	sig = sig + (SinOsc.ar(1400) * env * 1.3);  // ← 200hz = body του snare, άλλαξε το pitch εδώ
    sig = HPF.ar(sig, 6000);
	sig = GVerb.ar(sig, 100, 8, 0.5, drylevel: 0.3);
    Out.ar(out, sig ! 2);
}).add;

SynthDef(\hihat, {
    |out=0, amp=0.3, dur=0.06|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.005, dur), doneAction: 2);
    sig = PinkNoise.ar() * env * amp;
    sig = HPF.ar(sig, 4000);
    Out.ar(out, sig ! 2);
}).add;

SynthDef(\arpFM, {
    |out=0, freq=220, modRatio=3, depth=100, amp=1.2, dur=0.12|
    var mod, sig, env;
    env = EnvGen.kr(Env.perc(0.01, dur), doneAction: 2);
    mod = SinOsc.ar(freq * modRatio) * depth;
    sig = SinOsc.ar(freq + mod) * env * amp;
    sig = CombC.ar(sig, 0.5, 0.25, 0.35);  // ← ΕΔΩ το delay
    sig = FreeVerb.ar(sig, 0.8, 0.6);
	sig = GVerb.ar(sig, 100, 8, 0.5, drylevel: 0.3);
    Out.ar(out, sig ! 2);
}).add;


s.waitForBoot({
    var bpm = 120;
    var beat = 60 / bpm;
    var scale = [55, 65.4, 73.4, 82.4, 98, 110, 130.8];

    Routine({
        Synth(\fmDrone, [freq: 55, ratio: 2.02, depth: 80, atk: 8, rel: 2, amp: 1.25]);
    }).play;

    Routine({
        loop {
            Synth(\kick, [amp: 0.4]);
            beat.wait;
            Synth(\hihat, [amp: 0.25, dur: 0.05]);
            beat.wait;
            Synth(\snare, [amp: 0.5]);
            Synth(\hihat, [amp: 0.2, dur: 0.04]);
            beat.wait;
            Synth(\hihat, [amp: 0.3, dur: 0.06]);
            beat.wait;
        }
    }).play;

    Routine({
        (beat * 4).wait;
        loop {
            Synth(\arpFM, [
                freq:     scale.choose,
                modRatio: [2, 3, 5, 7].choose,
                depth:    scale.choose * rrand(0.5, 2.0),
                amp:      rrand(1.15, 0.3),
                dur:      [beat * 0.5, beat, beat * 1.5].choose
            ]);
            [beat * 0.5, beat].choose.wait;
        }
    }).play;
});
)