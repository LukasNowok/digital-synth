/*
Using Ndef as a flexible architecture to use presets.
Fixing the midi mapping allow to move from one to another preset without remapping each time.
For that the arguments have to be shared between synths and the scaling of the values can be done inside the synth.
I suggest to use generic names like cc1, cc2...etc and remap them inside the synth with names that make more sense to the UGen's graph.
All the controllers come inside the synth on the midi range and get the actual values inside the synth, this allow to control different ranges with the same controller.
In the code below an example of setting 24 continuos controls, note in and pitch bend.
Program change can move between synths by changing the source of the Ndef.

*/

//This is the main tool
/*
// use this for testing
~synth1={SinOsc.ar([440,660])};
~synth2={Saw.ar([440,660])};
~synth3={WhiteNoise.ar(0.1)!2};
~synth4={Silence.ar()};
*/
(
Ndef(\synth).play;
Ndef(\synth).fadeTime=4;
)
Ndef(\synth).pause;
Ndef(\synth).resume;
Ndef(\synth).clear;
Ndef(\synth).source=~synth1;
Ndef(\synth).source=~synth2;
Ndef(\synth).source=~synth3;
Ndef(\synth).source=~synth4;
Ndef(\synth).gui;
(
MIDIClient.init;
MIDIIn.connectAll;
);
// Map to your controller
(
~cc1 = 4;
~cc2 = 9;
~cc3 = 10;
~cc4 = 1;
~cc5 = 16;
~cc6 = 17;
~cc7 = 18;
~cc8 = 19;
~cc9 = 11;
~cc10 = 12;

~cc11 = 13;
~cc12 = 7;
~cc13 = 30;
~cc14 = 31;

~cc15 = 29;
~cc16 = 4;
// ~cc17 = 22;
// ~cc18 = 23;
//
// ~cc19 = 24;
// ~cc20 = 26;
// ~cc21 = 92;
//
// ~cc22 = 29;
// ~cc23 = 30;
// ~cc24 = 31;

);

//default cc
(
~cc1 = 1;
~cc2 = 2;
~cc3 = 3;
~cc4 = 4;
~cc5 = 5;
~cc6 = 6;
~cc7 = 7;
~cc8 = 8;
~cc9 = 9;
~cc10 = 10;

~cc11 = 11;
~cc12 = 12;
~cc13 = 13;
~cc14 = 14;

~cc15 = 15;
~cc16 = 16;
~cc17 = 17;
~cc18 = 18;
~cc19 = 19;
~cc20 = 20;
~cc21 = 21;
~cc22 = 22;
~cc23 = 23;
~cc24 = 24;

);

// print them out
25.do{|i|currentEnvironment.at(("cc"++i).asSymbol).postln};

//assign them to the synth
(
25.do{|i|var env = currentEnvironment.at(("cc"++i).asSymbol);
	MIDIFunc.cc({|val,num,ch,src|Ndef(\synth).set(("cc"++i).asSymbol, val);
		//[num,val].postln;
		},env);
};
// assign note on messages
MIDIFunc.noteOn({arg vel, note, ch, src;Ndef(\synth).set(\note, note, \tgate, 1);
	//note.postln
	});
MIDIFunc.noteOff({arg vel, note, ch, src;Ndef(\synth).set(\tgate, 0)});

);

//Sources
(
~synth1={arg note=60, vol= 1, tgate=1, cc1=60, cc2=1, cc3=0, cc4=0, cc5=0, cc6=120, cc7=127, cc8=60, cc9=120, cc10=0, cc11=0, cc12=127, cc13, cc14, cc15, cc16, cc17, cc18, cc19, cc20, cc21, cc22, cc23, cc24, cc25, cc26, cc27, cc28, cc29, cc30;

	var carFreq, modFreq, attack, decay, sustain, release, index, offset, ffreq, rq, morphing, amp;
	var delay, feedback, wet;
    var modulator, carrier, filter1, filter2, output, env, gate=1, pos=0;

	carFreq = note.midicps;
	//carFreq = cc1.linlin(0, 127, 20, 20000);
	modFreq = cc2.linlin(0, 127, 0.1, 1000);
	//gate = cc1.linlin(0, 127, 20, 20000);

	index = cc3.linlin(0, 127, 0, 4*pi);
	offset = cc4.linlin(0, 127, 1, 1000);

	attack = cc5.linlin(0, 127, 0, 2);
	decay = cc6.linlin(0, 127, 0, 2);
	sustain = cc7.linlin(0, 127, 0, 1);
	release = cc8.linlin(0, 127, 0, 2);


	ffreq = cc9.midicps;
	rq = cc10.linlin(0, 127, 0, 1);
	morphing = cc11.linlin(0, 127, -1, 1);
	amp = cc12.linlin(0, 127, 0, 1);

	delay = cc13.linlin(0,127,0.001,2);
	feedback = cc14.linlin(0,127,0,1.0);
	wet = cc15.linlin(0,127,-1,1);

    env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), tgate, doneAction:0);
