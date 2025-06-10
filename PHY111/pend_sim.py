# Made with ❤️ by Rishi and Sparsha

# lets import some fun libraries
import math
import random as rn
import numpy as np
import matplotlib.pyplot as plt

# pls tweak the variables below to generate a realistic data, i have tired my best to put okayish values...
def generate(l=1.000, ang_disp=rn.uniform(0.1,0.5), error=8) :
    # okay so these are the pendulum parameters
    ang_vel = 0.01                 # angluar velocity initial value, default value = 0, you need not change this
    ang_acc = 0.005                 # angular acceleration initial value, defalut value = 0, this also shouldnt be touched 
    #ang_disp = rn.uniform(0.1,0.5)    # initial anglular displacement, THIS is the value u need to tweak... in RADIANS bro or u ded... <------------- SPOTLIGHT HERE....................
    m = 0.010                       # mass of pendulum... again, be realistic, dont put ur mass... unit - kg
    g = 9.810                       # value of g, 9.81 is good enough... unit - m/s^2
    #l = 1.000                       # length to C.O.M. ... unit - m
    rot_inerta = m*l*l              # pls put realistic rotational intertia values, not some sketchy 1kgm^2 for a tiny bob... u must make a good realistic estimation... unit - kg*m^2
    damp = rn.uniform(0.005,0.010)   # damping value... this is where idk what i'm doing but everything works out fine somehow, a value of 0.01 seems okay ig
    #error = 8.000                   # maximum error in measuring time period... unit - s
    # so how long do u want the program to run... 
    runtime = 1057000               # ps. arbitrary units, and ya this is not the number of values generated... 
    # program variables... dont touch these unless u wanna cook ur laptop
    timestep = 0.001                # time interval for intregation 
    time = 0.000                    # time means time
    prev_time = 0                   # tracking param
    cnt = 0                         # useless tracking param

    # dont ask me what i have written below...
    for i in range (runtime) :
        time = time + timestep                                                      # okay incrementing time 
        torque = - l * m * g * math.sin(ang_disp) + l*l*ang_vel*ang_vel*damp        # uhh so calculating torque and adding some drag dissipation
        ang_acc = torque / rot_inerta                                               # if u dont understand this line, sheet should kill u
        ang_vel = ang_vel + (ang_acc * timestep)                                    # integrating alpha to get omega
        past_ang_disp = ang_disp                                                    # stamp variable for printing values... eh u can neglect this
        ang_disp = ang_disp + (ang_vel * timestep)                                  # integrating omega to get theta
        if  ((past_ang_disp * ang_disp < 0) and (ang_disp < 0)) :                   # sketchy if statement
            #noise = error+1                                                        # make error variable
            #while abs(noise)>error : noise = random.gauss(error/20,error/2)        # generate random value within error margin
            #print(cnt,'\t',((time-prev_time)+noise))                               # gibs values, adds some random error
            if cnt == 0 : prev_time = time                                          # update tracking params
            cnt+=1                                                                  # same as above
            if cnt == 51 :
                noise = error+1
                while abs(noise)>error : noise = rn.gauss(error/20,error/2)
                t50 = round((time+noise-prev_time), 2)
                t1 = round(t50/50, 2)
                break
    return t1, t50

# PART 1
print('Preparing data for 100 observations with same length...\n')

T, msg = np.array([]), 'Time taken for 50 oscillations,Time Period (T)\n'
for reading in range(100) :
    t1, t50 = generate()
    T = np.append(T, t1)
    msg += f'{t50}, {t1}\n'

print(f'Some stats for 100 observations :\nMax = {max(T)}, Min = {min(T)}, Mean = {round(T.mean(), 2)}, St Dv = {round(T.std(), 2)}\n')

for i in range(5,21,5) :
    plt.hist(T, bins=i, edgecolor="black", linewidth=0.5, zorder=3)
    plt.grid(axis='y', zorder=0)
    plt.xlabel('Time Period')
    plt.ylabel('Count')
    plt.title(f'Histogram with {i} bins')
    plt.savefig(f'{i}.png')
    plt.close()

with open('data100.csv', 'w+') as f :
    f.truncate(0)
    f.write(msg)

