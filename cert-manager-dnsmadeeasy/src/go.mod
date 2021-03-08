module github.com/jetstack/cert-manager-webhook-example

go 1.12

require (
	github.com/jetstack/cert-manager v0.13.0
	github.com/mhenderson-so/godnsmadeeasy v0.0.0-20161117210134-6c4a59b67887
	k8s.io/apiextensions-apiserver v0.17.0
	k8s.io/apimachinery v0.17.0
	k8s.io/client-go v0.17.0
)

//replace github.com/prometheus/client_golang => github.com/prometheus/client_golang v0.9.4
