[[δημιουργία ήχου/drum loop_creation]]

s.boot;
(
{
    var mod, osc, rhythm, env, sig, rate, meter, accent;

    // DRONE
    mod = SinOsc.kr(2.02).range(0.01, 80);
    osc = SinOsc.ar(mod, 6, 3);

    // fake meter clock (σαν "1 του μέτρου") τυχαία συμπεριφορά
    meter = Impulse.kr(2); // κάθε 0.5 sec περίπου

    // random rhythm - tempo που αλλάζει συνεχώς
    rate = TRand.kr(3, 8, Dust.kr(10));
    rhythm = Impulse.kr(rate);

    // accent: με πιθανότητα να “πέσει πάνω στο 1” ψευδο μέτρο
    accent = meter + (WhiteNoise.kr() > 0.5);

    // envelope - περιβάλλουσα ήχου
    env = Decay2.kr(rhythm + accent, 0.2, 2.8);

    // sound layer - βρώμικο texture - οχι καθαρος τονος
    sig = Saw.ar(mod * LFNoise1.kr(1.6).range(0.8, 1.5), 1.15) * env;

    // boost στο accent - ενταση σε καποια hits
    sig = sig * (2 + (accent * 3));

    // mix - ενωση drone με ρυθμό
    sig = osc + sig;

	// DELAY
sig = CombC.ar(sig, 2.3, 1.7, 1.2);

    // space - χωρος
    sig = FreeVerb.ar(sig, 1, 0.70);

	// FADE IN
sig = sig * EnvGen.kr(Env.linen(300, 0, 0), doneAction: 1 );

    sig = sig * 0.3; //ενταση - μιξη

    sig ! 2; //στελνει ηχο σε 2 καναλια
}.play;
)
