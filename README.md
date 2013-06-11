fglrxFanSpeedControl
====================

A short bash script to control a ATI GPU with fglrx dirver.

Sometimes the automatic fan control in fglrx is not optimal. Some people me included experience the fan speed never get higher than 33% regardless of the GPU temperature. Using a GPU under heavy load with a slow fan can cause an overheat and break the GPU completely.

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
A: Yes! After the first launch the script will create .fglrxFanSpeedControlConfig file in your home directory with the following contents:

verbose=1
checkInterval=10
coefficient=20
constant=-5


verbose=1 makes the script show more output during its work. It may be usefull in order to understand how it works. If you don't want that much output, you can change it to "verbose=0".

checkInterval=10 means that the script will check the GPU temperature every 10 seconds. Change it to whatever you like.

The fan speed is calculated in per cents using a parabolic function. The formula is as follows:
$currentTemp * $currentTemp * $coefficient / 1000 + $constant
That means that if for example the current temperature is 60 degrees Celsius and the $coefficient and $constant are default values then the calculated fan speed will be
60*60*20/1000 - 5 = 67%
You can change the slope and height of the fan speed graph by changing coefficient and constant in your config. No matter what the calculated speed will never get above 100% as this is useless and it will never get below 20%. This was done as a precaution. Even if the script fails to read the GPU temperature, it will never make the fan stop.

Q: How should I use it?
A: You can add the script to autostart after you make sure that it works as you want it. Or you can run it manually. However when you stop the script the fan speed will not return to auto! It will remain manually set to the last speed the script set it to. The best way to make fglrx control the fan speed automatically again is to remove the script from autostart and restart X server or reboot your computer completely.

The script is released under GPLv3 or higher and provided “AS IS” WITHOUT WARRANTY OF ANY KIND. Please refer to the full license text for more information:
http://www.gnu.org/licenses/gpl.html
