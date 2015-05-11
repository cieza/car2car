clear
reset
fontsize = 12
set terminal png size 520,400 enhanced font "Helvetica,13"
set output "atraso.png"

set grid ytics
set grid xtics
set key left top reverse Left
set ylabel "Atraso"
set xlabel "NºAtacantes"

plot 'teste2.txt' u 1:2 ti "Y1" with lines linetype 1, \
"" u 1:2:3 notitle w errorbars linetype 1, \
"" u 1:4 ti "Y2" with lines linetype 2, \
"" u 1:4:5 notitle w errorbars linetype 2, \
"" u 1:6 ti "Y3" with lines linetype 3, \
"" u 1:6:7 notitle w errorbars linetype 3, \
"" u 1:8 ti "Y4" with lines linetype 4, \
"" u 1:8:9 notitle w errorbars linetype 4