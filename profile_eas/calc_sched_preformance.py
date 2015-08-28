#!/usr/bin/env python

import os
import os.path
import sys, getopt
import binascii
import struct
import string
import re

class calc_perf(object):

    # calculate every tasks perf
    thread_perf = [0, 0, 0, 0, 0, 0, 0, 0]

    # normalize perf according to all tasks
    total_perf = 0
    avg_perf = 0

    thread_num = 0

    prefix = ""

    def __init__(self, thread_num, prefix, ofile):

        try:
            self.fp = open(ofile, "aw")
        except IOError, e:
            print "*** file open error:", e
            sys.exit(3)

        self.thread_num = thread_num
        self.prefix = prefix

        print self.thread_num

        i = 0
        while (i < int(self.thread_num)):
            filename = self.prefix + str(i) + ".log"
            print i

            i = i + 1

            if not os.path.isfile(filename):
                print "Error: file don't exists:", filename
                sys.exit(1)

    def __del__(self):
        self.fp.close()

    def parse(self):

        self.total_perf = 0
        i = 0
        while (i < int(self.thread_num)):
            filename = self.prefix + str(i) + ".log"


            perf = 0
            perf_cnt = 0

            with open(filename, "rb") as infile:
                lines = infile.readlines()[2:]
                for line in lines:
                    line = line.lstrip(' ')     # remove head space chars
                    line = line.rstrip('\r\n')  # remove tail return chars
                    line = re.sub(' +', ' ', line)
                    array = line.split(" ")
                    perf = perf + (int(array[7]) * 1024 / (int(array[9]) - int(array[8])))
                    perf_cnt = perf_cnt + 1

                perf = perf / perf_cnt
                self.thread_perf[i] = perf

            self.total_perf = self.total_perf + perf
            i = i + 1

        self.avg_perf = self.total_perf / int(self.thread_num)

        i = 0
        while (i < int(self.thread_num)):
            self.fp.write("cpu" + str(i) + ": " + str(self.thread_perf[i]) + "\n")
            i = i + 1

        self.fp.write("Performan (sum): " + str(self.total_perf) + "\n")
        self.fp.write("Performan (avg): " + str(self.avg_perf) + "\n")

def main(argv):
    try:
        opts, args = getopt.getopt(argv, "ho:", ["threads=", "logprefix="])
    except getopt.GetoptError:
        print 'calc_idle_diff.py -o <result.txt> -i <input.txt>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'calc_idle_diff.py -o <result.txt> -i <input.txt>'
            sys.exit(1)
        elif opt == '-o':
            ofile = arg
        elif opt in ("--threads"):
            thread_num = arg
        elif opt in ("--logprefix"):
            prefix = arg

    #if not os.path.isfile(ifile):
    #    print "Error: file don't exists:", ifile
    #    sys.exit(1)

    print "Parse scheduler performance:"
    print " thread numbers: " + thread_num
    print " log path:", prefix
    calc = calc_perf(thread_num, prefix, ofile)
    calc.parse()

if __name__ == "__main__":
    main(sys.argv[1:])
