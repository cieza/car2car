clear
reset
#unset key
fontsize = 12
set terminal png size 520,400 enhanced font "Helvetica,13"
#NP: não proativo ou P: proativo; M: móvel, (segundo) P: poluidor, ou nada
set output "hitXtempoPMP.png"

set grid ytics
set key left top reverse Left
set ylabel "Hit | Miss"
set xlabel "Tempo (s)"

#set style line
se st d l

plot 'with-mob-v2v-pollution-proativo.txt' u 1:2 lt 2 title "Hit", \
'' u 1:3 lt 1 title "Miss"