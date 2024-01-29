#!/bin/bash

 #------------------------------------------------------------------#
#|                      Course of action                            |#
 #------------------------------------------------------------------#
# Warning:
# Any pdf file in this directory will be removed!
 #------------------------------------------------------------------#

plot() {
declare -f filePath=("${!1}")
declare -f fileName=("${!2}")
declare -f caseDir=("${!3}")
#declare -f dataPvu=("${!4}")
gnuplot<<plotSigma
set terminal epslatex standalone

data="${filePath[*]}"
name="${fileName[*]}"
cases="${caseDir[*]}"
#dataPvu="${filePvu[*]}"

print data
print name
print cases
unset key
set xlabel '\$x\$ (m)'
 #------------------------------------------------------------------#
#                                Paraview
 #------------------------------------------------------------------#
#unset yrange
#unset xrange
##set xrange [-1e6:1e6]
##set yrange [-1e6:1e6]
#set key below  Left box  opaque reverse horizontal samplen 1#spacingfont '\tiny' 
#set format y '\$%4.2t\times10^{%T}\$'
##set x2tics ('\$\times 10^5\$' -.0399) nomirror scale 0
##unset x2tics
#set ylabel '$\sigma_{xx}$ (pa)' rotate by 90
#set output "Paraview.tex"
##plot for [i=1:words(data)]  word(data,i) u 1:3 w lp  
##plot for [i=1:words(data)]  word(data,i) u 1:3 w lp  \
##pt pType[i] ps .8  pn 10 \
##dt dash[i] lw lW[i] t word(name,i) 
#plot word(dataPvu,1) u 45:37 w lp  \
# ps .8  pn 10 \
#  t "Paraview"
 #------------------------------------------------------------------#
#                                sigmaxx
 #------------------------------------------------------------------#
unset yrange
unset xrange
#set xrange [-1e6:1e6]
#set yrange [-1e6:1e6]
set key below  Left   opaque reverse horizontal samplen 1#spacingfont '\tiny' 
#set format y '\$%4.2t\$'
set format y '\$%4.2t\times10^{%T}\$'
#set x2tics ('\$\times 10^6\$' -.095) nomirror scale 0
#unset x2tics
set ylabel '$\sigma_{xx}$ (pa)' rotate by 90
set output "sigmaxx.tex"
plot for [i=1:words(data)]  word(data,i) u 1:2 w lp  \
 ps .8  pn 10 \
  t word(cases,i)
  #t word(name,i)
#, word(dataPvu,1) u 45:37 w lp  \
# ps .8  pn 10 \
#  t "Paraview"
 #------------------------------------------------------------------#
#                                sigmayy
 #------------------------------------------------------------------#
unset yrange
unset xrange
#set xrange [-1e6:1e6]
#set yrange [-1e6:1e6]
set key below  Left   opaque reverse font '\tiny' 
set format y '\$%4.2t\times10^{%T}\$'
#set x2tics ('\$\times 10^5\$' -.0399) nomirror scale 0
#set format y '\$%4.2t\$'
#set format y '\$%4.2t\times10^{%T}\$'
#set x2tics ('\$\times 10^6\$' -.1) nomirror scale 0
#unset x2tics
set ylabel '$\sigma_{yy}$ (pa)' rotate by 90
set output "sigmayy.tex"
print data
plot for [i=1:words(data)]  word(data,i) u 1:3 w lp  \
 ps .8  pn 10 \
  t word(cases,i) 
  #t word(name,i) 
 #------------------------------------------------------------------#
#                                sigmaxy
 #------------------------------------------------------------------#
unset yrange
unset xrange
#set xrange [-1e6:1e6]
#set yrange [-1e6:1e6]
set key below  Left   opaque reverse font '\tiny' 
set format y '\$%4.2t\times10^{%T}\$'
#set x2tics ('\$\times 10^5\$' -.0399) nomirror scale 0
#set format y '\$%4.2t\$'
#set format y '\$%4.2t\times10^{%T}\$'
#set x2tics ('\$\times 10^6\$' -.1) nomirror scale 0
#unset x2tics
set ylabel '$\sigma_{xy}$ (pa)' rotate by 90
set output "sigmaxy.tex"
plot for [i=1:words(data)]  word(data,i) u 1:5 w lp  \
 ps .8  pn 10 \
  t word(cases,i) 
  #t word(name,i) 
 #------------------------------------------------------------------#
#                          sigmaxy-in focus
 #------------------------------------------------------------------#
unset yrange
unset xrange
set xrange [-.1:0]
set yrange [-2.5e5:2.5e5]
set key below Left   opaque  #reverse font '\tiny' 
set format y '\$%4.2t\times10^{%T}\$'
#set x2tics ('\$\times 10^5\$' -.0399) nomirror scale 0
#set format y '\$%4.2t\$'
#set format y '\$%4.2t\times10^{%T}\$'
#set x2tics ('\$\times 10^6\$' -.1) nomirror scale 0
#unset x2tics
set ylabel '$\sigma_{xy}$ (pa)' rotate by 90
set output "sigmaxyInFocus.tex"
plot for [i=1:words(data)]  word(data,i) u 1:5 w lp  \
 ps .8  pn 10 \
  t word(cases,i) 
  #t word(name,i) 

plotSigma
}

n=0
source userInput.sh
for mesh in $meshType
do
    #for solProc in $solProcs
    #do
        for model in $models
	do
            caseDir="$mesh-$model"
	    path="$caseDir/sampling/"
            for interpScheme in $INTERPSCHEME
            do
                for types in $TYPE
                do
                    for axes in $AXIS 
                    do
                        #filePvu[$n]=$path"pvu.tsv"
                        fileName[$n]="$interpScheme-$types-$axes"
                        filePath[$n]=$path"${fileName[$n]}"
                        cases[$n]="$caseDir"
                        n=$(($n+1))
                    done
                done
            done
	done
    #done
done

rm *eps *tex *aux *log *dvi *pdf
#plot filepath[@] filename[@] cases[@] filepvu[@]
plot filePath[@] fileName[@] cases[@]

#rm *pdf
for i in *.tex; do latex $i;done; for i in *.dvi; do dvipdf $i; done
rm *eps *tex *aux *log *dvi 
