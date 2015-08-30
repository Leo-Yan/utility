#!/usr/bin/env python

import os
import os.path
import sys, getopt
import binascii
import struct
import string
import re

class calc_pstate_time(object):

    baseln_cls = { '208.00MHz':0, '432.00MHz':0, '729.00MHz':0, '960.00MHz':0, '1.20GHz':0, 'cycles':0 };
    baseln_cpu = { '208.00MHz':0, '432.00MHz':0, '729.00MHz':0, '960.00MHz':0, '1.20GHz':0, 'cycles':0 };

    easdis_cls = { '208.00MHz':0, '432.00MHz':0, '729.00MHz':0, '960.00MHz':0, '1.20GHz':0, 'cycles':0 };
    easdis_cpu = { '208.00MHz':0, '432.00MHz':0, '729.00MHz':0, '960.00MHz':0, '1.20GHz':0, 'cycles':0 };

    easndm_cls = { '208.00MHz':0, '432.00MHz':0, '729.00MHz':0, '960.00MHz':0, '1.20GHz':0, 'cycles':0 };
    easndm_cpu = { '208.00MHz':0, '432.00MHz':0, '729.00MHz':0, '960.00MHz':0, '1.20GHz':0, 'cycles':0 };

    easchd_cls = { '208.00MHz':0, '432.00MHz':0, '729.00MHz':0, '960.00MHz':0, '1.20GHz':0, 'cycles':0 };
    easchd_cpu = { '208.00MHz':0, '432.00MHz':0, '729.00MHz':0, '960.00MHz':0, '1.20GHz':0, 'cycles':0 };

    def __init__(self, ofile):
        try:
            self.fp = open(ofile, "wb+")
        except IOError, e:
            print "*** file open error:", e
            sys.exit(3)

    def __del__(self):
        self.fp.close()

    def statistic(self, ifile, stat0, stat1):

        start = 0

        with open(ifile, "rb") as infile:
            for line in infile:

                if ("P-state" in line):
                    title = line
                    separator = next(infile)
                    start = 1

                while start == 1:
                    string = next(infile)

                    if string in ['\n', '\r\n']:
                        start = 0

                    cluster_strings = ('clusterA', 'clusterB')
                    if any(s in string for s in cluster_strings):
                        head = next(infile)
                        opp  = next(infile)

                        #print "cluster"
                        while ('---' not in opp):
                            opp = re.sub(' +', '', opp)
                            opp = opp.lstrip('|')     # remove head space chars
                            array = opp.split("|")

                            if ('us' in array[4]):
                                array[4] = array[4].rstrip('us')
                                time = float(array[4])
                                time = time / 1000
                            elif ('ms' in array[4]):
                                array[4] = array[4].rstrip('ms')
                                time = float(array[4])
                            elif ('s' in array[4]):
                                array[4] = array[4].rstrip('s')
                                time = float(array[4])
                                time = time * 1000

                            stat0[array[0]] = stat0[array[0]] + time
                            opp = next(infile)

                    cpu_strings = ('cpu0', 'cpu1', 'cpu2', 'cpu3', 'cpu4', 'cpu5', 'cpu6', 'cpu7')
                    if any(s in string for s in cpu_strings):
                        head = next(infile)
                        opp  = next(infile)

                        #print "cpu"
                        while ('---' not in opp):
                            opp = re.sub(' +', '', opp)
                            opp = opp.lstrip('|')     # remove head space chars
                            array = opp.split("|")

                            if ('us' in array[4]):
                                array[4] = array[4].rstrip('us')
                                time = float(array[4])
                                time = time / 1000
                            elif ('ms' in array[4]):
                                array[4] = array[4].rstrip('ms')
                                time = float(array[4])
                            elif ('s' in array[4]):
                                array[4] = array[4].rstrip('s')
                                time = float(array[4])
                                time = time * 1000

                            stat1[array[0]] = stat1[array[0]] + time
                            opp = next(infile)

        stat0['cycles'] = stat0['208.00MHz'] * 208 + stat0['432.00MHz'] * 432 + stat0['729.00MHz'] * 729 + stat0['960.00MHz'] * 960 + stat0['1.20GHz'] * 1200
        stat1['cycles'] = stat1['208.00MHz'] * 208 + stat1['432.00MHz'] * 432 + stat1['729.00MHz'] * 729 + stat1['960.00MHz'] * 960 + stat1['1.20GHz'] * 1200

    def calc_percentage(self, a, b):
        percentage = float(a) - float(b)
        if b == 0:
            b = 1.0
        percentage = (1.0 * percentage / float(b)) * 100

        if percentage > 0:
            self.fp.write(' %+11.2f' % percentage + "%")
        else:
            self.fp.write(' %11.2f' % percentage + "%")

    def add_log(self, stat0, stat1):
        self.calc_percentage(stat0['208.00MHz'], stat1['208.00MHz'])
        self.fp.write("|")
        self.calc_percentage(stat0['432.00MHz'], stat1['432.00MHz'])
        self.fp.write("|")
        self.calc_percentage(stat0['729.00MHz'], stat1['729.00MHz'])
        self.fp.write("|")
        self.calc_percentage(stat0['960.00MHz'], stat1['960.00MHz'])
        self.fp.write("|")
        self.calc_percentage(stat0['1.20GHz'],   stat1['1.20GHz'])
        self.fp.write("|")
        self.calc_percentage(stat0['cycles'],    stat1['cycles'])
        self.fp.write("|\n")

    def parse(self, ifile1, ifile2, ifile3, ifile4):

        self.statistic(ifile1, self.baseln_cls, self.baseln_cpu)
        self.statistic(ifile2, self.easdis_cls, self.easdis_cpu)
        self.statistic(ifile3, self.easndm_cls, self.easndm_cpu)
        self.statistic(ifile4, self.easchd_cls, self.easchd_cpu)

        self.fp.write("P-State Statistics\n\n")
        self.fp.write("-------------------------------------------------------------------------------------------------\n")
        self.fp.write("| Cluster Level (ms)                                                                            |\n")
        self.fp.write("------ ------------------------------------------------------------------------------------------\n")
        self.fp.write("| Item      |     208MHz  |     432MHz  |     729MHz  |     960MHz  |     1.2GHz  |   Cycles    |\n");
        self.fp.write("-------------------------------------------------------------------------------------------------\n")

        self.fp.write("| MAINLINE  |")
        self.fp.write(' %11.2f' % self.baseln_cls['208.00MHz'])
        self.fp.write(" |")
        self.fp.write(' %11.2f' % self.baseln_cls['432.00MHz'])
        self.fp.write(" |")
        self.fp.write(' %11.2f' % self.baseln_cls['729.00MHz'])
        self.fp.write(" |")
        self.fp.write(' %11.2f' % self.baseln_cls['960.00MHz'])
        self.fp.write(" |")
        self.fp.write(' %11.2f' % self.baseln_cls['1.20GHz'])
        self.fp.write(" |")
        self.fp.write(' %11.2f' % self.baseln_cls['cycles'])
        self.fp.write(" |\n")

        self.fp.write("| EAS DIS   |")
        self.add_log(self.easdis_cls, self.baseln_cls)

        self.fp.write("| EAS NDM   |")
        self.add_log(self.easndm_cls, self.baseln_cls)

        self.fp.write("| EAS SCHED |")
        self.add_log(self.easchd_cls, self.baseln_cls)

        self.fp.write("-------------------------------------------------------------------------------------------------\n\n")

        self.fp.write("-------------------------------------------------------------------------------------------------\n")
        self.fp.write("| CPU Level (ms)                                                                                |\n")
        self.fp.write("------ ------------------------------------------------------------------------------------------\n")
        self.fp.write("| Item      |     208MHz  |     432MHz  |     729MHz  |     960MHz  |     1.2GHz  |   Cycles    |\n");
        self.fp.write("-------------------------------------------------------------------------------------------------\n")

        self.fp.write("| MAINLINE  |")
        self.fp.write(' %11.2f' % self.baseln_cpu['208.00MHz'])
        self.fp.write(" |")
        self.fp.write(' %11.2f' % self.baseln_cpu['432.00MHz'])
        self.fp.write(" |")
        self.fp.write(' %11.2f' % self.baseln_cpu['729.00MHz'])
        self.fp.write(" |")
        self.fp.write(' %11.2f' % self.baseln_cpu['960.00MHz'])
        self.fp.write(" |")
        self.fp.write(' %11.2f' % self.baseln_cpu['1.20GHz'])
        self.fp.write(" |")
        self.fp.write(' %11.2f' % self.baseln_cpu['cycles'])
        self.fp.write(" |\n")

        self.fp.write("| EAS DIS   |")
        self.add_log(self.easdis_cpu, self.baseln_cpu)

        self.fp.write("| EAS NDM   |")
        self.add_log(self.easndm_cpu, self.baseln_cpu)

        self.fp.write("| EAS SCHED |")
        self.add_log(self.easchd_cpu, self.baseln_cpu)

        self.fp.write("-------------------------------------------------------------------------------------------------\n\n")

        #print(self.baseln_cls['208.00MHz']);
        #print(self.baseln_cls['432.00MHz']);
        #print(self.baseln_cls['729.00MHz']);
        #print(self.baseln_cls['960.00MHz']);
        #print(self.baseln_cls['1.20GHz']);

        #print(self.baseln_cpu['208.00MHz']);
        #print(self.baseln_cpu['432.00MHz']);
        #print(self.baseln_cpu['729.00MHz']);
        #print(self.baseln_cpu['960.00MHz']);
        #print(self.baseln_cpu['1.20GHz']);

        #print(self.easdis_cls['208.00MHz']);
        #print(self.easdis_cls['432.00MHz']);
        #print(self.easdis_cls['729.00MHz']);
        #print(self.easdis_cls['960.00MHz']);
        #print(self.easdis_cls['1.20GHz']);

        #print(self.easdis_cpu['208.00MHz']);
        #print(self.easdis_cpu['432.00MHz']);
        #print(self.easdis_cpu['729.00MHz']);
        #print(self.easdis_cpu['960.00MHz']);
        #print(self.easdis_cpu['1.20GHz']);

        #print(self.easndm_cls['208.00MHz']);
        #print(self.easndm_cls['432.00MHz']);
        #print(self.easndm_cls['729.00MHz']);
        #print(self.easndm_cls['960.00MHz']);
        #print(self.easndm_cls['1.20GHz']);

        #print(self.easndm_cpu['208.00MHz']);
        #print(self.easndm_cpu['432.00MHz']);
        #print(self.easndm_cpu['729.00MHz']);
        #print(self.easndm_cpu['960.00MHz']);
        #print(self.easndm_cpu['1.20GHz']);

        #print(self.easchd_cls['208.00MHz']);
        #print(self.easchd_cls['432.00MHz']);
        #print(self.easchd_cls['729.00MHz']);
        #print(self.easchd_cls['960.00MHz']);
        #print(self.easchd_cls['1.20GHz']);

        #print(self.easchd_cpu['208.00MHz']);
        #print(self.easchd_cpu['432.00MHz']);
        #print(self.easchd_cpu['729.00MHz']);
        #print(self.easchd_cpu['960.00MHz']);
        #print(self.easchd_cpu['1.20GHz']);


