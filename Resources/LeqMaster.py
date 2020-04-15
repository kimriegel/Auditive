import numpy as np
import math
import sys

from scipy.io import wavfile

print(sys.argv[1])

fs, data = wavfile.read( sys.argv[1] ) # 'AA_cal_wave.wav')


tmsq = 0
msq = 0
x = 1
i = 1
k = 23047
leqs = list()
rate = int(fs/10) #sample rate per .1 sec

while x <= len(data)/rate: #x increases every 0.1 sec which is 4410 samples. Loop stops when time is over.
    
    for i in range ((x-1)*rate,rate*x): #recalculate rms every 0.1 sec
        msq = msq + ((data[i][0])/k)**2 #add the square of the current sample to the sum of the square of the samples within this 0.1 seconds
    x = x+1
    tmsq = tmsq + msq
    if msq == 0: #skip current iteration if 0 to prevent divide by zero error
      pass
    else:
      leq = 10*np.log10((msq/rate)/(0.00002**2)) # compute leq over 0.1 sec
    msq = 0 #reset msq every 0.1 sec

    leqs.append(leq) #add all the 0.1 sec leqs to list

#compute Lmax
print(len(leqs), leqs)
Lmax = max(leqs)
print ("Lmax: ",Lmax)

#compute total LEQ
print ("tmsq: ",tmsq)
tleq = 10*np.log10((tmsq/len(data))/(0.00002**2))
print ("LEQ: ",tleq)
