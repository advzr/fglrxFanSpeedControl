#!/bin/bash

function getTemp {
temp=$(aticonfig --adapter=0 --od-gettemperature | grep 'Sensor' | sed "s/[^0-9]//g;s/^$/-1/;" | sed "s/[0-9]//")
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
	echo tempStep1=40 >> $configFile 
	echo fanStep1=20 >> $configFile 
	echo tempStep2=50 >> $configFile 
	echo fanStep2=30 >> $configFile 
	echo tempStep3=60 >> $configFile 
	echo fanStep3=40 >> $configFile 
	echo tempStep4=65 >> $configFile 
	echo fanStep4=60 >> $configFile 
	echo tempStep5=70 >> $configFile 
	echo fanStep5=70 >> $configFile 
	echo tempStep6=75 >> $configFile 
	echo fanStep6=90 >> $configFile 
	echo checkInterval=10 >> $configFile 
	echo coefficient=20 >> $configFile 
	echo constant=0 >> $configFile 

	local verbose=$(getConfig verbose) 
	if [ "$verbose" -eq 1 ] ; then
		echo "~/$configFile is generated"
	fi
fi
}

function getConfig {
local result=$(cat $configFile | grep -v '^#' | grep "$1=" | sed "s/$1=//")
echo $result
}

function discreteTemperatureControl {
local verbose=$(getConfig verbose) 
local tempStep1=$(getConfig tempStep1) 
local fanStep1=$(getConfig fanStep1) 
local tempStep2=$(getConfig tempStep2) 
local fanStep2=$(getConfig fanStep2) 
local tempStep3=$(getConfig tempStep3) 
local fanStep3=$(getConfig fanStep3) 
local tempStep4=$(getConfig tempStep4) 
local fanStep4=$(getConfig fanStep4) 
local tempStep5=$(getConfig tempStep5) 
local fanStep5=$(getConfig fanStep5) 
local tempStep6=$(getConfig tempStep6) 
local fanStep6=$(getConfig fanStep6) 
local checkInterval=$(getConfig checkInterval) 

local lastTempMode=0
local tempMode=0

if [ "$verbose" -eq 1 ] ; then
	echo "Commencing automatic fan speed control"
fi

while :
do
	temp=$(getTemp)

	if [ "$temp" -le "$tempStep1" ] ; then
		tempMode=1
	elif [ "$temp" -le "$tempStep2" ] ; then
		tempMode=2
	elif [ "$temp" -le "$tempStep3" ] ; then
		tempMode=3
	elif [ "$temp" -le "$tempStep4" ] ; then
		tempMode=4
	elif [ "$temp" -le "$tempStep5" ] ; then
		tempMode=5
	elif [ "$temp" -le "$tempStep6" ] ; then
		tempMode=6
	else
		tempMode=7
	fi

	if [ "$tempMode" -ne "$lastTempMode" ] ; then
		case $tempMode in
			1)
				if [ "$verbose" -eq 1 ] ; then
					echo "GPU Temperature is bellow $tempStep1. Setting fan speed to $fanStep1%."
				fi
				setFanSpeed $fanStep1
				lastTempMode=$tempMode
				;;
			2)
				if [ "$verbose" -eq 1 ] ; then
					echo "GPU Temperature is bellow $tempStep2. Setting fan speed to $fanStep2%."
				fi
				setFanSpeed $fanStep2
				lastTempMode=$tempMode
				;;
			3)
				if [ "$verbose" -eq 1 ] ; then
					echo "GPU Temperature is bellow $tempStep3. Setting fan speed to $fanStep3%."
				fi
				setFanSpeed $fanStep3
				lastTempMode=$tempMode
				;;
			4)
				if [ "$verbose" -eq 1 ] ; then
					echo "GPU Temperature is bellow $tempStep4. Setting fan speed to $fanStep4%."
				fi
				setFanSpeed $fanStep4
				lastTempMode=$tempMode
				;;
			5)
				if [ "$verbose" -eq 1 ] ; then
					echo "GPU Temperature is bellow $tempStep5. Setting fan speed to $fanStep5%."
				fi
				setFanSpeed $fanStep5
				lastTempMode=$tempMode
				;;
			6)
				if [ "$verbose" -eq 1 ] ; then
					echo "GPU Temperature is bellow $tempStep6. Setting fan speed to $fanStep6%."
				fi
				setFanSpeed $fanStep6
				lastTempMode=$tempMode
				;;
			7)
				if [ "$verbose" -eq 1 ] ; then
					echo "GPU Temperature is above $tempStep6. Setting fan speed to max."
				fi
				setFanSpeed 100
				lastTempMode=$tempMode
				;;
		esac

	fi

	sleep $checkInterval
done
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
#discreteTemperatureControl
parabolicTemperatureControl
