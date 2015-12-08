(
Server.default.makeGui;
s.meter;
s.plotTree;
s.scope;
)

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
~rev = Synth.new(\reverb, [
	\in, 0,
	\wet, 0.4,
	\size, 0.8,
	\damp, 0.6,
]);
)

~rev.set(\wet, 0.9);
~rev.set(\size, 0.9);
~rev.set(\damp, 0.9);

r.free;


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
	\pregain, 10,
]);
)
d.set(\pregain, 30); // increase gradually
d.free;




(
SynthDef.new(\FM, {
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
Pdef(\FMsynth).quant = 0.16 * 6;

(
Pdef(\FMsynth,
	Pbind(
		\instrument, \FM,
		\dur, 0.16,
		\freq, 50 ,
		\modAmp, 2000,
		//\modAdd, Pseq([200, 250, 300],inf),
		\modAdd, Pseq([180, 230, 280, 180, 250, 280],inf),
		//\modAdd, Pseq([320, 400, 200],inf),
		\atk, 0.05,
		\rel, 0.2,
		\amp, 0.3,
	);
);
)
Pbindf(Pdef(\FMsynth)).play;


(
SynthDef.new(\FMgang, {
	arg pan = 0, amp = 0.5,
	freq=440, modAmp=0.5, modAdd=250, fund=440, arp_speed=5, arp_range=5,
	atk = 0.01, rel = 1;
	var modSig, outSig, env;

	env = EnvGen.kr(Env.perc(
		atk,
		rel, level:1, curve:-10), doneAction:2);

	// Frequency Modulation
	freq = LFNoise0.kr(arp_speed).exprange(fund/arp_range, fund*arp_range).round(fund);
	modSig = SinOsc.ar(freq, mul:modAmp, add:modAdd);
	outSig = SinOsc.ar(modSig, mul:amp);

	outSig = Pan2.ar(outSig, pan, amp);
	outSig = outSig * env;
	Out.ar(0, outSig);
}).add;
)


(
Pdef(\FMpanoply,
	Pbind(
		\instrument, \FMgang,
		\dur, 2.5,
		\freq, 60,
		\modAmp, 500,
		//\modAdd, Pseq([200, 250, 300],inf),
		//\fund, Pxrand([60, 62, 64, 65, 67, 69, 71, 72], inf).midicps,
		\arp_speed, 70,
		\arp_range, 15,
		//\fund, Pxrand([60,62,63,65,67,68,71,72], inf).midicps,  // C5 harmonic minor
		//\fund, Pxrand([55,57,58,60,62,63,66,67],inf).midicps,     // G4 harmonic minor
		\fund, Pseq([51,53,54,56,58,59,62,63], inf).midicps,  // Eb4 harmonic minor
		//\fund, Pxrand([
		\modAdd, Pkey(\fund),
		//\modAdd, Pseq([320, 400, 200],inf),
		\atk, 2.5,
		\rel, 2.5,
		\amp, 0.3,
	);
);
)

Pbindf(Pdef(\FMparty)).play;
s.boot;
s.quit;