//	modulator = SinOsc.kr(modFreq,0,index,offset);
//  carrier = SinOsc.ar(carFreq+modulator);
	carrier = PMOsc.ar(carFreq, modFreq, index);
	carrier = XFade2.ar (carrier, PitchShift.ar(carrier,0.1,1,delay,feedback), wet);
	filter1 = DFM1.ar(carrier, ffreq, rq);
    filter2 = BMoog.ar(carrier, ffreq, rq, offset, 0.5);
	//var filter1 = LPF.ar(carrier, ffreq, rq);
	//var filter2 = HPF.ar(carrier, ffreq, rq);
	output = XFade2.ar (filter1, filter2, morphing);

	Pan2.ar(output,pos,env*amp*vol);

}
);

Ndef(\synth).source=~synth1;

(
~synth2={arg note=60, vol= 1, tgate=1, cc1=60, cc2=1, cc3=0, cc4=0, cc5=0, cc6=0, cc7=127, cc8=60, cc9=120, cc10=0, cc11=0, cc12=127, cc13, cc14, cc15, cc16, cc17, cc18, cc19, cc20, cc21, cc22, cc23, cc24, cc25, cc26, cc27, cc28, cc29, cc30;

	var carFreq, modFreq, attack, decay, sustain, release, index, offset, ffreq, rq, morphing, amp;
	var delay, feedback, wet;
    var modulator, carrier, filter1, filter2, output, env, gate=1, pos=0;
	var envFilter, attackFilter, decayFilter, sustainFilter, releaseFilter, saturation=1, envamountFilter=0;

	carFreq = note.midicps;
	//carFreq = cc1.linlin(0, 127, 20, 20000);
	modFreq = cc2.linlin(0, 127, 0.1, 1000);
	//gate = cc1.linlin(0, 127, 20, 20000);

	index = cc3.linlin(0, 127, 0, 4*pi);
	//offset = cc4.linlin(0, 127, 1, 1000);
	saturation = cc4.linlin(0, 127, 1, 1000);

	attack = cc5.linlin(0, 127, 0, 2);
	decay = cc6.linlin(0, 127, 0, 2);
	sustain = cc7.linlin(0, 127, 0, 1);
	release = cc8.linlin(0, 127, 0, 2);

	attackFilter = cc15.linlin(0, 127, 0, 2);
	decayFilter = cc16.linlin(0, 127, 0, 2);
	sustainFilter = cc17.linlin(0, 127, 0, 100);
	releaseFilter = cc18.linlin(0, 127, 0, 2);
	envamountFilter = cc19.linlin(0, 127, 0, 1);

	ffreq = cc9.midicps;
	rq = cc10.linlin(0, 127, 0, 1);
	morphing = cc11.linlin(0, 127, -1, 1);
	amp = cc12.linlin(0, 127, 0, 1);

	delay = cc13.linlin(0,127,0.001,2);
	feedback = cc14.linlin(0,127,0,1.0);
	wet = cc20.linlin(0,127,-1,1);

    env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), tgate, doneAction:0);
	envFilter = EnvGen.ar(Env.adsr(attackFilter,decayFilter,1,releaseFilter), tgate, doneAction:0)*sustainFilter;
