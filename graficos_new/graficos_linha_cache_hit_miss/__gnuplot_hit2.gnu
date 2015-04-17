clear
reset
#unset key
fontsize = 12
set terminal png size 520,400 enhanced font "Helvetica,13"
#NP: não proativo, M: móvel, P: poluidor
set output "hitXtempoNPM.png"

set grid ytics
set key left top reverse Left
set ylabel "Hit | Miss"
set xlabel "Tempo (s)"

set format y "%.0s*10^%T"
set yrange [0:250000]

#set style line
se st d l

plot 'with-mob-v2v-nao-proativo.txt' u 1:2 title "Miss", \
'' u 1:3 title "Hit"