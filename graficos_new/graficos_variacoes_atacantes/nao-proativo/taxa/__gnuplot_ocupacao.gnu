clear
reset
fontsize = 12
set terminal png size 520,400 enhanced font "Helvetica,13"
set output "ocupacao2-np.png"

#set title "Não proativo"

set grid ytics
set grid xtics
set yrange [0.7:1.0]
set key right bottom reverse Left
set ylabel "Ocupação Maliciosa"
set xlabel "Taxa de Envio de Interesses"

plot 'ocupacao.txt' u 1:2 ti "Sem mobilidade" with lines linetype 1, \
"" u 1:2:3 notitle w errorbars linetype 1, \
"" u 1:4 ti "Com mobilidade" with lines linetype 2, \
"" u 1:4:5 notitle w errorbars linetype 2