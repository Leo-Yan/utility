import subprocess
import re
from collections import defaultdict

sites = [
        'j0.0bad.com',
        'j1.0bad.com',
        'j2.0bad.com',
        'j3.0bad.com',
        'j4.0bad.com',
        'j5.0bad.com',
        'j6.0bad.com',
        'hk.0bad.com',
        'sg01.0bad.com',
        'us0.0bad.com',
        'us1.0bad.com',
        'us2.0bad.com',
        'us3.0bad.com',
        'us4.0bad.com',
        'us5.0bad.com',
        'us6.0bad.com',
        'us7.0bad.com',
        'us8.0bad.com',
        'us9.0bad.com',
        'uk.0bad.com',
        'in.0bad.com'
]

def test_site_speed(vpn_site):
    p = subprocess.Popen(["ping", "-c 10", vpn_site], stdout = subprocess.PIPE)
    result = p.communicate()[0]

    print result

    log_regexp = r"(?P<transmitted>\d+) packets transmitted, (?P<received>\d+) received, (?P<percent>\d+)% packet loss, time (?P<time>\d+)ms"
    log_regexp = re.compile(log_regexp, re.MULTILINE)
    log_match = log_regexp.search(result)
    #print log_match.group('transmitted')
    #print log_match.group('received')
    #print log_match.group('percent')
    #print log_match.group('time')

    percent = log_match.group('percent')

    if percent == '100':
        return 0

    log_regexp = r"rtt min/avg/max/mdev = (?P<min>\d+.\d+)/(?P<avg>\d+.\d+)/(?P<max>\d+.\d+)/(?P<mdev>\d+.\d+) ms"
    log_regexp = re.compile(log_regexp, re.MULTILINE)
    log_match = log_regexp.search(result)
    #print log_match.group('min')
    #print log_match.group('avg')
    #print log_match.group('max')
    #print log_match.group('mdev')

    avg = log_match.group('avg')

    speed = (10000 / float(avg)) * (100 - float(percent)) / 100
    return speed

def main():

    collectValue = defaultdict(list)

    for site in sites:
        speed = test_site_speed(site)
        collectValue[site].append(speed)

    collectValue = sorted(collectValue.items(), key=lambda(k,v): v)

    for condition, values in collectValue:
        print condition
        print values

if __name__ == "__main__":
    main()
