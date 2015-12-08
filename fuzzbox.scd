s.boot;
s.scope;

(
s.plotTree;
s.meter;
Server.default.makeGui;
FreqScope.new;)

/* synthesis techniques article:

 http://www.berkeleynoise.com/celesteh/code/tutorials/supercollider05 synthesis techniques.pdf
*/
(
SynthDef.new(\fuzzboxRM, {
	arg freq=190, pan = 0, amp = 0.5, modFreq=50, modAmp=0.5,
	atk = 0.01, rel = 1;
	var carSig, modulator, outSig, env;

	env = EnvGen.kr(Env.perc(
		atk,
		rel), doneAction:2);

	// Ring Modulation
	modulator = SinOsc.ar(modFreq, mul:modAmp);
	outSig = SinOsc.ar(freq, mul: modulator * amp);

	outSig = Pan2.ar(outSig, pan, amp);
	outSig = outSig * env;
	Out.ar(0, outSig);
}).add;
)

Synth.new(\fuzzboxRM, [\freq, 340, \modFreq, 500,\amp, 0.8,\atk, 0.1, \rel, 0.1]);
Synth.new(\fuzzboxRM, [\freq, 60, \modFreq, 500,\amp, 0.8,\atk, 0.1, \rel, 0.1]);

// if carrier freq is modulated by a linear frequency (proportional), then the new wave will remain harmonic


/* for AM synthesis
We divide the modulator signal by two to halve its amplitude. Then we add 0.5
to it so that it centers on 0.5 instead of on zero
*/
(
SynthDef.new(\fuzzboxAM, {
	arg freq=190, pan = 0, amp = 0.5, modFreq=50, modAmp=0.5,
	atk = 0.01, rel = 1;
	var carSig, modSig, outSig, env;

	env = EnvGen.kr(Env.perc(
		atk,
		rel), doneAction:2);

	// Amplitude Modulation
	modSig = SinOsc.ar(modFreq, mul:modAmp/2, add:0.5);
	outSig = SinOsc.ar(freq, mul: modSig * amp);

	outSig = Pan2.ar(outSig, pan, amp);
	outSig = outSig * env;
	Out.ar(0, outSig);
}).add;
)

Synth.new(\fuzzboxAM, [\freq, 300, \modFreq, 190,\amp, 0.8,\atk, 1.5, \rel, 0.5]);


/* for FM synthesis
carrier frequency is modulated by the modulator signal
Think Vibrato
  modAdd is the center frequency of the vibrato
  modAmp controls the depth of the vibrato
  modFreq controls the speed of the vibrato
*/
// env testing:

Env.perc(1,0.01, level:1, curve:10).plot;
Env.perc(3,2, level:1, curve:-10).plot;

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

Synth.new(\fuzzboxFM, [\amp, 0.5,\atk, 1.5, \rel, 1, \modAmp, 600, \modFreq, 100, \modAdd, 45]);



// playing with my fuzzboxFM
(
p = Pxrand([20, 22, 24, 30, 32, 34, 40, 42, 44], inf).asStream;
// ordered sequence of durations
q = Pseq([1/2, 2, 1/8], inf).asStream;
t = Task({
	loop({
		x.release(2);
		x = Synth.new(\fuzzboxFM, [\amp, 0.5,\atk, 1.5, \rel, 1, \modAmp, 600, \modFreq, 100, \modAdd, p.value.midicps]);
		q.value.wait;
	});
});
t.start;
)
t.stop; x.release(2);
// live control of the modAdd center frequency
p = Pxrand([11, 12, 14, 16, 17, 19, 21, 23], inf).asStream;
// live control of the delay between synth creations
q = Pseq([3, 5, 1], inf).asStream;

// 60 = C4

