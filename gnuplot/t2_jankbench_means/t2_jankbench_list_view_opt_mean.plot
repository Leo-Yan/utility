set terminal pngcairo size 1200,480 enhanced font 'Ubuntu,9'
set output 't2_jankbench_list_view_opt_mean.png'
set title "Cpuset optimization for JankBench list\\\_view case"
set xlabel "Configurations"
set ylabel "Janks %"
set boxwidth 1.1 absolute
#set style fill   solid 1.00 border lt -1
set xtics norangelimit font ",9"
set yrange [0:80]

$data <<EOD
87.50% 80.50% 89.70% 56.10% 57.60% 45.90%
89.20% 72.90% 89.90% 75.10% 54.90% 58.80%
89.30% 83.80% 80.80% 66.30% 65.90% 40.30%
83.80% 81.80% 84.90% 58.50% 40.70% 84.30%
87.30% 83.10% 88.20% 45.10% 34.70% 42.10%
EOD

stats $data using 1:6 nooutput

#plot $data u 1:5 w lp lt 1 t 'Col 5', '' u 1:(STATS_mean_x) w l lt 1 lw 2 t 'Avg col 5',\
#    '' u 1:10 w lp lt 2 t 'Col 10', '' u 1:(STATS_mean_y) w l lt 2 lw 2 t 'Avg col 10'

set style line 1 lc rgb 'orange';
set style line 2 lc rgb 'pink';
set style line 3 lc rgb 'blue';
set style line 4 lc rgb 'cyan';
set style line 5 lc rgb 'seagreen';
set style line 6 lc rgb 'green';
set style line 7 lc rgb 'brown';
set style line 8 lc rgb 'yellow';
set style line 9 lc rgb 'red';

set boxwidth 0.3
set style data boxplot
#set xtics ("cl1\\\_800MHz" 1, \
#	   "cls1\\\_800MHz\\\_cfg1" 2, "cls1\\\_800MHz\\\_cfg2" 3, "cls1\\\_1113MHz" 4, "cls1\\\_1113MHz\\\_cfg1" 5, "cls1\\\_1113MHz\\\_cfg2" 6)
set xtics ("" 1, "" 2, "" 3, "" 4, "" 5, "" 6)
plot $data u (1):1:xtic(1) title 'cls0\_960MHz\_cls1\_800MHz' lc 1, \
        '' u (2):2 title 'cls0\_960MHz\_cls1\_800MHz\_cpuset\_cfg1' lc 2, \
	'' u (3):3 title 'cls0\_960MHz\_cls1\_800MHz\_cpuset\_cfg2' lc 3, \
	'' u (4):4 title 'cls0\_1113MHz\_cls1\_800MHz' lc 1, \
	'' u (5):5 title 'cls0\_1113MHz\_cls1\_800MHz\_cpuset\_cfg1' lc 2, \
	'' u (6):6 title 'cls0\_1113MHz\_cls1\_800MHz\_cpuset\_cfg2' lc 3

set terminal wxt enhanced font 'Ubuntu,9'
replot

