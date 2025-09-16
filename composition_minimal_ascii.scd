(
s.waitForBoot({

	var scale, root, clock, pMel, pPad, piece, duration;

	// basics
	clock = TempoClock.new(70/60);
	scale = Scale.aeolian;
	root  = 9; // A minor feel

	// synths
	SynthDef(\mel, { |out=0, freq=220, amp=0.12, pan=0, atk=0.01, rel=0.6|
		var env = EnvGen.kr(Env.perc(atk, rel), doneAction:2);
		var sig = (SinOsc.ar(freq) * 0.6) + (Saw.ar(freq*0.5) * 0.4);
		sig = sig * env * amp;
		sig = FreeVerb.ar(sig, 0.3, 0.9, 0.4);
		Out.ar(out, Pan2.ar(sig, pan));
	}).add;

	SynthDef(\pad, { |out=0, freq=220, amp=0.07, pan=0|
		var src = Mix(Saw.ar(freq * [0.99, 1.0, 1.006]));
		src = RLPF.ar(src, 1400, 0.35);
		src = src * EnvGen.kr(Env.asr(2.0, 1.0, 5.5), doneAction:2);
		src = FreeVerb.ar(src, 0.25, 0.9, 0.4);
		Out.ar(out, Pan2.ar(src * amp, pan));
	}).add;

	s.sync;

	// patterns
	pMel = Pbind(
		\instrument, \mel,
		\scale,  scale,   \root, root,
		\degree, Pwrand([0,2,3,5,7,9,10],[0.15,0.12,0.18,0.22,0.16,0.10,0.07], inf),
		\octave, Pwrand([4,5,6],[0.55,0.35,0.10], inf),
		\dur,    Pwrand([0.25,0.5,0.75,1,1.5],[0.25,0.35,0.15,0.2,0.05], inf),
		\rel,    Pwhite(0.35, 0.8, inf),
		\amp,    Pwhite(0.07, 0.13, inf),
		\pan,    Pwhite(-0.6, 0.6, inf)
	);

	pPad = Pbind(
		\instrument, \pad,
		\scale, scale, \root, root,
		\degree, Pseq([0,5,3,7,2,6,0], inf),
		\octave, 4,
		\dur, 4,
		\amp, 0.055,
		\pan, Pwhite(-0.25, 0.25, inf)
	);

	piece = Ppar([pPad, pMel], 1);
	~player = piece.play(clock);

	// auto stop
	duration = 170; // ~2.8 minutes
	SystemClock.sched(duration, {
		if(~player.notNil) { ~player.stop; };
		"Composition finished.".postln;
		nil
	});

});
)
