#!/usr/bin/python

import array
import argparse
import csv
import os
import sys
import sys, getopt
import collections
from os import system, remove
from collections import defaultdict

scenarios = {

    'idle' : [
        'BOARD_ENERGY_BIG',
        'BOARD_ENERGY_LITTLE'
    ],

    'audio' : [
        'BOARD_ENERGY_BIG',
        'BOARD_ENERGY_LITTLE'
    ],

    'video' : [
        'BOARD_ENERGY_BIG',
        'BOARD_ENERGY_LITTLE'
    ],

    'recentfling' : [
        'Average 90th Percentile',
        'Average 95th Percentile',
        'Average 99th Percentile',
        'Average Jank',
        'Average Jank%',
        'BOARD_ENERGY_BIG',
        'BOARD_ENERGY_LITTLE'
    ],

    'galleryfling' : [
        'Average 90th Percentile',
        'Average 95th Percentile',
        'Average 99th Percentile',
        'Average Jank',
        'Average Jank%',
        'BOARD_ENERGY_BIG',
        'BOARD_ENERGY_LITTLE'
    ],

    'browserfling' : [
        'Average 90th Percentile',
        'Average 95th Percentile',
        'Average 99th Percentile',
        'Average Jank',
        'Average Jank%',
        'BOARD_ENERGY_BIG',
        'BOARD_ENERGY_LITTLE'
    ],


    'linpack' : [
        'Linpack ST',
        'Linpack MT',
        'Total energy',
        'BOARD_ENERGY_BIG',
        'BOARD_ENERGY_LITTLE'
    ],

    'quadrant' : [
        'benchmark_score',
        'Total energy'
    ],

    'smartbench' : [
        'Smartbench: valueProd',
        'Smartbench: valueGame',
        'Total energy'
    ],

    'geekbench' : [
        'score',
        'multicore_score',
        'BOARD_ENERGY_BIG',
        'BOARD_ENERGY_LITTLE'
    ],

    'nenamark' : [
        'nenamark score',
        'Total energy'
    ],

    'vellamo_overall' : [
        'Browser',
        'Multicore',
        'Metal',
        'BOARD_ENERGY_BIG',
        'BOARD_ENERGY_LITTLE'
    ],

    'vellamo_Browser' : [
        'Browser',
        'html5.Crossfader',
        'html5.Kruptein',
        'html5.CanvasRefocus',
        'html5.PixelBlender',
        'html5.CanvasAquarium',
        'html5.CSS3DFish',
        'html5.Jellyfish',
        'html5.DOMTraversal',
        'html5.JSBandwidth',
        'html5.CanvasRotate',
        'html5.OceanScroller',
        'html5.PageLoadPerformance',
        'html5.TextReflow',
        'html5.SunSpider',
        'html5.Octane',
        'BOARD_ENERGY_BIG',
        'BOARD_ENERGY_LITTLE'
    ],

    'vellamo_Multicore' : [
        'Multicore',
        'multi.Linpack',
        'multi.LinpackJava',
        'multi.Stream',
        'multi.Membench',
        'multi.Sysbench',
        'multi.Threadbench',
        'multi.Parsec',
        'multi.ProcessCommunication',
        'BOARD_ENERGY_BIG',
        'BOARD_ENERGY_LITTLE'
    ],

    'vellamo_Metal' : [
        'Metal',
        'metal.Dhrystone',
        'metal.Linpack',
        'metal.Kbench',
        'metal.Stream',
        'metal.RamJam',
        'metal.FlashBench',
        'BOARD_ENERGY_BIG',
        'BOARD_ENERGY_LITTLE'
    ],

}

def parse_file(scene, files):

    write_tag = 0
    out_file_tmp = open('/tmp/plot_' + scene, "w")

    for name in files:

        print name
        print name.split(os.path.sep)[0]

        in_file = open(name, "r")
        in_line = csv.reader(in_file)
        next(in_line, None)
        collectValue = defaultdict(list)

        for row in in_line:
            #print row[3]
            #print row[4]

            if row[1] not in scene:
                continue

            condition = row[3]
            value = row[4]

            if condition not in scenarios[scene]:
                continue

            collectValue[condition].append(float(value))

        if bool(collectValue) == False:
            break

        for i in xrange(len(collectValue['BOARD_ENERGY_BIG'])):
            collectValue['BOARD_ENERGY'].append(collectValue['BOARD_ENERGY_BIG'][i] + collectValue['BOARD_ENERGY_LITTLE'][i])

        print collectValue['BOARD_ENERGY_BIG']
        print collectValue['BOARD_ENERGY_LITTLE']
        print collectValue['BOARD_ENERGY']

        # sort items
        collectValue = sorted(collectValue.items())

        if write_tag == 0:
            out_file_tmp.write('test_name')
            for condition, values in collectValue:
                condition = condition.replace(" ", "_")
                out_file_tmp.write(' ' + condition)
            out_file_tmp.write('\n')
            write_tag = 1

        out_file_tmp.write(name.split(os.path.sep)[0] + ' ')
        for condition, values in collectValue:
            print condition
            print values
            out_file_tmp.write(' ' + str(sum(values) / len(values)))
        out_file_tmp.write('\n')

    out_file_tmp.close()

    # convert matrix
    print "file size"
    print os.stat('/tmp/plot_' + scene).st_size
    if os.stat('/tmp/plot_' + scene).st_size == 0:
        print "Have no data for " + scene
        return

    with open('/tmp/plot_' + scene) as f:
        lis = [x.split() for x in f]

    outFileFinal = open('./plot_' + scene, "w")
    for x in zip(*lis):
        print x
        for y in x:
            print y
            outFileFinal.write(y + ' ')
        outFileFinal.write('\n')

    outFileFinal.close()

    # Use gnuplot template to draw pictures
    cmd_str = 'gnuplot -e "filename=\''+'plot_'+scene+'\''+'" plot_result_template.plot'
    system(cmd_str)

def main(argv):

    files = []

    for fn in sys.argv[1:]:
        print fn
        if not os.path.isfile(fn):
            print "file don't exists:", fn
            sys.exit(1)
        files.append(fn)

    for s in scenarios:
        parse_file(s, files)

if __name__ == "__main__":
    main(sys.argv[1:])
