#!/bin/sh

dump_regs()
{
	if [ -z $1 ]; then
		echo "Please input reg start address"
		exit 1
	fi

	if [ -z $2 ]; then
		echo "Please input reg end address"
		exit 1
	fi

	addr=$1
	end=$2
	while [ $addr -le $end ];
	do
		reg=`devmem $addr w`
		printf "[0x%08x]=0x%08x\n" $addr $reg
		addr=$(( $addr + 4 ))
	done
}

dump_gpio_regs()
{
	gpio_base=$1
	gpio_data_0=$(( $1 + 4 ))
	gpio_data_1=$(( $1 + 8 ))
	gpio_data_2=$(( $1 + $((0x10)) ))
	gpio_data_3=$(( $1 + $((0x20)) ))
	gpio_data_4=$(( $1 + $((0x40)) ))
	gpio_data_5=$(( $1 + $((0x80)) ))
	gpio_data_6=$(( $1 + $((0x100)) ))
	gpio_data_7=$(( $1 + $((0x200)) ))

	gpio_dir=$(( $1 + $((0x400)) ))
	gpio_is=$(( $1 + $((0x404)) ))
	gpio_be=$(( $1 + $((0x408)) ))
	gpio_iev=$(( $1 + $((0x40c)) ))
	gpio_ie=$(( $1 + $((0x410)) ))
	gpio_ris=$(( $1 + $((0x414)) ))
	gpio_mis=$(( $1 + $((0x418)) ))
	gpio_ic=$(( $1 + $((0x41c)) ))
	gpio_afsel=$(( $1 + $((0x420)) ))

	gpio_ie2=$(( $1 + $((0x500)) ))
	gpio_ie3=$(( $1 + $((0x504)) ))
	gpio_mis2=$(( $1 + $((0x530)) ))
	gpio_mis3=$(( $1 + $((0x534)) ))

	gpio_debbyp=$(( $1 + $((0x618)) ))
	gpio_clkcycle=$(( $1 + $((0x61c)) ))
	gpio_clkdiv=$(( $1 + $((0x620)) ))

	dump_regs $gpio_data_0 $gpio_data_1
	dump_regs $gpio_data_2 $gpio_data_2
	dump_regs $gpio_data_3 $gpio_data_3
	dump_regs $gpio_data_4 $gpio_data_4
	dump_regs $gpio_data_5 $gpio_data_5
	dump_regs $gpio_data_6 $gpio_data_6
	dump_regs $gpio_data_7 $gpio_data_7

	dump_regs $gpio_dir $gpio_afsel

	dump_regs $gpio_ie2 $gpio_ie3
	dump_regs $gpio_mis2 $gpio_mis3

	dump_regs $gpio_debbyp $gpio_clkdiv
}

echo "\n\n"

echo "Dump iocg on registers:"
dump_regs $((0xF8001800)) $((0xF8001874))
echo "\n\n"

echo "Dump iocg off registers:"
dump_regs $((0xF7010800)) $((0xF7010a88))
echo "\n\n"

echo "Dump iomg off registers:"
dump_regs $((0xF7010000)) $((0xF7010278))
echo "\n\n"

echo "Dump gpio 0 registers:"
dump_gpio_regs $((0xF8011000))
echo "\n\n"

echo "Dump gpio 1 registers:"
dump_gpio_regs $((0xF8012000))
echo "\n\n"

echo "Dump gpio 2 registers:"
dump_gpio_regs $((0xF8013000))
echo "\n\n"

echo "Dump gpio 3 registers:"
dump_gpio_regs $((0xF8014000))
echo "\n\n"

echo "Dump gpio 4 registers:"
dump_gpio_regs $((0xF7020000))
echo "\n\n"

echo "Dump gpio 5 registers:"
dump_gpio_regs $((0xF7021000))
echo "\n\n"

echo "Dump gpio 6 registers:"
dump_gpio_regs $((0xF7022000))
echo "\n\n"

echo "Dump gpio 7 registers:"
dump_gpio_regs $((0xF7023000))
echo "\n\n"

echo "Test:"
dump_regs $((0xf7032580)) $((0xf703259c))
echo "\n\n"
