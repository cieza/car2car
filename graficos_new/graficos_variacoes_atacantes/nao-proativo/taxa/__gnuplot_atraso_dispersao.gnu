clear
reset
fontsize = 12
set terminal png size 520,400 enhanced font "Helvetica,13"
set output "atraso2-np.png"

#set title "Não proativo"

set grid ytics
set grid xtics
set xrange [30:150]
set yrange [0:85]
set key left top reverse Left
set key box
set ylabel "Atraso (s)"
set xlabel "Taxa de Envio"

plot 'atraso_disp.txt' u 2:3 ti "Sem mobilidade" with points pt 5, \
"" u 2:4 ti "Com mobilidade" with points pt 9