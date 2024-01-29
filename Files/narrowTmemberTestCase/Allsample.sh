#!/bin/bash

# Sampling
#rm -r $caseDir/sampling
rm -r $caseDir/postProcessing/sets
if [ ! -d $caseDir ]
then
    mkdir $caseDir/sampling
fi
for interpScheme in $INTERPSCHEME
do
    for types in $TYPE
    do
        for axes in $AXIS 
        do
            if [ -d $caseDir ]
	    then
                echo "sampleDict deleted."
	        #rm -r $caseDir/postProcessing/sets
                cp narrowTmember/system/sampleDict $caseDir/system
	    fi
            echo "Creating sampleDict for $interpScheme-$types-$axes"
            sed -i s/INTERPSCHEME/$interpScheme/g \
               $caseDir/system/sampleDict
            sed -i s/FIELDS/"$FIELDS"/g \
               $caseDir/system/sampleDict
            sed -i s/TYPE/$types/g \
               $caseDir/system/sampleDict
            sed -i s/AXIS/$axes/g \
               $caseDir/system/sampleDict
            sed -i s/START/"$START"/g \
               $caseDir/system/sampleDict
            sed -i s/END/"$END"/g \
               $caseDir/system/sampleDict
            sed -i s/NPOINTS/$NPOINTS/g \
               $caseDir/system/sampleDict
            
            sample -case $caseDir -latestTime > $caseDir/log.sample
            dataName=$(ls $caseDir/postProcessing/sets/$latestTime -t1|head -1) 
            cp $caseDir/postProcessing/sets/$latestTime/$dataName \
               $caseDir/sampling/"$interpScheme-$types-$axes"
        done
    done
done
#---------------------------------------------------------------------
