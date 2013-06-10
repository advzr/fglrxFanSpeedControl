#!/bin/bash

function getTemp {
temp=$(aticonfig --adapter=0 --od-gettemperature | grep "Sensor" | sed "s/[^0-9]//g;s/^$/-1/;" | sed "s/[0-9]//")
let "temp /= 100"
echo $temp
}

function getFullOutputTemp {
aticonfig --adapter=0 --od-gettemperature
}

function getFanSpeed {
fanspeed=$(aticonfig --pplib-cmd "get fanspeed 0" | grep "Result:" | tr -dc '[0-9]')
echo $fanspeed
}

function getFullOutputFanSpeed {
aticonfig --pplib-cmd "get fanspeed 0"
}

function setFanSpeed {
aticonfig --pplib-cmd "set fanspeed 0 $1"
}

function check1 {
echo -e "Step 1:
Trying to get your GPU temp with aticonfig..."
getFullOutputTemp
echo -e "\nParsing aticonfig output to get the temperature...
Your GPU temperature is $(getTemp) degrees Celsius. Is this correct? Please pay attention as the script relies on getting the correct GPU temperature. If anything looks suspicious, you should quit now.\n"

OPTIONS="Continue Quit"
select opt in $OPTIONS; do
	if [ "$opt" = "Quit" ]; then
		exit
	elif [ "$opt" = "Continue" ]; then
		break
	else
		clear
		echo bad option
	fi
done

}

function check2 {
echo -e "\nStep 2:
Trying to get your GPU fan speed with aticonfig...\n"
getFullOutputFanSpeed
echo -e "Parsing aticonfig output to get the fan speed...
Your GPU fan speed is $(getFanSpeed)%. Is this correct?\n"

OPTIONS="Continue Quit"
select opt in $OPTIONS; do
	if [ "$opt" = "Quit" ]; then
		exit
	elif [ "$opt" = "Continue" ]; then
		break
	else
		clear
		echo bad option
	fi
done
}

function check3 {
echo -e "\nStep 3:
Trying to change the fan speed...
Setting the fan speed to 50%..."
setFanSpeed 50
sleep 3

echo "Setting the fan speed to 70%..."
setFanSpeed 70
sleep 3

echo "Setting the fan speed to 30%..."
setFanSpeed 30
echo -e "\nDid you hear the fan speed change? Should we proceed?\n"

OPTIONS="Continue Quit"
select opt in $OPTIONS; do
	if [ "$opt" = "Quit" ]; then
		exit
	elif [ "$opt" = "Continue" ]; then
		break
	else
		clear
		echo bad option
	fi
done
}

function check {
if [ ! -f $configFile ] ; then
	echo "Config file $configFile not found. The script must be run for the first time. Commencing initial checks..."
	
	check1
	check2
	check3

	echo "All checks are complete."
fi
}

cd ~/
configFile=".atiFanSpeedControlConfig"

function generateConfig {
if [ -f $configFile ] ; then
	echo "$configFile found. Using existing config."
else
	touch $configFile
	echo verbose=1 >> $configFile 
	echo checkInterval=10 >> $configFile 
	echo coefficient=20 >> $configFile 
	echo constant=-5 >> $configFile 

	local verbose=$(getConfig verbose) 
	if [ "$verbose" -eq 1 ] ; then
		echo "~/$configFile is generated"
	fi
fi
}

function getConfig {
local result=$(cat $configFile | grep -v '^#' | grep "$1=" | sed "s/$1=//" | tr -dc '[0-9, -]')
echo $result
}

function parabolicTemperatureControl {
local verbose=$(getConfig verbose) 
local checkInterval=$(getConfig checkInterval) 
local coefficient=$(getConfig coefficient) 
local constant=$(getConfig constant) 
local lastTemp=0

while :
do
	local currentTemp=$(getTemp)
	local calculatedSpeed=$(($currentTemp * $currentTemp * $coefficient / 1000 + $constant))

	if [ "$calculatedSpeed" -gt 100 ] ; then
		calculatedSpeed=100
	fi

	if [ "$calculatedSpeed" -lt 20 ] ; then
		calculatedSpeed=20
	fi

	if [ "$currentTemp" -ne "$lastTemp" ] ; then
		if [ "$verbose" -eq 1 ] ; then
			echo "GPU Temperature is $currentTemp. Setting fan speed to $calculatedSpeed"
		fi
		
		setFanSpeed $calculatedSpeed
		lastTemp=$currentTemp
	fi

	sleep $checkInterval
done

}

check
generateConfig
parabolicTemperatureControl
