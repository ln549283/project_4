"""Original deterministic sound design. No samples or third-party recordings."""
from pathlib import Path
import numpy as np, wave, subprocess
out=Path(__file__).resolve().parents[2]/'assets/slice/lantern'
sr=24000
rng=np.random.default_rng(1309)
def save(name,y,loop=False):
 y=np.asarray(y);y=y/(max(1,float(abs(y).max())/.7));pcm=(y*32767).astype('<i2')
 path=out/(name+'.wav')
 with wave.open(str(path),'wb') as f:f.setnchannels(1 if y.ndim==1 else 2);f.setsampwidth(2);f.setframerate(sr);f.writeframes(pcm.tobytes())
 if loop:
  subprocess.run(['ffmpeg','-y','-loglevel','error','-i',str(path),'-c:a','libvorbis','-q:a','4',str(out/(name+'.ogg'))],check=True);path.unlink()
def bell(freq,duration,soft=False):
 t=np.arange(int(sr*duration))/sr
 y=sum(np.sin(2*np.pi*freq*r*t+0.05*i)*np.exp(-t*(1.1+i*.7))/(1+i)**2 for i,r in enumerate([1,2.002,3.99,5.04,7.02]))
 return y*(1-np.exp(-t/(.025 if soft else .002)))*np.exp(-t*.6)
# Sparse original 16-bar phrase, D suspended -> G -> B minor -> A, 64 seconds.
n=sr*64; music=np.zeros((n,2));notes=[(0,50),(4,62),(8,69),(12,66),(16,43),(20,62),(24,67),(28,69),(32,47),(36,62),(40,66),(44,73),(48,45),(52,64),(56,69),(60,62)]
for k,(start,midi) in enumerate(notes):
 note=bell(440*2**((midi-69)/12),9,True)*(.13 if k%4 else .19)
 for c,g in enumerate([.8+.2*np.sin(k),.8-.2*np.sin(k)]):
  for delay,vol in [(0,1),(.19,.18),(.43,.08)]:
   ids=(np.arange(len(note))+int((start+delay)*sr))%n;music[ids,c]+=note*g*vol
save('river_theme',music,True)
# Seamless band-limited river air with slow non-identical stereo movement.
f=np.fft.rfftfreq(n,1/sr);amp=1/np.maximum(f,30)**.82;amp[f<35]=0;amp[f>4500]=0
channels=[]
for c in range(2):
 z=np.fft.irfft(amp*np.exp(1j*rng.uniform(0,2*np.pi,len(f))),n);z=z/np.std(z)*.075
 t=np.arange(n)/sr;z*=.8+.12*np.sin(2*np.pi*t/16+c)+.06*np.sin(2*np.pi*t/8)
 channels.append(z)
save('river_air',np.array(channels).T,True)
for i in range(3):
 t=np.arange(int(sr*.32))/sr
 noise=rng.normal(0,1,len(t));scrape=np.convolve(noise,np.ones(9)/9,'same')*np.exp(-t*32)*.14
 y=bell(710+i*37,.32)*.19+bell(1190+i*53,.32)*.08+scrape
 save('mirror_'+str(i),y)
save('touch',bell(290,.14)*.09)
save('mark',bell(880,1.1)*.17)
y=np.zeros(sr*4)
for i,midi in enumerate([62,69,74,78]):
 note=bell(440*2**((midi-69)/12),3,True)*.17;j=int(i*.22*sr);y[j:j+len(note)]+=note
save('arrival',y)
print('Original assets generated')
