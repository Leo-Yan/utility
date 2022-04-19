set terminal pngcairo size 1200,480 enhanced font 'Ubuntu,9'
set output 't2_jankbench_list_view_opt_mean.png'
set title "Cpuset optimization for JankBench list\\\_view case"
set xlabel "Configurations"
set ylabel "Janks %"
set boxwidth 0.9 absolute
#set style fill   solid 1.00 border lt -1
set xtics norangelimit font ",9"
set yrange [0:80]

$data <<EOD
44.9%% 33.00% 24.10% 23.3% 25.1% 30.2%
44.00% 36.00% 25.10% 22.9% 31.8% 23.3%
36.70% 37.80% 23.40% 23.0% 27.0% 24.0%
28.50% 40.90% 48.70% 38.6% 35.4% 23.0%
34.10% 31.90% 34.20% 28.0% 27.5% 28.7%
EOD

stats $data using 1:6 nooutput

#plot $data u 1:5 w lp lt 1 t 'Col 5', '' u 1:(STATS_mean_x) w l lt 1 lw 2 t 'Avg col 5',\
#    '' u 1:10 w lp lt 2 t 'Col 10', '' u 1:(STATS_mean_y) w l lt 2 lw 2 t 'Avg col 10'

set boxwidth 0.3
set style data boxplot
#set xtics ("cl1\\\_800MHz" 1, \
#	   "cls1\\\_800MHz\\\_cfg1" 2, "cls1\\\_800MHz\\\_cfg2" 3, "cls1\\\_1113MHz" 4, "cls1\\\_1113MHz\\\_cfg1" 5, "cls1\\\_1113MHz\\\_cfg2" 6)
set xtics ("" 1, "" 2, "" 3, "" 4, "" 5, "" 6)
plot $data u (1):1:xtic(1) title 'cls1\_800MHz', \
        '' u (2):2 title 'cls1\_800MHz\_cpuset\_cfg1', \
	'' u (3):3 title 'cls1\_800MHz\_cpuset\_cfg2', \
	'' u (4):4 title 'cls1\_1113MHz', \
	'' u (5):5 title 'cls1\_1113MHz\_cpuset\_cfg1', \
	'' u (6):6 title 'cls1\_1113MHz\_cpuset\_cfg2'

set terminal wxt enhanced font 'Ubuntu,9'
replot

