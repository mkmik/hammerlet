// hammerlet is a very simple HTTP load test utility.
package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
	"golang.org/x/time/rate"
)

var (
	target  = flag.String("t", "http://localhost:8080", "target url")
	rps     = flag.Int("r", 1, "request per second")
	timeout = flag.Duration("timeout", 60*time.Second, "timeout")

	listen = flag.String("l", ":6002", "listen for prometheus scrapes")
)

var (
	requestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of performed http requests.",
		},
		[]string{"code"},
	)

	requestsDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_requests_duration_seconds",
			Help:    "Duration of requests",
			Buckets: prometheus.ExponentialBuckets(1.0/1024, 8, 14),
		},
		[]string{"code"},
	)
)

func init() {
	prometheus.MustRegister(requestsTotal)
	prometheus.MustRegister(requestsDuration)
}

func hit(httpClient *http.Client, u string) {
	if err := hitE(httpClient, u); err != nil {
		log.Printf("error: %v", err)
	}
}

func hitE(httpClient *http.Client, u string) error {
	log.Printf("hitting")
	start := time.Now()

	resp, err := httpClient.Get(u)
	var code string
	if err != nil {
		code = "err"
	} else {
		code = fmt.Sprint(resp.StatusCode)
	}
	l := prometheus.Labels{"code": code}

	requestsTotal.With(l).Inc()
	requestsDuration.With(l).Observe(time.Since(start).Seconds())

	return err
}

func run(target string, rps int, timeout time.Duration) error {
	ctx := context.Background()
	lim := rate.NewLimiter(rate.Limit(rps), 1)

	httpClient := &http.Client{
		Timeout: timeout,
	}
	for {
		err := lim.Wait(ctx)
		if err != nil {
			return err
		}

		go hit(httpClient, target)
	}
}

func main() {
	flag.Parse()

	http.Handle("/metrics", promhttp.Handler())
	go http.ListenAndServe(*listen, nil)

	if err := run(*target, *rps, *timeout); err != nil {
		log.Fatal(err)
	}
}
