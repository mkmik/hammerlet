# hammerlet

Hammerlet is a simple load test utility that exposes live metrics to prometheus.

Don't expect stellar performance (on my i7 laptop it caps 100k RPS).

I wrote it out of frustration because I didn't find a decent way
to have light-weight tools that would perform long running load test
for which I wouldn't have to wait until the end to see the results
(or use proprietary dashboards to stream that data to).

## Usage

```
$ hammerlet -r 10 -t http://localhost:8080
```
