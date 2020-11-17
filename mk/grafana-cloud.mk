.PHONY: lke-promtail
lke-promtail: | lke-ctx $(CURL) $(LPASS)
	curl -fsS https://raw.githubusercontent.com/grafana/loki/master/tools/promtail.sh \
	| sh -s 8521 "$$($(LPASS) show --notes 1212835959730479797)" logs-prod-us-central1.grafana.net default | kubectl apply --namespace=default -f  -

lke-provision:: lke-promtail
