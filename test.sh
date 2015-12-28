#!/bin/bash

#############################################
# Author: Darshan Thaker                    #
# This script can be used to test parallel  #
# vs. serial implementations. Feel free to  #
# hardcode the below variables if needed.   #
#                                           #
# Preconditions: The parallel version of    #
# the program takes in a number of threads  #
# as its final command line parameter. The  #
# program should also output a line         #
# starting with 'Time:' to see how long     #
# the program took.                         #
#                                           #
# It will output the time taken for the old #
# version, the new version, and the speedup #
# of the program, which is defined as       #
# OLD_TIME / NEW_TIME                       #
#############################################

echo "What is the command to compile your program (old and new)? (Ex. 'make clean all' or 'none')"
read COMPILE_COMMAND
echo "What is the command to run your old program? (Ex. './EXECUTABLE' or 'python NAME')"
read RUN_COMMAND_OLD
echo "What is the command to run your new program? (Ex. './EXECUTABLE' or 'python NAME')"
read RUN_COMMAND_NEW
echo "How many threads do you want to run (max)?"
read THREADS
echo "What is the stepsize for threads (starting from 1 thread)"
read STEP_SIZE
echo "How many inputs do you want to test?"
read INPUT_SIZE
INPUT_COUNTER=0
INPUT=()
while [ $INPUT_COUNTER -lt $INPUT_SIZE ]; do
    echo "Enter in name of input #$INPUT_COUNTER"
    read INP
    INPUT+=($INP)
    let INPUT_COUNTER=INPUT_COUNTER+1
done

TCOUNTER=1
INPUT_COUNTER=0

if [ $COMPILE_COMMAND != "none" ]
then
    $COMPILE_COMMAND
    if [ $? -ne 0 ]
    then
        echo "Did not compile properly: return value nonzero"
        exit
    fi
fi

if [ $INPUT_SIZE -ne 0 ]
then
    while [ $INPUT_COUNTER -lt $INPUT_SIZE ]; do
        while [ $TCOUNTER -lt $THREADS ]; do
            echo "Input: ${INPUT[$INPUT_COUNTER]}, Number of threads: $TCOUNTER"
            OLDTIMETAKEN="$($RUN_COMMAND_OLD ${INPUT[$INPUT_COUNTER]} | grep "Time:")"
            NEWTIMETAKEN="$($RUN_COMMAND_NEW ${INPUT[$INPUT_COUNTER]} $TCOUNTER | grep "Time:")"
            echo "OLD: $OLDTIMETAKEN"
            echo "NEW: $NEWTIMETAKEN"
            echo "SPEEDUP: "
            python -c "print $OLDTIMETAKEN / float($NEWTIMETAKEN)"
            let TCOUNTER=TCOUNTER+$STEP_SIZE
        done
        TCOUNTER=1
        let INPUT_COUNTER=INPUT_COUNTER+1
    done
else
    while [ $TCOUNTER -lt $THREADS ]; do
        echo "Number of threads: $TCOUNTER"
        OLDTIMETAKEN="$($RUN_COMMAND_OLD | grep "Time:")"
        NEWTIMETAKEN="$($RUN_COMMAND_NEW $TCOUNTER | grep "Time:")"
        echo "OLD: $OLDTIMETAKEN"
        echo "NEW: $NEWTIMETAKEN"
        echo "SPEEDUP: "
        python -c "print $OLDTIMETAKEN / float($NEWTIMETAKEN)"
        let TCOUNTER=TCOUNTER+$STEP_SIZE
    done
fi
