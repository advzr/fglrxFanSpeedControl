fglrxFanSpeedControl
====================

A short bash script to control a ATI GPU with fglrx dirver.

Sometimes the automatic fan control in fglrx is not optimal. Some people report the fan working always at maximum speed. And some me included experience the fan speed never get higher than 30% regardless of the GPU temperature. While running the fan at full speed can diminish its life time, using a GPU under heavy load with a slow fan can cause an overheat and break the GPU completely.

A possible solution for this is to manually change the GPU fan speed with the following command:

aticonfig --pplib-cmd "set fanspeed 0 X"

where X is the fan speed. For example if you want to run it at 50% you should execute:

aticonfig --pplib-cmd "set fanspeed 0 50"

The major drawback of this solution is that you have to do it manually. You should increase the speed before launching a heavy app and decrease it after you close the app. Moreover you should control the GPU temperature during the heavy load because the speed you chose could be not enough and your GPU can overheat nevertheless.

To overcome this drawback was created fglrxFanSpeedControl bash script.

FAQ

Q: How can I use it?
A: Simply download fglrxFanSpeedControl.sh, run it with:
sh fglrxFanSpeedControl.sh
and follow the instructions.

Q: Does it work with the open-source driver too?
A: No, the script works only with fglrx driver.

Q: Does it support CrossFireX?
A: The short answer is no. The long answer is the following. Now the script only controls the first GPU. Technically it can be possible to rewrite the script and make it control other GPUs too or launch separate instances of the script for each GPU. But I don't have CrossFireX available and if you really want me to make the script support CrossFireX, I will need a lot of your help in testing.

Q: Can I configure the script behavior?
A: Yes! After the first launch the script will create .atiFanSpeedControlConfig file in your home directory with the following contents:

verbose=1
tempStep1=40
fanStep1=20
tempStep2=50
fanStep2=30
tempStep3=60
fanStep3=40
tempStep4=65
fanStep4=60
tempStep5=70
fanStep5=70
tempStep6=75
fanStep6=90
checkInterval=10

verbose=1 makes the script show more output during its work. It may be usefull in order to understand how it works. If you don't want that much output, you can change it to "verbose=0".

checkInterval=10 means that the script will check the GPU temperature every 10 seconds. Change it to whatever you like. However too small check interval will cause the fan speed change too often and that can be annoying.

tempStepN and fanStepN are the main options to control the fan speed. Currently the script supports 6 steps. tempStep equals to the temperature in Celsius below which the corresponding fanStep will work. For example tempStep1=40 and fanStep1=20 mean that if the GPU temperature is below 40 degrees the fan speed will be 20%. tempStep2=50 and fanStep2=30 mean that if the temperature is above tempStep1 but below tempStep2 the fan speed will be fanStep2 and so on. If the temperature gets over tempStep6 then fan will work at maximum speed.

Q: How should I use it?
A: You can add the script to autostart after you make sure that it works as you want it. Or you can run it manually. However when you stop the script the fan speed will not return to auto! It will remain manually set to the last speed the script set it to. The best way to make fglrx control the fan speed automatically again is to remove the script from autostart and restart X server or reboot your computer completely.

The script is released under GPLv3 or higher and provided “AS IS” WITHOUT WARRANTY OF ANY KIND. Please refer to the full license text for more information:
http://www.gnu.org/licenses/gpl.html
