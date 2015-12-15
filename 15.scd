s.reboot;
s.quit;
s.plotTree;
(
SynthDef.new(\sin, {
	arg freq = 220, atk = 0.005, rel= 0.3,
	amp = 1, pan = 0,
	ringDivisor = 2, ringFreq= 100, ringMul = 1,
	lowpassFreq = 300, lowpassRQ = 1;
	var sig, env, sig2;

	sig = SinOsc.ar(freq);
	sig2 = Saw.ar(ringFreq, mul:ringMul);
	sig = sig * sig2;

	env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1,-1]), doneAction:2);

	sig = Pan2.ar(sig, pan, amp);

	sig = RLPF.ar(sig, lowpassFreq, lowpassRQ);


	sig = sig * env;

	Out.ar(0,sig);
}).add;
)

Synth.new(\sin);

(
p = Pbind(
	\instrument, \sin,
	\dur, 0.5, // 2 synth per second
	\midinote, Pseq([59, 62, 66], inf), // 1 , 3b, 5  bm
	).play;
)

(
q = Pbind(
	\instrument, \sin,
	\dur, 1, // 2 synth per second
	\midinote, [59, 62, 66, 71], // 1 , 3b, 5  bm
	).play;
)

(
q = Pbind(
	\instrument, \sin,
	\dur, 0.125,
	\midinote, Pseq([
		Pseq([59, 62, 66], 1), // bm  1 , 3b, 5
		Pseq([53, 57, 61], 1), // Fmaj 1, 3, 5
		Pseq([55, 59, 62], 1), // G 1, 3, 5
		Pseq([50, 54, 57], 1),  // Dm 1, 3b, 5
		Pseq([58, 61, 65], 1)   // a#m 1, 3b, 5
	], inf),
	).play;
)

(
q = Pbind(
	\instrument, \sin,
	\dur, 0.125, // 2 synth per second
	\midinote, Pxrand([  // key of bm
		Pseq([59, 62, 66], 1), // bm  1 , 3b, 5
		Pseq([52, 56, 60], 1), // E 1, 3, 5
		Pseq([55, 59, 62], 1), // G 1, 3, 5
		Pseq([50, 54, 57], 1),  // C# 1, 3b, 5
		Pseq([51, 54, 58], 1)   // Dm 1, 3b, 5
	], inf),
	\amp, 0.6,
	\atk, 0.005,
	\rel, 0.03,
	).play;
)

q.stop;


(
Pdef(
	\mypat,
	 Pbind(
		\instrument, \sin,
		\dur, Pexprand(0.125, 0.5, inf),
		\midinote, Pseq([36],inf),
		\harmonic, Pexprand(1, 15, inf).round.trace,
		\ringDivisor, 0.125,
		\atk, Pwhite(0.125, 1.0, inf),
		\rel, Pwhite(0.5, 1.25 ,inf),
		\amp, Pkey(\harmonic).reciprocal * 0.3,
	)
).play;
)

// rhythm

(
Pdef(
	\ringLPF,
	 Pbind(
		\instrument, \sin,
		\dur, Pseq([1/16], inf),
		\stretch, 60/85 * 4,
		\midinote, Pseq([40],inf),
		\harmonic, Pexprand(1, 3, inf),
		\ringFreq, ((Pkey(\midinote) + Pkey(\ctranspose).midicps * Pkey(\harmonic)) / 6.8).trace,
		\ringMul, 2.1,
		\lowpassFreq, Pkey(\ringFreq) * Pexprand(2, 5, inf),
		\lowpassRQ, 0.0001,
		\atk, 0.5,
		\rel, 0.3,
		\amp, Pkey(\harmonic).reciprocal * 0.1,
	)
).play;
)
s.reboot;
Server.default.makeGui;



// THIS IS SOME 15 SHIT


(   // This is the "melody"
Pdef(
	\ringLPFbmVoice,
	Pbind(
		\instrument, \sin,
		\dur, Pseq([1/16], inf),
		\stretch, 60/90 * 4,
		\midinote, Pseq([  // key of bm
			Pseq([59, 62, 66], 2), // bm  1 , 3b, 5
			Pseq([52, 56, 60], 1), // E 1, 3, 5
			Pseq([55, 59, 62], 4), // G 1, 3, 5
			Pseq([50, 54, 57], 1),  // C# 1, 3b, 5
			Pseq([51, 54, 58], 3)   // Dm 1, 3b, 5
		], inf),
		\harmonic, -3,
		\lowpassFreq, Pwhite(200, 250, inf),
		\lowpassRQ, 0.05,   // BE CAREFUL WITH RQ !!!!!!!!!!!!!!!!!!!!!!!!
		\amp, 0.2,
		\atk, 0.02,
		\rel, 0.09,
		\pan, Pwhite(-1,1,inf),
	)
).play;
)



(
Pdef(   // here is some GONG
	\ringLPFbmStretch,
	Pbind(
		\instrument, \sin,
		\dur, Pseq([2], inf),
		\stretch, 60/90 * 4,
		\midinote, Pseq([[59, 62, 66, 69]], inf), // bm  1 , 3b, 5
		\harmonic, -3,
		\lowpassFreq, 400,
		\lowpassRQ, 0.05,
		\amp, 0.2,
		\atk, 0.05,
		\rel, 4,
		\pan, 0,
	)
).play;
)