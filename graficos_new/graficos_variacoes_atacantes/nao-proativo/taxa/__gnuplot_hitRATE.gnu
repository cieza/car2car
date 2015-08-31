clear
reset
fontsize = 12
set terminal png size 520,400 enhanced font "Helvetica,13"
set output "hitrate3-np.png"

#set title "Não proativo"

set grid ytics
set grid xtics
set yrange [0:0.3]
set xrange [40:650]
set key left bottom reverse Left
set ylabel "hit Rate"
set xlabel "Taxa de Envio de Interesses"

plot 'cache_hitRATE.txt' u 2:3 ti "Sem mobilidade" with lines linetype 1, \
"" u 2:3:4 notitle w errorbars linetype 1, \
"" u 2:5 ti "Com mobilidade" with lines linetype 2, \
"" u 2:5:6 notitle w errorbars linetype 2