set terminal pngcairo noenhanced size 1024,600 font 'Ubuntu,9'
set output sprintf('%s.png', filename)
set grid
set title "EAS Performance and Power Comparision"
set ylabel "Performance and Power Result"

set boxwidth 0.9 absolute
set style fill   solid 1.00 border lt -1
set key outside right
set style histogram clustered gap 1 title  offset character 0, 0, 0
set datafile missing '-'
set style data histograms
#set xtics border in scale 0,0 nomirror rotate by -45  offset character 0, 0, 0 autojustify
set xtics rotate by -45
#set xtics norangelimit font ",11"
set xtics   ()
i = 22
set style line 1 lc rgb 'orange';
set style line 2 lc rgb 'pink';
set style line 3 lc rgb 'blue';
set style line 4 lc rgb 'cyan';
set style line 5 lc rgb 'seagreen';
set style line 6 lc rgb 'green';
set style line 7 lc rgb 'brown';
set style line 8 lc rgb 'yellow';
set style line 9 lc rgb 'red';

plot for [i=2:11] filename using i:xtic(1) ti col ls i-1;

set terminal wxt noenhanced font 'Ubuntu,9'
replot
