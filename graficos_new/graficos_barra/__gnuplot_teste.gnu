#clear
reset
fontsize = 12
set terminal png size 520,400 enhanced font "Helvetica,13"
set output "atraso.png"
set style histogram errorbars lt -1 lw 1
set style fill pattern border

set style data histogram
set bars front

set grid ytics
set key left top reverse Left
set ylabel "Atraso"

plot 'teste.txt' using 2:3:xtic(1) ti "with-mob-v2v-pollution" fill pattern 5, \
"" using 4:5:xtic(1) ti "no-mob" fill pattern 2, \
"" using 6:7:xtic(1) ti "with-mob-v2v" fill pattern 6, \
"" using 8:9:xtic(1) ti "no-mob-pollution" fill pattern 4;