def main(argv):
    try:
        opts, args = getopt.getopt(argv, "h:", ["ifile1=", "ifile2=", "ifile3=", "ifile4=", "ofile="])
    except getopt.GetoptError:
        print 'calc_idle_diff.py -o <result.txt> -i <input.txt>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'calc_idle_diff.py -o <result.txt> -i <input.txt>'
            sys.exit(1)
        elif opt in ("--ifile1"):
            ifile1 = arg
        elif opt in ("--ifile2"):
            ifile2 = arg
        elif opt in ("--ifile3"):
            ifile3 = arg
        elif opt in ("--ifile4"):
            ifile4 = arg
        elif opt in ("--ofile"):
            ofile = arg

    print "Input file:", ifile1, ifile2, ifile3, ifile4
    print "Output file:", ofile

    if not os.path.isfile(ifile1):
        print "Error: file don't exists:", ifile1
        sys.exit(1)

    if not os.path.isfile(ifile2):
        print "Error: file don't exists:", ifile2
        sys.exit(1)

    if not os.path.isfile(ifile3):
        print "Error: file don't exists:", ifile3
        sys.exit(1)

    if not os.path.isfile(ifile4):
        print "Error: file don't exists:", ifile4
        sys.exit(1)

    calc = calc_pstate_time(ofile)
    calc.parse(ifile1, ifile2, ifile3, ifile4)

if __name__ == "__main__":
    main(sys.argv[1:])