print('Preparing data for 10 observations with different lengths...')

T = np.array([])
msg = 'Length (in m),Time taken for 50 oscillations,Time Period (T), T²\n'
L = np.linspace(0.2, 2, 10)
for l in L :
    t1, t50 = generate(l)
    T = np.append(T, t1)
    msg += f'{l}, {t50}, {t1}, {t1**2}\n'

for deg in range(1,3) :
    plt.grid()
    plt.xlabel('L')
    if deg == 1 :
        plt.ylabel('T')
        curve = np.polyfit(L, T**deg, 2)
    elif deg == 2 :
        plt.ylabel('T²')
        curve = np.polyfit(L, T**deg, 1)
    poly = np.poly1d(curve)
    x = np.linspace(L.min(), L.max(), 500)
    y = poly(x)
    plt.plot(L, T**deg, 'o')
    plt.plot(x, y)
    plt.savefig(f't{deg} vs l.png')
    plt.close()

with open('data10.csv', 'w+') as f :
    f.truncate(0)
    f.write(msg)
print('Prepared\n')

# PART 2

print('Finding length of seconds pendulum...')

L = np.array([])
msg = 'Time taken for 50 oscillations,Time Period (T),Length (in m)\n'
while True :
    l = round(rn.uniform(0.8,1.2), 3)
    t1, t50 = generate(l)
    if 1.95 < t1 < 2.05 :
        L = np.append(L, l)
        msg += f'{t50},{t1},{l}\n'
    if len(L) == 10 :
        break

print(f'Mean of 10 observations = {round(L.mean(), 3)}\n')

with open('seconds.csv', 'w+') as f :
    f.truncate(0)
    f.write(msg)


# PART 3

print('Preparing data to calculate K1...')

T, angles, l = np.array([]), np.array([]), 0.5
msg = 'Theta (in degrees),Theta (in radians),Time taken for 50 oscillations,Time Period (T)\n'
for theta in np.linspace(10,55,10) :
    rad = round(np.radians(theta), 2)
    t1, t50 = generate(l, rad, 1)
    T = np.append(T, t1)
    angles = np.append(angles, rad)
    msg += f'{theta}, {rad}, {t50}, {t1}\n'

plt.grid()
plt.xlabel('θ²')
plt.ylabel('T')
m, c = np.polyfit(angles**2, T, 1)
x = angles**2
y = m*x + c
K1 = (m/(2*3.14))*(math.sqrt(9.81/l))
plt.plot(x, T, 'o')
plt.plot(x, y)
plt.savefig(f'T vs θ2.png')
plt.close()

with open('K1.csv', 'w+') as f :
    f.truncate(0)
    f.write(msg)

print(f'Slope = {round(m, 3)}, K1 = {round(K1, 3)}\n')

# PART 4

with open('compound.csv') as f :
    lines = f.read().splitlines()[2:11]

msg = 'Distance from CG (in m),Time Taken for 10 oscillations,,Time Period\n'
msg += ',From end A,From end B,\n'

for line in lines :
    data = line.split(',')
    d = 50 - float(data[1])    # Distance from CG in cm
    t10_1 = round(float(data[4]) + rn.uniform(-0.05,0.05), 2)
    t10_2 = round(t10_1 + rn.uniform(-0.1, 0.1), 2)
    t = round((t10_1+t10_2)/20, 2)
    msg += f'{d},{t10_1},{t10_2},{t}\n'

with open('data-compound.csv', 'w+') as f :
    f.truncate(0)
    f.write(msg)

print('Generated data for Compound Pendulum')

for k,v in {'oval (10 cm)':[5.93, 6.06], 'rectangle (8 cm)':[6.02, 6.04]}.items():
    msg = f'{k},,,\nfrom A,,from B,\n10 osc,T,10 osc,T\n'
    for i in range(5):
        for val in v :
            t = round(rn.uniform(val-0.1, val+0.1), 2)
            msg += f'{t*10},{t},'
        msg = msg[:-1]
        msg += '\n'
    with open(f'data-{k}.csv', 'w+') as f :
        f.truncate(0)
        f.write(msg)

print('Done!')
