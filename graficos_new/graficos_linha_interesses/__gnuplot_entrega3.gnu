clear
reset
#unset key
fontsize = 12
set terminal png size 520,400 enhanced font "Helvetica,13"
#NP: não proativo, M: móvel, P: poluidor
set output "entregaXtempoNPP.png"

set grid ytics
set key left top reverse Left
set ylabel "Interesses"
set xlabel "Tempo (s)"

#set style line
se st d l

plot 'no-mob-pollution-nao-proativo.txt' u 1:2 title "Enviados", \
'' u 1:3 title "Satisfeitos"