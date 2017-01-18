#!/usr/bin/env python

import os
import os.path
import sys, getopt
import binascii
import struct
import string
import re
from collections import defaultdict

big_tasks = [
    'AudioIn_16', 'Binder_1', 'Binder_2', 'Binder_3', 'Binder_4',
    'C3Dev-0-ReqQueu', 'CDU-0-FrameProc', 'Camera3Metadata',
    'FaceDetection', 'Fill Buffer Tas', 'ImageCallbackTh',
    'MPEG4Writer', 'RenderThread', 'SceneDetection', 'SensorService',
    'ThumbnailBase', 'chargelogcat', 'codec_looper',
    'ev#2', 'gle.aac.encoder', 'glgps47531', 'isp#0',
    'ispack', 'isplogcat', 'ispout#1#', 'ispout#2#',
    'ispout#3#', 'ispout#4#',
    'ispout#5#', 'ispout#6^',
    'kworker/u16:0',
    'kworker/u16:1',
    'kworker/u16:2',
    'kworker/u16:3',
    'kworker/u16:4',
    'kworker/u16:7',
    'kworker/u16:8',
    'kworker/0:1',
    'logcat',
    'logd.reader.per',
    'logd.writer',
    'm.huawei.camera',
    'mali-renderer',
    'mmcqd/0',
    'pl#2',
    'recorder_looper',
    's#0@pl#2',
    'surfaceflinger']

class analyse_wake_tasks(object):

    taskname = ''
    filename = ''
    waker = ''
    result = {}

    def __init__(self, ifile):

        try:
            self.fp = open(ifile, "aw")
        except IOError, e:
            print "*** file open error:", e
            sys.exit(3)

        self.filename = ifile;

    def __del__(self):
        self.fp.close()

    def parse(self, taskname):

        self.taskname = taskname
        self.waker = ''
        self.result.clear()

        with open(self.filename, "rb") as infile:
            lines = infile.readlines()

        for line in lines:

            search_stat_sleep = "sched_stat_sleep: comm=" + self.taskname
            search_stat_runtime = "sched_stat_runtime: comm=" + self.taskname

            if (search_stat_sleep in line):

                #print line

                special_fields_regexp = r"^\s*(?P<comm>.*)-(?P<pid>\d+)(?:\s+\(.*\))"\
                                        r"?\s+\[(?P<cpu>\d+)\](?:\s+....)?\s+"\
                                        r"(?P<timestamp>[0-9]+\.[0-9]+):"\
                                        r"?\s+sched_stat_sleep\: comm=(?P<wakee>.*)"\
                                        r"?\s+pid=(?P<wakee_pid>\d+)"\
                                        r"?\s+delay=(?P<delay>\d+)"

                special_fields_regexp = re.compile(special_fields_regexp)

                special_fields_match = special_fields_regexp.match(line)

                #print special_fields_match.group('comm')
                #print special_fields_match.group('pid');
                #print special_fields_match.group('cpu');
                #print special_fields_match.group('timestamp');
                #print special_fields_match.group('wakee');
                #print special_fields_match.group('wakee_pid');
                #print special_fields_match.group('delay');

                self.waker = special_fields_match.group('comm') + '-' + special_fields_match.group('pid')
                #print self.waker

                if self.waker not in self.result:
                    self.result[self.waker] = {
                            'sleep': 0,
                            'count': 0,
                            'avg_sleep': 0,
                            'max_sleep': 0,
                            'min_sleep': 1000000000,
                            'runtime': 0,
                            'avg_runtime': 0,
                    }

                delay = int(special_fields_match.group('delay')) / 1000

                self.result[self.waker]['sleep'] += delay
                self.result[self.waker]['count'] += 1

                if (self.result[self.waker]['max_sleep'] < delay):
                    self.result[self.waker]['max_sleep'] = delay

                if (self.result[self.waker]['min_sleep'] > delay):
                    self.result[self.waker]['min_sleep'] = delay

                #print self.result[self.waker]

            elif (search_stat_runtime in line):

                #print line

                if self.waker == '':
                    continue

                special_fields_regexp = r"^\s*(?P<comm>.*)-(?P<pid>\d+)(?:\s+\(.*\))"\
                                        r"?\s+\[(?P<cpu>\d+)\](?:\s+....)?\s+"\
                                        r"(?P<timestamp>[0-9]+\.[0-9]+):"\
                                        r"?\s+sched_stat_runtime\: comm=(?P<wakee>.*)"\
                                        r"?\s+pid=(?P<wakee_pid>\d+)"\
                                        r"?\s+runtime=(?P<runtime>\d+)"

                special_fields_regexp = re.compile(special_fields_regexp)

                special_fields_match = special_fields_regexp.match(line)

                #print special_fields_match.group('comm') + '-' + special_fields_match.group('pid');
                #print special_fields_match.group('cpu');
                #print special_fields_match.group('timestamp');
                #print special_fields_match.group('wakee');
                #print special_fields_match.group('wakee_pid');
                #print special_fields_match.group('runtime');

                self.result[self.waker]['runtime'] += int(special_fields_match.group('runtime'))

                #print self.result[self.waker]

    def output_result(self):

        print ''
        print '---------------------------------'
        print 'task: ' + self.taskname

        for key, value in self.result.iteritems():
            value['avg_runtime'] = value['runtime'] / value['count']
            value['avg_sleep'] = value['sleep'] / value['count']
            print 'Waker:' + key
            print '  count:' + str(value['count'])
            print '  average sleep time (us):' + str(value['avg_sleep'])
            print '  maximum sleep time (us):' + str(value['max_sleep'])
            print '  mininum sleep time (us):' + str(value['min_sleep'])
            print '  total sleep time (us):' + str(value['sleep'])

            print '  average runtime (us):' + str(value['avg_runtime'])
            print '  total runtime (us):' + str(value['runtime'])

        print '---------------------------------'


def main(argv):
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'f:h', ['file=', 'help'])
    except getopt.GetoptError:
        print 'analyse_wake_task.py -f <ftrace.log>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'analyse_wake_task.py -f <ftrace.log> -t <task_name>'
            sys.exit(1)
        elif opt == '-f':
            ifile = arg

    if not os.path.isfile(ifile):
        print "Error: file don't exists:", ifile
        sys.exit(1)

    wake_tasks = analyse_wake_tasks(ifile)
    for task in big_tasks:
        #wake_tasks.result.clear()
        wake_tasks.parse(task)
        wake_tasks.output_result()

if __name__ == "__main__":
    main(sys.argv[1:])