(
p = Pseq([60,62,65,67,69,71,72,74], inf).asStream;
q = Pseq([0.1], inf).asStream;
t = Task({
	var modAmp = 10;
	loop ({
		modAmp.postln;
		x = Synth.new(\fuzzboxFM, [\amp, 0.5,\atk, 0.05, \rel, 0.05, \modAmp, modAmp, \modFreq, 500, \modAdd, p.value.midicps]);
		q.value.wait; // rest
		modAmp = modAmp + 15;
	});
});
t.start;
)
t.stop;


p = Pseq([0,2,5,7,9,11,12,14], inf).asStream;

(
p = Pxrand([0,2,5,7,9,11,12,14], inf).asStream; // major
q = Pseq([0.1], inf).asStream;
t = Task({
	var modAmp = 10, baseNote = 20, modAmpDelta = 200, curFreq = 0;
	loop ({
		// get the next note
		curFreq = (baseNote + p.value).midicps;
		// get random modAmp
		modAmp = rrand(10,15000);
		["modAmp", modAmp].postln;
		["curFreq", curFreq.cpsmidi].postln;

		// x = Synth.new(\fuzzboxFM, [\amp, 0.5,\atk, 0.05, \rel, 0.5, \modAmp, modAmp, \modFreq, 500, \modAdd, curFreq ]);
		//  extra release bleedover
		// x = Synth.new(\fuzzboxFM, [\amp, 0.5,\atk, 0.05, \rel, 0.75, \modAmp, modAmp, \modFreq, 500, \modAdd, curFreq ]);
		// more release, more stacking, more weirdness
		x = Synth.new(\fuzzboxFM, [\amp, 0.3,\atk, 0.05, \rel, 5, \modAmp, modAmp, \modFreq, 500, \modAdd, curFreq ]);

		q.value.wait; // rest
	});
});
t.start;
)



// Arpegiator kinda thing
(
p = Pseq([0,2,3,5,7,9,11,12], inf).asStream; // minor
q = Pseq([1], inf).asStream;
t = Task({
	var modAmp = 500, baseNote = 60, modAmpDelta = 200, curFreq = 0;
	loop ({
		// get the next note
		curFreq = (baseNote + p.value).midicps;
		// flip a coin, + or - it to modAmp
		if (0.5.coin,
			{modAmp = modAmp + rrand(10,300)},
			{modAmp = modAmp - rrand(10,300)}
		);

		["modAmp", modAmp].postln;
		["curFreq", curFreq].postln;

		x = Synth.new(\fuzzboxFM, [\amp, 0.5,\atk, 0.5, \rel, 0.5, \modAmp, modAmp, \modFreq, 500, \modAdd, curFreq ]);
		q.value.wait; // rest
	});
});
t.start;
)



// Percussion thing

Synth.new(\fuzzboxFM, [\amp, 0.3,\atk, 0.05, \rel, 5, \modAmp, 500, \modFreq, 500, \modAdd, 40.midicps ]);
Synth.new(\fuzzboxFM, [\amp, 0.3,\atk, 0.05, \rel, 5, \modAmp, 500, \modFreq, 500, \modAdd, 55.midicps ]);

// rubberband on the beat
(
p = Pseq([55,40,60,40], inf).asStream; // major
//q = Pseq([1/2, 1/4, 1/4, 1, 1/8, 1/8, 1/8, 1/8], inf).asStream;
q = Pseq([1], inf).asStream;
t = Task({
	var modAmp = 500, baseNote = 0, modAmpDelta = 200, curFreq = 0;
	loop ({
		// get the next note
		curFreq = (baseNote + p.value).midicps;
		// get random modAmp
		//modAmp = rrand(10,15000);
		["modAmp", modAmp].postln;
		["curFreq", curFreq.cpsmidi].postln;

		x = Synth.new(\fuzzboxFM, [\amp, 0.3,\atk, 0.05, \rel, 1.75, \modAmp, modAmp, \modFreq, 10, \modAdd, curFreq ]);

		q.value.wait; // rest
	});
});
t.start;
)

