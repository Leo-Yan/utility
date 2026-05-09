#define _GNU_SOURCE
#include <time.h>
#include <stdbool.h>
#include <signal.h>
#include <poll.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <linux/perf_event.h>

static struct signal_counts {
        int in;
	int out;
	int hup;
	int unknown;
} count;

static unsigned long sample_type = PERF_SAMPLE_IP | PERF_SAMPLE_TID |
				   PERF_SAMPLE_TIME | PERF_SAMPLE_ADDR |
				   PERF_SAMPLE_READ | PERF_SAMPLE_ID |
				   PERF_SAMPLE_CPU | PERF_SAMPLE_PERIOD |
				   PERF_SAMPLE_STREAM_ID | PERF_SAMPLE_RAW;

static void sighandler(int signum, siginfo_t *info, void *uc)
{
	switch(info->si_code) {
                case POLL_IN:  count.in++;  break;
                case POLL_OUT: count.out++; break;
                case POLL_HUP: count.hup++; break;
                default: count.unknown++; break;
        }
}

void generate_load(unsigned long long iterations) {
    unsigned long long sum = 0;
    srand(time(0));

    for (unsigned long long i = 0; i < iterations; ++i) {
        int rnd = rand();
        sum += (rnd ^ (rnd >> 3)) % 1000;
    }
    printf("Computation result: %llu\n", sum);
}

void perf_attr(struct perf_event_attr *pe,
		       unsigned long config, unsigned long period, bool freq,
		       unsigned long bits)
{
	memset(pe, 0, sizeof(struct perf_event_attr));
	pe->size = sizeof(struct perf_event_attr);

	pe->type = PERF_TYPE_HARDWARE;
	pe->config = config | 0xB00000000UL;

	pe->exclude_kernel = 0;
	pe->exclude_hv = 0;

	pe->freq = freq;
	pe->sample_period = period;

	pe->sample_type = bits;
	pe->disabled = 1;
}

int main(int argc, char **argv)
{
	int fd, rc = -1;
	int signo = SIGRTMIN + 1;
	struct sigaction sa, sa_old;
	struct perf_event_attr pe;

	/* Set up overflow handler */
	memset(&sa, 0, sizeof(struct sigaction));
	memset(&sa_old, 0, sizeof(struct sigaction));
	sa.sa_sigaction = sighandler;
	sa.sa_flags = SA_SIGINFO;
	sigemptyset(&sa.sa_mask);

	if (sigaction(signo, &sa, &sa_old) < 0)
		goto out;

	printf("Perf event open \n");

	perf_attr(&pe, PERF_COUNT_HW_CPU_CYCLES, 5000, 1, sample_type);

	fd = syscall(__NR_perf_event_open, &pe, 0, -1, -1, 0);
	if (fd < 0)
		return rc;

	printf("Fcntl\n");

	rc = fcntl(fd, F_SETSIG, signo);
	rc |= fcntl(fd, F_SETOWN, getpid());
	rc |= fcntl(fd, F_SETFL, fcntl(fd, F_GETFL) | O_ASYNC | O_NONBLOCK);
	//rc |= fcntl(fd, F_SETFL, O_RDWR | O_NONBLOCK | O_ASYNC);
	if (rc)
		goto out;

	printf("Refresh\n");

	rc = ioctl(fd, PERF_EVENT_IOC_REFRESH, 25);
	if (rc)
		goto out;

	printf("Reset\n");

	rc = ioctl(fd, PERF_EVENT_IOC_RESET, 0);
	if (rc)
		goto out;

	printf("Enable\n");

	rc = ioctl(fd, PERF_EVENT_IOC_ENABLE, 0);
	if (rc)
		goto out;

	printf("Run load ...\n");

	generate_load(100000000ULL);

	printf("Finish loadn");

	sigaction(signo, &sa_old, NULL);
	printf("count.hup: %d count.pollin: %d\n", count.hup, count.in);

	ioctl(fd, PERF_EVENT_IOC_DISABLE, 0);
	close(fd);
	return 0;
out:
	return rc;
}
