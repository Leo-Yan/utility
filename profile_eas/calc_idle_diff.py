#!/usr/bin/env python

import os
import os.path
import sys, getopt
import binascii
import struct
import string
import re

class calc_idle_diff(object):

    c1_str = {
        'mainln':"|      WFI |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |",
        'easdis':"|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |",
        'easndm':"|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |",
        'easchd':"|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |",
    };

    c2_str = {
        'mainln':"|      C2  |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |",
        'easdis':"|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |",
        'easndm':"|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |",
        'easchd':"|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |",
    };

    m2_str = {
        'mainln':"|      MP2 |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |",
        'easdis':"|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |",
        'easndm':"|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |",
        'easchd':"|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |",
    };

    def __init__(self, ofile):
        try:
            self.fp = open(ofile, "wb+")
        except IOError, e:
            print "*** file open error:", e
            sys.exit(3)

    def __del__(self):
        self.fp.close()

    def parse_diff(self, ifile, parse_type):

        self.c1_str['mainln'] = "|      WFI |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |\n"
        self.c1_str['easdis'] = "|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |\n"
        self.c1_str['easndm'] = "|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |\n"
        self.c1_str['easchd'] = "|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |\n"

        self.c2_str['mainln'] = "|      C2  |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |\n"
        self.c2_str['easdis'] = "|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |\n"
        self.c2_str['easndm'] = "|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |\n"
        self.c2_str['easchd'] = "|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |\n"

        self.m2_str['mainln'] = "|      M2  |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |\n"
        self.m2_str['easdis'] = "|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |\n"
        self.m2_str['easndm'] = "|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |\n"
        self.m2_str['easchd'] = "|          |     n.a. |     n.a. |     n.a. |     n.a. |  n.a. |  n.a. |  n.a. |\n"

        start = 0

        with open(ifile, "rb") as infile:
            for line in infile:
                if ("== ORIGINAL" in line):
                    log_type = 'mainln'
                elif ("== EAS DIS" in line):
                    log_type = 'easdis'
                elif ("== EAS NDM" in line):
                    log_type = 'easndm'
                elif ("== EAS SCHED" in line):
                    log_type = 'easchd'

                if ("C-state" in line):
                    title = line

                if (parse_type in line):
                    indicator = line
                    separator = next(infile)
                    start = 1

                while start == 1:
                    str = next(infile)

                    if (separator in str):
                        start = 0

                    if ("WFI" in str):
                        c1_line1 = str
                        c1_line2 = next(infile)

                        if log_type == 'mainln':
                            self.c1_str[log_type] = c1_line1
                        else:
                            self.c1_str[log_type] = c1_line2

                    if ("cpu-sleep" in str):
                        #c2_line1 = str
                        c2_line1 = re.sub(r" cpu-sleep ", "       C2 ", str)
                        c2_line2 = next(infile)

                        if log_type == 'mainln':
                            self.c2_str[log_type] = c2_line1
                        else:
                            self.c2_str[log_type] = c2_line2

                    if ("cluster-sleep" in str):
                        m2_line1 = re.sub(r" cluster-sleep ", "       M2 ", str)
                        m2_line2 = next(infile)

                        if log_type == 'mainln':
                            self.m2_str[log_type] = m2_line1
                        else:
                            self.m2_str[log_type] = m2_line2

        self.fp.write(separator)
        self.fp.write(title)
        self.fp.write(separator)
        self.fp.write(indicator)
        self.fp.write(separator)

        self.fp.write(self.c1_str['mainln'])
        self.fp.write(self.c1_str['easdis'])
        self.fp.write(self.c1_str['easndm'])
        self.fp.write(self.c1_str['easchd'])

        self.fp.write(self.c2_str['mainln'])
        self.fp.write(self.c2_str['easdis'])
        self.fp.write(self.c2_str['easndm'])
        self.fp.write(self.c2_str['easchd'])

        self.fp.write(self.m2_str['mainln'])
        self.fp.write(self.m2_str['easdis'])
        self.fp.write(self.m2_str['easndm'])
        self.fp.write(self.m2_str['easchd'])

        self.fp.write(separator)
        self.fp.write('\n')

        self.fp.write("C-state DC      Mainline (ndm) noEAS (ndm)    EAS (ndm)      EAS (sched)\n")
        self.fp.write('{0: <16}'.format(parse_type + ": WFI"))
        mainln_array = self.c1_str['mainln'].split("|")
        self.fp.write('{0: <15}'.format(mainln_array[5].lstrip()))
        easdis_array = self.c1_str['easdis'].split("|")
        self.fp.write('{0: <15}'.format(easdis_array[5].lstrip()))
        easndm_array = self.c1_str['easndm'].split("|")
        self.fp.write('{0: <15}'.format(easndm_array[5].lstrip()))
        easchd_array = self.c1_str['easchd'].split("|")
        self.fp.write(easchd_array[5].strip())
        self.fp.write('\n')

        self.fp.write('{0: <16}'.format(parse_type + ": C2"))
        mainln_array = self.c2_str['mainln'].split("|")
        self.fp.write('{0: <15}'.format(mainln_array[5].lstrip()))
        easdis_array = self.c2_str['easdis'].split("|")
        self.fp.write('{0: <15}'.format(easdis_array[5].lstrip()))
        easndm_array = self.c2_str['easndm'].split("|")
        self.fp.write('{0: <15}'.format(easndm_array[5].lstrip()))
        easchd_array = self.c2_str['easchd'].split("|")
        self.fp.write(easchd_array[5].strip())
        self.fp.write('\n')

        self.fp.write('{0: <16}'.format(parse_type + ": M2"))
        mainln_array = self.m2_str['mainln'].split("|")
        self.fp.write('{0: <15}'.format(mainln_array[5].lstrip()))
        easdis_array = self.m2_str['easdis'].split("|")
        self.fp.write('{0: <15}'.format(easdis_array[5].lstrip()))
        easndm_array = self.m2_str['easndm'].split("|")
        self.fp.write('{0: <15}'.format(easndm_array[5].lstrip()))
        easchd_array = self.m2_str['easchd'].split("|")
        self.fp.write(easchd_array[5].strip())
        self.fp.write('\n\n')

    def parse(self, ifile):
        self.parse_diff(ifile, "clusterA")
        self.parse_diff(ifile, "clusterB")
        self.parse_diff(ifile, "cpu0")
        self.parse_diff(ifile, "cpu1")
        self.parse_diff(ifile, "cpu2")
        self.parse_diff(ifile, "cpu3")
        self.parse_diff(ifile, "cpu4")
        self.parse_diff(ifile, "cpu5")
        self.parse_diff(ifile, "cpu6")
        self.parse_diff(ifile, "cpu7")

def main(argv):
    try:
        opts, args = getopt.getopt(argv, "h:", ["ifile=", "ofile="])
    except getopt.GetoptError:
        print 'calc_idle_diff.py -o <result.txt> -i <input.txt>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'calc_idle_diff.py -o <result.txt> -i <input.txt>'
            sys.exit(1)
        elif opt in ("--ifile"):
            ifile = arg
        elif opt in ("--ofile"):
            ofile = arg

    print "Input file:", ifile
    print "Output file:", ofile

    if not os.path.isfile(ifile):
        print "Error: file don't exists:", ifile
        sys.exit(1)

    calc = calc_idle_diff(ofile)
    calc.parse(ifile)

if __name__ == "__main__":
    main(sys.argv[1:])