(
p = Pseq([70], inf).asStream; // major
//q = Pseq([1/2, 1/4, 1/4, 1, 1/8, 1/8, 1/8, 1/8], inf).asStream;
q = Pseq([4], inf).asStream;
t = Task({
	var modAmp = 500, baseNote = 0, modAmpDelta = 200, curFreq = 0;
	loop ({
		// get the next note
		curFreq = (baseNote + p.value).midicps;
		// get random modAmp
		//modAmp = rrand(10,15000);
		["modAmp", modAmp].postln;
		["curFreq", curFreq.cpsmidi].postln;

		x = Synth.new(\fuzzboxFM, [\amp, 0.3,\atk, 0.05, \rel, 1.75, \modAmp, modAmp, \modFreq, 10, \modAdd, curFreq ]);

		q.value.wait; // rest
	});
});
t.start;
)

Synth.new(\fuzzboxFM, [\amp, 0.3,\atk, 0.09, \rel, 3, \modAmp, 8000, \modFreq, 60, \modAdd, 113.midicps ]);


// lots together:

// rubberband on the beat
(
~a1 = Pseq([55,40,60,40], inf).asStream;
//q = Pseq([1/2, 1/4, 1/4, 1, 1/8, 1/8, 1/8, 1/8], inf).asStream;
~b1 = Pseq([2], inf).asStream;
~t1 = Task({
	var modAmp = 500, baseNote = 0, modAmpDelta = 200, curFreq = 0;
	loop ({
		// get the next note
		curFreq = (baseNote + ~a1.value).midicps;
		// get random modAmp
		//modAmp = rrand(10,15000);
		["modAmp", modAmp].postln;
		["curFreq", curFreq.cpsmidi].postln;

		x = Synth.new(\fuzzboxFM, [\amp, 0.3,\atk, 0.05, \rel, 1.75, \modAmp, modAmp, \modFreq, 10, \modAdd, curFreq ]);

		~b1.value.wait; // rest
	});
});
~t1.start;
)



~a2 = Pxrand([113], inf).asStream; // baseNote
~b2 = Pseq([4], inf).asStream; // rest
~c3 = Pxrand([8000,9000,10000,11000],inf).asStream; //modAmp
~t2 = Task({
	var modAmp = 500, baseNote = 0, curFreq = 0;
	1.wait;
	loop ({
		// get the next note
		curFreq = (baseNote + ~a2.value).midicps;
		x = Synth.new(\fuzzboxFM, [\amp, 0.3,\atk, 0.05, \rel, 5, \modAmp, ~c3.value, \modFreq, 500, \modAdd, curFreq ]);

		~b2.value.wait; // rest
	});
});
~t2.start;

// Arpegiator kinda thing
(
~a3 = Pxrand([0,2,5,7,9,11,12,14], inf).asStream; // major
~b3 = Pseq([1/4], inf).asStream;
~t3 = Task({
	var modAmp = 300, baseNote = 40, modAmpDelta = 200, curFreq = 0;
	loop ({
		// get the next note
		curFreq = (baseNote + ~a3.value).midicps;
		// flip a coin, + or - it to modAmp
		if (0.5.coin,
			{modAmp = modAmp + rrand(10,20)},
			{modAmp = modAmp - rrand(10,20)}
		);
		 ~x3 = Synth.new(\fuzzboxFM, [\amp, 0.5,\atk, 0.05, \rel, 0.5, \modAmp, modAmp, \modFreq, 500, \modAdd, curFreq ]);
		//  extra release bleedover
		// x = Synth.new(\fuzzboxFM, [\amp, 0.5,\atk, 0.05, \rel, 0.75, \modAmp, modAmp, \modFreq, 500, \modAdd, curFreq ]);
		// more release, more stacking, more weirdness
		//~x3 = Synth.new(\fuzzboxFM, [\amp, 0.3,\atk, 0.05, \rel, 5, \modAmp, modAmp, \modFreq, 500, \modAdd, curFreq ]);

		~b3.value.wait; // rest
	});
});
~t3.start;
)

~a1 = Pseq([50,60,70,80,90,100,120,140], inf).asStream;
~a3 = Pxrand([50,60,70,80,90,100,120,140], inf).asStream; // major

