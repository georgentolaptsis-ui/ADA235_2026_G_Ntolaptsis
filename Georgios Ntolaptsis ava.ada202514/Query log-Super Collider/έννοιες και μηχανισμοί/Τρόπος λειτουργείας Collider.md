[[Βασικές έννοιες]]

Το SuperCollider είναι ένα από τα πιο ισχυρά περιβάλλοντα για ηχητική σύνθεση και αλγοριθμική σύνθεση μουσικής. Ας ξεκινήσουμε με μια οπτική επισκόπηση της αρχιτεκτονικής του.

![[supercollider_architecture.svg|697]]
![[Pasted image 20260508105746.png]]

Το SuperCollider αποτελείται από δύο βασικά κομμάτια που επικοινωνούν μεταξύ τους: τη γλώσσα **sclang** και τον ηχητικό server scsynth.

---

### Βασικές έννοιες

**sclang** είναι η γλώσσα προγραμματισμού — εκεί γράφεις κώδικα. Επικοινωνεί με τον server μέσω OSC (Open Sound Control) μηνυμάτων.

**scsynth** είναι ο πραγματικός ηχητικός κινητήρας — τρέχει σε ξεχωριστή διαδικασία, επεξεργάζεται τον ήχο σε πραγματικό χρόνο.


### Τα κυριότερα UGen (Unit Generators)

**Ταλαντωτές:** `SinOsc`, `Saw`, `Pulse`, `LFTri` — παράγουν κυματομορφές

**Φίλτρα:** `LPF`, `HPF`, `BPF`, `Resonz` — φιλτράρουν το σήμα

**Envelopes:** `EnvGen` + `Env.adsr`, `Env.perc` — διαμορφώνουν την ένταση

**Εφέ:** `FreeVerb`, `CombL`, `AllpassN` — reverb/delay

**Noise:** `WhiteNoise`, `PinkNoise`, `BrownNoise`

### s.sync

Είναι μια εντολή που λέει στον κώδικα: **"περίμενε μέχρι ο server να τελειώσει αυτό που κάνει, και μετά συνέχισε"**.
Θυμήσου από το διάγραμμα ότι sclang και scsynth είναι **δύο χωριστά προγράμματα** που επικοινωνούν με μηνύματα. Αυτό σημαίνει ότι δεν συγχρονίζονται αυτόματα.
Μεταξύ των γραμμών συνδέει όλα τα synth και τα buffer.
### Πρέπει να είναι μέσα σε Routine

Σημαντικό: το `s.sync` **δεν δουλεύει** στο κανονικό περιβάλλον — χρειάζεται να είναι μέσα σε `Routine` ή `fork`

### fork

Είναι συντομογραφία για "τρέξε αυτό τον κώδικα σε ξεχωριστό νήμα (Routine) παράλληλα με τα υπόλοιπα".
Χωρίς `fork`, ο κώδικας τρέχει γραμμή-γραμμή και το `wait` θα **πάγωνε** όλο το πρόγραμμα. Με `fork` κάθε μπλοκ έχει τη δική του "ζωή"

### Buffer

Είναι μια **περιοχή μνήμης στον server** που αποθηκεύει ήχο. Σκέψου το σαν ένα "δοχείο" που γεμίζεις με samples
Ομαλότητα στις καθυστερήσεις 
Μνήμη εφεδρική
Μνήμη που περιέχει δεδομένα που θέλουμε να έχουμε γρήγορη πρόσβαση

> [!question] το wait for boot δημιουργεί ρουτίνα (routine)?

**Όχι**, το `s.waitForBoot` δεν δημιουργεί Routine — αλλά **δέχεται μια συνάρτηση** που τρέχει αυτόματα μόλις ο server είναι έτοιμος.
Η συνάρτηση `{ }` μέσα τρέχει **αυτόματα σε Routine** — το SuperCollider το κάνει για σένα εσωτερικά. Γι' αυτό μπορείς να βάλεις `s.sync` και `wait` μέσα χωρίς να χρειαστείς εσύ να γράψεις `.fork`.

### Η διαφορά τους σε μία γραμμή

|εντολή|boot;|δημιουργεί Routine;|
|---|---|---|
|`s.waitForBoot`|αν χρειαστεί|ναι, εσωτερικά|
|`.fork`|όχι|ναι|
|`Routine({}).play`|όχι|ναι, χειροκίνητα|

Το `waitForBoot` είναι ουσιαστικά **ένα βολικό περιτύλιγμα** που κάνει boot + Routine μαζί σε ένα βήμα.

### Pbind

Είναι ένας τρόπος να **περιγράψεις μουσική σαν λεξικό παραμέτρων** — συνδέει τιμές με παραμέτρους του SynthDef και τις παίζει στον χρόνο.

