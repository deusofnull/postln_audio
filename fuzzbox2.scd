(
SynthDef.new(\fuzzboxFM, {
	arg pan = 0, amp = 0.5,
	modFreq=600, modAmp=0.5, modAdd=250,
	atk = 0.01, rel = 1;
	var modSig, outSig, env;

	env = EnvGen.kr(Env.perc(
		atk,
		rel, level:1, curve:-10), doneAction:2);

	// Frequency Modulation
	modSig = SinOsc.ar(modFreq, mul:modAmp, add:modAdd);
	outSig = SinOsc.ar(modSig, mul:amp);

	outSig = Pan2.ar(outSig, pan, amp);
	outSig = outSig * env;
	Out.ar(0, outSig);
}).add;
)

// HorrORSHOW
(
~a3 = Pexprand(1,40).asStream;
~b3 = Pseq([1/128], inf).asStream;
~modFreq3 = 50;
~t3 = Task({
	var modAmp = 300, baseNote = 0, modAmpDelta = 200, curFreq = 0;
	loop ({
		// get the next note
		curFreq = (baseNote + ~a3.value).midicps;
		// flip a coin, + or - it to modAmp
		if (0.5.coin,
			{modAmp = modAmp + rrand(10,50)},
			{modAmp = modAmp - rrand(10,50)}
		);
		// ~x3 = Synth.new(\fuzzboxFM, [\amp, 0.3,\atk, 0.05, \rel, 0.5, \modAmp, modAmp, \modFreq, 500, \modAdd, curFreq ]);
		//  extra release bleedover
		 ~x3 = Synth.new(\fuzzboxFM, [\amp, 0.3,\atk, 0.05, \rel, 0.95, \modAmp, modAmp, \modFreq, ~modFreq3, \modAdd, curFreq ]);
		// more release, more stacking, more weirdness
		//~x3 = Synth.new(\fuzzboxFM, [\amp, 0.3,\atk, 0.05, \rel, 5, \modAmp, modAmp, \modFreq, 500, \modAdd, curFreq ]);

		~b3.value.wait; // rest
	});
});
~t3.start;
)

~t3.stop;
(
~fuzzTest = Synth.new(\fuzzboxFM, [
	\atk, 0.05, \rel, 0.95,
	\modAmp, 1, \modFreq, 200, \modAdd, 93.midicps]);
)

(
~fuzzPat = Pbind( \instrument, \fuzzboxFM,
	\atk, 0.05, \rel, 0.95,
	\dur, 0.5,
	\modAmp, 1,
	\modFreq, 200,
	\modAdd, Pseq([40,50,55], inf).midicps,
).play(quant: 1.875);
)

(
Pdef(\fuzzboxPat,
	Pbind(
		\instrument, \fuzzboxFM,
		\atk, Pexprand(0.5,3,inf), \rel, Pexprand(0.5,3,inf),
		\dur, 5,
		\modAmp, Pexprand(50,1000,inf),
		\modFreq, Pexprand(50,1000,inf),
		\modAdd, Pexprand(40,80, inf).midicps,
	).play;
)
)
(
Pdef(\fuzzbazz,
	Pbind(
		\instrument, \fuzzboxFM,
		\atk, 0.05, \rel, 0.05),
		\dur, 0.1,
		\modAmp, 500,
		\modFreq, 1,
		\modAdd, 55.midicps,
	).play;
)
)

(
Pdef(\fuzzboxPat,
	Pbind(
		\instrument, \fuzzboxFM,
		\amp, 0.8,
		\atk, 0.05, \rel, 3,
		\dur, 0.5,
		\modAmp, 500,
		\modFreq, 10,
		\modAdd, Pseq([70,75,73], inf).midicps,
	).play;
)
)



s.quit;