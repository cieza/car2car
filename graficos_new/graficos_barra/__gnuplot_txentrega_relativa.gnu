clear
reset
#unset key
fontsize = 12
set terminal png size 520,400 enhanced font "Helvetica,13"
set output "txentrega_relativa.png"

# Select histogram data
set style data histogram

set grid ytics
set key left top reverse Left
set ylabel "Taxa de Entrega Relativa"
set yrange [0:1]

# Give the bars a plain fill pattern, and draw a solid line around them.
#set style fill solid border
set style fill pattern border

set style histogram clustered
#set style histogram errorbars linewidth 0.1
#set style histogram errorbars gap 2 lw 1
#set style histogram errorbars gap 2 lt -1 lw 2
#set style histogram errorbars
#set bars front

#plot for [COL=2:5] 'txentrega.tsv' using COL:xticlabels(1) title columnheader
plot 'txentrega_relativa.txt' using 2:xtic(1) title "with-mob-v2v-pollution" fill pattern 5, \
'' using 3 title "no-mob" fill pattern 2, \
'' using 4 title "with-mob-v2v" fill pattern 6, \
'' using 5 title "no-mob-pollution" fill pattern 4