Το "P" σημαίνει Pattern, το "bind" σημαίνει "δέσιμο" — δένει παραμέτρους με τιμές.

a = {};

7:26 μ.μ.

 
 
 
 > [!question] 
 > a = {.....}
 
 Αυτό είναι απλώς αποθήκευση μιας κενής συνάρτησης σε μεταβλητή.

Αυτό είναι απλώς **αποθήκευση μιας κενής συνάρτησης σε μεταβλητή**.

---

supercollider

```supercollider
a = {};
```

Το `a` τώρα περιέχει μια **Function** που δεν κάνει τίποτα — είναι κενή.

---

### Τι μπορείς να κάνεις μετά

supercollider

```supercollider
// Ορισμός
a = { "γεια".postln };

// Εκτέλεση
a.value;   // → "γεια"

// Ή με παραμέτρους
a = { |x| x * 2 };
a.value(5);  // → 10
```

---

### Σε σχέση με το SuperCollider

Το `a` είναι μια **global μεταβλητή** — ένα γράμμα μόνο του (a-z) είναι πάντα global στο SuperCollider, ορατό παντού στο πρόγραμμα.

supercollider

a = { SinOsc.ar(440) };  // αποθήκευσε τη συνάρτηση
a.play;                   // τώρα παίξε την
a.value;                  // ή εκτέλεσέ την χωρίς audio



> [!question] το phase τι είναι, και τι εφαρμογή έχει σε ένα synthDef?

### Phase (Φάση)

Είναι η **θέση** ενός κύματος στον κύκλο του — πού βρίσκεται το κύμα τη δεδομένη στιγμή.

Σκέψου το σαν ένα ρολόι:

- `0` = 12η ώρα (αρχή)
- `pi` = 6η ώρα (μέση)
- `2pi` = 12η ώρα πάλι (ένας πλήρης κύκλος)

---

### Στο SuperCollider

supercollider

```supercollider
SinOsc.ar(freq, phase, mul, add)
//              ^^^^
//              εδώ ορίζεις τη φάση
```

supercollider

```supercollider
SinOsc.ar(440, 0)        // αρχίζει από 0
SinOsc.ar(440, pi)       // αρχίζει από τη μέση
SinOsc.ar(440, pi/2)     // αρχίζει από την κορυφή
```

---

### Εφαρμογές σε SynthDef

**1. Stereo πλάτος — δύο κύματα με διαφορά φάσης:**

supercollider

```supercollider
SynthDef(\wideSine, {
    var left  = SinOsc.ar(440, 0);
    var right = SinOsc.ar(440, pi/3);  // λίγο διαφορετική φάση
    Out.ar(0, [left, right] * 0.3)     // ακούγεται "πλατύ"
}).add;
```

**2. Phase Modulation — ο ήχος του FM synthesis:**

supercollider

```supercollider
SynthDef(\fmSynth, { |freq = 440, modDepth = 3|
    var mod = SinOsc.ar(freq * 2) * modDepth;  // modulator
    var sig = SinOsc.ar(freq, mod);             // φάση = mod!
    Out.ar(0, sig * 0.3)
}).add;
```

Αυτό είναι το **FM synthesis** — η φάση αλλάζει συνεχώς από έναν άλλο oscillator και δημιουργεί πλούσιο ήχο.

**3. Phase LFO — κινούμενο stereo:**

supercollider

```supercollider
SynthDef(\phaseSweep, {
    var phase = SinOsc.kr(0.5).range(0, 2pi);  // φάση που κινείται
    var sig   = SinOsc.ar(440, phase);
    Out.ar(0, sig ! 2 * 0.3)
}).add;
```

**4. Phaser effect:**

supercollider

```supercollider
SynthDef(\phaser, { |freq = 440|
    var sig    = Saw.ar(freq);
    var phase  = SinOsc.kr(0.3).range(0, 2pi);
    var phased = AllpassC.ar(sig, 0.02, phase * 0.01, 0);
    Out.ar(0, (sig + phased) * 0.3 ! 2)
}).add;
```
> [! question] 
> sig = signal σωστα?

Ναι, ακριβώς!

`sig` είναι απλώς **σύντμηση του "signal"** — είναι σύμβαση που χρησιμοποιούν σχεδόν όλοι στο SuperCollider για να ονομάζουν το ηχητικό σήμα μέσα σε ένα SynthDef.

---

supercollider

```supercollider
SynthDef(\example, {
    var sig;              // το σήμα - signal
    sig = SinOsc.ar(440); // δημιουργία σήματος
    sig = sig * 0.5;      // επεξεργασία σήματος
    sig = LPF.ar(sig, 800); // φιλτράρισμα σήματος
    Out.ar(0, sig)        // έξοδος σήματος
});
```

