import matplotlib.pyplot as plt
import numpy as np
from fxpmath import Fxp
import random
from math import sqrt



t = np.linspace(0,1,100)  # Time
tb = 1;
fc = 1;    # carrier frequency

c1 = np.cos(2*np.pi*fc*t) # carrier frequency cosine wave
c2 = np.sin(2*np.pi*fc*t) # carrier frequency sine wave

fig, ax = plt.subplots(4)

m = []
t1 = 0;
t2 = tb; 
#b010111101001011
m = [0,0,0,1,1,1,1,0,1,0,0,1,0,1,1,1]
# for i in range(num_symbols):
#     m.append(random.uniform(0,1))   # message signal (binary)
    # print(m[i])
num_symbols = len(m)
## modulation

odd_sig = np.zeros((num_symbols,100))
even_sig = np.zeros((num_symbols,100))

for i in range(0,num_symbols-1,2):
    t = np.linspace(t1,t2,100)
    if (m[i]>0.5):
        m[i] = 1
        m_s = np.ones((1,len(t)))
    else:
        m[i] = 0
        m_s = (-1)*np.ones((1,len(t)))

    odd_sig[i,:] = c1*m_s

    if (m[i+1]>0.5):
        m[i+1] = 1
        m_s = np.ones((1,len(t)))
    else:
        m[i+1] = 0
        m_s = (-1)*np.ones((1,len(t)))

    even_sig[i,:] = c2*m_s

    qpsk = odd_sig + even_sig

    ax[0].plot(t,qpsk[i,:])
    ax[2].plot(t,odd_sig[i,:])
    ax[3].plot(t,even_sig[i,:])
    t1 = t1 + (tb+0.01)
    t2 = t2 + (tb+0.01)

ax[0].grid()
ax[0].title.set_text('Modulated Wave')
ax[2].grid()
ax[2].title.set_text('Odd')
ax[3].grid()
ax[3].title.set_text('Even')

print(m)
ax[1].stem(range(num_symbols), m,use_line_collection=True)
ax[1].grid()
ax[1].set_ylabel(str(len(m))+' bits data')
ax[1].title.set_text('Generation of message signal (Binary)')
fig.tight_layout()
plt.show()
