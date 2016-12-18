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

#no_of_files = len(sys.argv)
#
##if no_of_files <= 1:
# #   sys.exit('Error! No input file') 
#
#parser = argparse.ArgumentParser()
#parser.add_argument('-i', nargs='*', help='Input CSV files')
#args = parser.parse_args()
#
#filenames = args.i
#
#if not filenames:
#    sys.exit('Error! No input file')
#
#outFile = open("./out.txt", "w+")
#
#
#scenarios = {'nenamark score', 'Linpack ST', 'Linpack MT', 'benchmark_score', 'Smartbench: valueProd', 'Smartbench: valueGame', 'overall_score', 'native_score', 'java_score', 'score', 'multicore_score', 'Browser', 'Multicore', 'Metal'}
#
#for name in filenames:
#    outFile.write('{}\n'.format(name))
#    inFile = open(name, "r")
#    inLine = csv.reader(inFile)
#    next(inLine,None)
#    collectValue = defaultdict(list)
#    for row in inLine:
#        condition = row[3]
#        value = row[4]
#        if condition not in scenarios:
#            continue
#        collectValue[condition].append(float(value))
#    
#    for condition, values in collectValue.iteritems():
#         outFile.write('{0}\t{1}\n'.format(condition, sum(values) / len(values)))
#
#    outFile.write('\n')
#
#outFile.close()

scenarios = {

    'recentfling' : [
        'Average 90th Percentile',
        'Average 95th Percentile',
        'Average 99th Percentile',
        'Average Jank',
        'Average Jank%',
        'Total energy'
    ]
}

def parse_file(scene, files):

    write_tag = 0
    outFile = open('/tmp/' + scene, "w")
    outFileFinal = open('./' + scene, "w")

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

            if row[1] != scene:
                continue

            condition = row[3]
            value = row[4]

            if condition not in scenarios[scene]:
                continue

            collectValue[condition].append(float(value))

        # sort items
        collectValue = sorted(collectValue.items())

        if write_tag == 0:
            outFile.write('test_name')
            for condition, values in collectValue:
                condition = condition.replace(" ", "_")
                outFile.write(' ' + condition)
            outFile.write('\n')
            write_tag = 1

        outFile.write(name.split(os.path.sep)[0] + ' ')
        for condition, values in collectValue:
            outFile.write(' ' + str(values[0]))
        outFile.write('\n')

    outFile.close()

    # convert matrix
    with open('/tmp/' + scene) as f:
        lis = [x.split() for x in f]

    for x in zip(*lis):
        print x
        for y in x:
            print y
            outFileFinal.write(y + ' ')
        outFileFinal.write('\n')

    outFileFinal.close()

    cmd_str = 'gnuplot -e "filename=\''+scene+'\''+'" plot_result_template.plot'
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
