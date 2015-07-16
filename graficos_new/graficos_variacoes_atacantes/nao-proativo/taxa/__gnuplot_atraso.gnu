clear
reset
fontsize = 12
set terminal png size 520,400 enhanced font "Helvetica,13"
set output "atraso2-np.png"

#set title "Não proativo"

set grid ytics
set grid xtics
set xrange [30:150]
set yrange [0:150]
set key left top reverse Left
set ylabel "Atraso (s)"
set xlabel "Taxa de Envio de Interesses"

plot 'atraso.txt' u 1:2 ti "Sem mobilidade" with lines linetype 1, \
"" u 1:2:3 notitle w errorbars linetype 1, \
"" u 1:4 ti "Com mobilidade" with lines linetype 2, \
"" u 1:4:5 notitle w errorbars linetype 2