~b3 = Pseq([1/32],inf).asStream;
~x3.set(\rel, 1.5);
~x3.set(\modFreq, rrand(50,200));
~x3.set(\modFreq, 50);

// Arpegiator patterns

// major
~a3 = Pseq([0,2,5,7,9,11,12,14], inf).asStream;
// minor
~a3 = Pseq([50,100], inf).asStream;
// strange harmonics
~a3 = Pseq([80,60,40,20,0,100,50,70], inf).asStream;

~b2 = Pexprand(2,4, inf)



// turn this into a proper Pdef / Pbind / Routine
(
~a3 = Pxrand([0,2,5,7,9,11,12,14], inf).asStream; // major
~b3 = Pseq([1/4], inf).asStream;
~t3 = Task({
	var modAmp = 300, baseNote = 40, modAmpDelta = 200, curFreq = 0;
	loop ({
		// get the next note
		curFreq = (baseNote + ~a3.value).midicps;
		// flip a coin, + or - it to modAmp
		if (0.5.coin,
			{modAmp = modAmp + rrand(10,50)},
			{modAmp = modAmp - rrand(10,50)}
		);
		 ~x3 = Synth.new(\fuzzboxFM, [\amp, 0.5,\atk, 0.05, \rel, 0.5, \modAmp, modAmp, \modFreq, 500, \modAdd, curFreq ]);
		//  extra release bleedover
		// x = Synth.new(\fuzzboxFM, [\amp, 0.5,\atk, 0.05, \rel, 0.75, \modAmp, modAmp, \modFreq, 500, \modAdd, curFreq ]);
		// more release, more stacking, more weirdness
		//~x3 = Synth.new(\fuzzboxFM, [\amp, 0.3,\atk, 0.05, \rel, 5, \modAmp, modAmp, \modFreq, 500, \modAdd, curFreq ]);

		~b3.value.wait; // rest
	});
});
~t3.start;
)
~b3 = Pseq([1/128], inf).asStream;
~a3 = Pexprand(20,60).asStream;

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

s.boot;
Server.default.makeGui


~a3 = Pexprand(1,100).asStream;
~modFreq3 = 10;
(
~modFreq3 = 1000;
~b3 = Pseq([1/128], inf).asStream;
~a3 = Pexprand(1,50).asStream;
)

(
~modFreq3 = 85;
~b3 = Pseq([1/128], inf).asStream;
~a3 = Pexprand(1,5).asStream;
)
(
~modFreq3 = 70;
~b3 = Pseq([1/128], inf).asStream;
~a3 = Pexprand(0.9,1.01).asStream;
)
(
~modFreq3 = 70;
~b3 = Pseq([1/128], inf).asStream;
~a3 = Pexprand(5,15).asStream;
)
(
~b3 = Pseq([1/128], inf).asStream;
~a3 = Pexprand(15,30).asStream;
)
~a3 = Pexprand(25,50).asStream;
(
~b3 = Pseq([1/256], inf).asStream;
~a3 = Pexprand(50,59).asStream;
)
(
~b3 = Pseq([1/256], inf).asStream;
~a3 = Pexprand(59,60).asStream;
)
(
~modFreq3 = 50;
~b3 = Pseq([1/128], inf).asStream;
~a3 = Pexprand(60,60.1).asStream;
)
(
~modFreq3 = 45;
~b3 = Pseq([1/128], inf).asStream;
~a3 = Pexprand(60,63).asStream;
)

(
~modFreq3 = 40;
~b3 = Pseq([1/128], inf).asStream;
~a3 = Pexprand(65, 70).asStream;
)
(
~modFreq3 = 70;
~b3 = Pseq([1/64], inf).asStream;
~a3 = Pexprand(70, 72.5).asStream;
)
(
~modFreq3 = 70;
~b3 = Pseq([1/], inf).asStream;
~a3 = Pexprand(73, 73.01).asStream;
)
~modFreq3 = 70;




