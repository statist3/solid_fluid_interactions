#!/bin/bash
 #------------------------------------------------------------------#
#|                          Course of action                        |#
 #------------------------------------------------------------------#
 #------------------------------------------------------------------#
#|                                                                  |#
 #------------------------------------------------------------------#

source userInput.sh

# create caseDir
for mesh in $meshType
do
    #for solProc in $solProcs
    #do
        for model in $models
	do
            caseDir="$mesh-$model"
            source Allsample.sh
	done
    #done
done
#---------------------------------------------------------------------