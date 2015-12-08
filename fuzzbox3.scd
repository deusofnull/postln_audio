s.boot;

(
Server.default.makeGui;
s.meter;
s.scope;
)

(
SynthDef.new(\fuzzboxFM, {
	arg pan = 0, amp = 0.5,
	freq=440, modAmp=0.5, modAdd=250,
	atk = 0.01, rel = 1;
	var modSig, outSig, env;

	env = EnvGen.kr(Env.perc(
		atk,
		rel, level:1, curve:-10), doneAction:2);

	// Frequency Modulation
	modSig = SinOsc.ar(freq, mul:modAmp, add:modAdd);
	outSig = SinOsc.ar(modSig, mul:amp);

	outSig = Pan2.ar(outSig, pan, amp);
	outSig = outSig * env;
	Out.ar(0, outSig);
}).add;
)

a = Scale.minor;
a.degrees.midicps;

(
Pdef(\fuzzTest,
	Pbind(
		\instrument, \fuzzboxFM,
		\dur, 0.5,
		\freq, 440,
		\modAmp, 0.5,
		\modAdd, Pseq([200,250, 300],inf),
		\atk, 0.05,
		\rel, 0.5,
		\amp, 0.3,
	);
);
)

Pbindf(Pdef(\fuzzTest)).play;
Synth.new(\fuzzboxFM);

(
SynthDef.new(\distort, {
	arg in, out =0, pregain=40, amp=0.2, gate=1;

	var env, sig;

	sig = In.ar(in,2);

	sig = (sig * pregain).distort * amp;

	env = Linen.kr(gate, 0.05, 1, 0.1, 2);

	Out.ar(out, sig);
}).add;
)



(
d = Synth.new(\distort, [
	\in, 0,
	\pregain, 120,
]);
)
d.set(\pregain, 100);
d.free;

Pbindf(Pdef(\fuzzTest)).play;
(
SynthDef.new(\reverb, {
	arg in, out =0, wet=0.5, size=0.5, damp=0.2 ;
	var env, sig;
	sig = In.ar(in,2);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);
	Out.ar(out, sig);
}).add;
)

(
r = Synth.new(\reverb, [
	\in, 0,
	\wet, 0.4,
	\size, 0.8,
	\damp, 0.6,
]);
)

r.set(\wet, 0.9);
r.set(\size, 0.9);
r.set(\damp, 0.9);

r.free;






("fuzz1 quant = " + Pdef(\fuzz1).quant).postln; // just remind me what the quantization factor is
)

(
Pdef(\fuzz1,
	Pbind(
		\instrument, \fuzzboxFM,
		\dur, 0.15,
		\freq, 2000,
		\modAmp, 100,
		//\modAdd, Pseq([60,70, 80],inf).midicps,
		\modAdd, Pexprand(60,70,inf).midicps / 2,
		\atk, 0.05,
		\rel, Pexprand(0.5,10,inf),
	);
);
("fuzz1 quant = " + Pdef(\fuzz1).quant).postln; // just remind me what the quantization factor is
)
Pdef(\fuzz1).quant=1;



// Starting above Pdef
Pbindf(Pdef(\fuzz1)).play;

// manipulating \fuzz1 live


(
Pdef(\fuzz1,
	Pbind(
		\instrument, \fuzzboxFM,
		\dur, 0.3,
		\freq, 60,
		\modAmp, 60,
		\modAdd, Pseq([50,52, 53],inf).midicps,
		\atk, 0.05,
		\rel, 0.5,
		\amp, 0.2,
	);
);
("quant = " + Pdef(\fuzz1).quant).postln; // just remind me what the quantization factor is
Pdef(\fuzz1).quant=0.9;
)

//============================ Fuzz Major ======================================================
// ======Starting Fuzz Major
Pbindf(Pdef(\fuzzMajor)).play;
(
Pdef(\fuzzMajor,
	Pbind(
		\instrument, \fuzzboxFM,
		\dur, 0.3,
		\freq, Pexprand(200,1000,inf),
		\modAmp, Pexprand(300, 500,inf),
		\modAdd, Pxrand([60, 62, 64, 65, 67, 69, 71, 72], inf).midicps, // C60 major
		//\modAdd, Pxrand([65, 67, 69, 70, 72, 74, 76, 78], inf).midicps, // F65 major
		\atk, 0.05,
		\rel, 5,
		\amp, 0.17,

	);
);
("quant = " + Pdef(\fuzzMajor).quant).postln; // just remind me what the quantization factor is
Pdef(\fuzzMajor).quant=2.4;
)

(
u = Pbind( // Pbind generates event
	\type, \note, // default event type
	\instrument, \sine,
	\dur, Pwhite(0.05, 0.5, inf),  // Pwhite generates random number with linear distribution
	\midinote, 35,
	\harmonic, Pexprand(1,80, inf).round.trace, // play to harmonic note between 1st and 80th partial harmonic
	\atk, Pwhite(2.0,3.0, inf),
	\rel, Pwhite(5.0,10.0, inf),
	\amp, Pkey(\harmonic).reciprocal * 0.3,  // make the amp = reciprocal of partial number, making higher partials quieter
	\pan, Pwhite( -0.8, 0.8, inf),
).play;
)

(
SynthDef.new(\sine, {
	arg freq = 440, atk = 0.005, rel=0.3, amp = 0.5, pan = 0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1,-1]), doneAction:2);
	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;
	Out.ar(0,sig);
}).add;
)

