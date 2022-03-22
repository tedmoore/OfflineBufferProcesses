// all mono
(
~src = Buffer.loadCollection(s,Array.fill(100,{rrand(-1.0,1.0)}));
~dst = Buffer.alloc(s,100);
~env = Buffer.loadCollection(s,Array.fill(100,{arg i; i.linlin(0,99,0,pi).sin}));
)

(
~src.copyWithEnv(~env,~dst);
~dst.plot;
)

// a section
(
~src = Buffer.loadCollection(s,Array.fill(100,{arg i; i}));
~dst = Buffer.alloc(s,100);
~env = Buffer.loadCollection(s,Array.fill(10,{arg i; i.linlin(0,9,0,pi).sin}));
)

(
~src.copyWithEnv(~env,~dst,9,40);
~src.copyWithEnv(~env,~dst,0,50);
~src.copyWithEnv(~env,~dst,8,5);
~dst.plot;
)

// wrong num channels

(
~src = Buffer.loadCollection(s,Array.fill(100,{arg i; i}),2);
~dst = Buffer.alloc(s,100);
~env = Buffer.loadCollection(s,Array.fill(10,{arg i; i.linlin(0,9,0,pi).sin}));
)

(
~src.copyWithEnv(~env,~dst,5,5);
)

// same buffer errors
(
// mulBuf: mul buffer is the same as the destination buffer.
~src.copyWithEnv(~dst,~dst);
)

(
// mulBuf: source buffer is the same as the destination buffer.
~src.copyWithEnv(~src,~dst);
)

(
// mulBuf: mul buffer is the same as the source buffer.
~src.copyWithEnv(~dst,~src);
)

// dest gain

(
~noise = Buffer.loadCollection(s,Array.fill(100,{rrand(-1.1,1.1)}));
~line = Buffer.loadCollection(s,Array.fill(100,{arg i; i}));
~dst = Buffer.alloc(s,100);
~env = Buffer.loadCollection(s,Array.fill(50,{0.5}));
)

(
~noise.copyWithEnv(~env,~dst,0,40,300,1);
~line.copyWithEnv(~env,~dst,0,25,1,0.5);
~dst.plot;
)

(
~noise.copyWithEnv(~env,~dst);
~line.copyWithEnv(~env,~dst,0,25,5,1);
~dst.plot;
)

// ======= test with no enveloping ===========
~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

(
~dur = 0.1;
~envLen = ~src.sampleRate * ~dur;
)

(
~overlap = 4;
~numSlices = (~src.numFrames / ~envLen).floor.asInteger;
~dest = Buffer.alloc(s,(~numSlices * (~envLen / ~overlap)) + ~envLen,~src.numChannels);
)

(
~numSlices.do{
	arg i;
	var src_start = i * ~envLen;
	var dest_start = src_start / ~overlap;
	"% / %".format(i+1,~numSlices).postln;
	FluidBufCompose.processBlocking(s,~src,src_start,~envLen,destination:~dest,destStartFrame:dest_start,destGain:1);
};
)

~dest.plot;
~dest.play;

// ================ with enveloping ===================

~src = Buffer.read(s,FluidFilesPath("Nicol-LoopE-M.wav"));

(
~dur = 0.1;
~envLen = ~src.sampleRate * ~dur;
// ~env = Buffer.loadCollection(s,Array.fill(~envLen,{arg i; i.linlin(0,~envLen-1,0,pi).sin}));
~env = Buffer.loadCollection(s,Array.fill(~envLen,{arg i; i.linlin(0,~envLen-1,-1,1).abs * -1}));
)

~env.plot;

(
~overlap = 4;
~numSlices = (~src.numFrames / ~envLen).floor.asInteger;
~dest = Buffer.alloc(s,(~numSlices * (~envLen / ~overlap)) + ~envLen,~src.numChannels);
)

(
~numSlices.do{
	arg i;
	var src_start = i * ~envLen;
	var dest_start = src_start / ~overlap;
	"% / %".format(i+1,~numSlices).postln;
	~src.copyWithEnv(~env,~dest,src_start,dest_start,destGain:1);
};
)

~dest.plot;
~dest.play;