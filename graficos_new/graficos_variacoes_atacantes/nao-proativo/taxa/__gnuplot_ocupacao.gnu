clear
reset
fontsize = 12
set terminal png size 520,400 enhanced font "Helvetica,13"
set output "ocupacao3-np.png"

#set title "Não proativo"

set grid ytics
set grid xtics
set yrange [0.7:1.0]
set xrange [40:650]
set key right top reverse Left
set ylabel "Ocupação Maliciosa"
set xlabel "Taxa de Envio de Interesses"

plot 'ocupacao.txt' u 2:3 ti "Sem mobilidade" with lines linetype 1, \
"" u 2:3:4 notitle w errorbars linetype 1, \
"" u 2:5 ti "Com mobilidade" with lines linetype 2, \
"" u 2:5:6 notitle w errorbars linetype 2