clear
reset
fontsize = 12
set terminal png size 520,400 enhanced font "Helvetica,13"
set output "atraso.png"
set style fill pattern border

set style data histogram
set style histogram errorbars
#set bars front

set grid ytics
#set key left top reverse Left
set ylabel "Tempo de Recuperação (s)"
set yrange [0:70]
set datafile separator ","

plot 'atraso.txt' using 2:3:xtic(1) ti "Mobilidade com Poluidor" fill pattern 5, \
"" using 4:5:xtic(1) ti "Sem Mobilidade" fill pattern 2, \
"" using 6:7:xtic(1) ti "Mobilidade" fill pattern 6, \
"" using 8:9:xtic(1) ti "Sem Mobilidade com Poluidor" fill pattern 4;