//	modulator = SinOsc.kr(modFreq,0,index,offset);
//  carrier = SinOsc.ar(carFreq+modulator);
	//carrier = PMOsc.ar(carFreq, modFreq, index);
	//carrier = XFade2.ar (carrier, PitchShift.ar(carrier,0.1,1,delay,feedback), wet);
	//filter1 = DFM1.ar(carrier, ffreq, rq);
    //filter2 = BMoog.ar(carrier, ffreq, rq, offset, 0.5);
	//var filter1 = LPF.ar(carrier, ffreq, rq);
	//var filter2 = HPF.ar(carrier, ffreq, rq);
	//output = XFade2.ar (filter1, filter2, morphing);

	//output = Pulse.ar(carFreq,[rq,rq+0.1]);
	output = SawDPW.ar(carFreq,[index,index+0.1]);
	output = BMoog.ar(output, ffreq*(envFilter*envamountFilter+0.01), rq, 0.5);
	//Pan2.ar(output,pos,env*amp*vol);

	output*env*amp*vol

}
);

Ndef(\synth).source=~synth2;

(
~synth3={|carFreq= 313, modFreq=440, gate=1, attack=0.01, decay=0.2, sustain=1, index=100, offset=10 release=0.1, ffreq = 10000 , rq = 1,morphing = 0,amp=1|
    var sin = Pulse.kr(modFreq,0.5,index,offset);
    var osc= LFTri.ar(carFreq+sin);
    var filter1 = DFM1.ar(osc, ffreq, rq);
    var filter2 = BMoog.ar(osc, ffreq, rq, 2, 0.5);
	//var filter1 = LPF.ar(osc, ffreq, rq);
	//var filter2 = HPF.ar(osc, ffreq, rq);
	var output = XFade2.ar (filter1, filter2, morphing,);
    var env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), gate, doneAction:2);
	output*env*0.5*amp;}
);


(
~synth4={|carFreq= 313, modFreq=440, gate=1, attack=0.01, decay=0.2, sustain=1, index=100, offset=10 release=0.1, ffreq = 10000 , rq = 1,morphing = 0,amp=1|
    //var sin = Pulse.kr(modFreq,0.5,index,offset);
	var sin = Dseq([60,63,62,67,68,67,72].midicps,inf);
	var arp = Demand.kr(Impulse.kr(modFreq),0,sin);
    var osc= LFTri.ar(carFreq+arp);
    var filter1 = DFM1.ar(osc, ffreq, rq);
    var filter2 = BMoog.ar(osc, ffreq, rq, 2, 0.5);
	//var filter1 = LPF.ar(osc, ffreq, rq);
	//var filter2 = HPF.ar(osc, ffreq, rq);
	var output = XFade2.ar (filter1, filter2, morphing,);
    var env = EnvGen.ar(Env.adsr(attack,decay,sustain,release), gate, doneAction:2);
	output*env*0.5*amp;}
);



/*
MIDIFunc.cc({|val,num,ch,src|~cc1Pot = val; Ndef(\synth).set(\cc1, val)},~cc1);
MIDIFunc.cc({|val,num,ch,src|~cc2Pot = val; Ndef(\synth).set(\cc2, val)},~cc2);
MIDIFunc.cc({|val,num,ch,src|~cc3Pot = val; Ndef(\synth).set(\cc3, val)},~cc3);
MIDIFunc.cc({|val,num,ch,src|~cc4Pot = val; Ndef(\synth).set(\cc4, val)},~cc4);
MIDIFunc.cc({|val,num,ch,src|~cc5Pot = val; Ndef(\synth).set(\cc5, val)},~cc5);
MIDIFunc.cc({|val,num,ch,src|~cc6Pot = val; Ndef(\synth).set(\cc6, val)},~cc6);
MIDIFunc.cc({|val,num,ch,src|~cc7Pot = val; Ndef(\synth).set(\cc7, val)},~cc7);
MIDIFunc.cc({|val,num,ch,src|~cc8Pot = val; Ndef(\synth).set(\cc8, val)},~cc8);
MIDIFunc.cc({|val,num,ch,src|~cc9Pot = val; Ndef(\synth).set(\cc9, val)},~cc9);
MIDIFunc.cc({|val,num,ch,src|~cc10Pot = val; Ndef(\synth).set(\cc10, val)},~cc10);
*/


