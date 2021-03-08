package main

import (
	"encoding/json"
	"fmt"
	"os"
  "strings"

	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
  metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
  extAPI "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1beta1"

	webhookapi "github.com/jetstack/cert-manager/pkg/acme/webhook/apis/acme/v1alpha1"
	webhookcmd "github.com/jetstack/cert-manager/pkg/acme/webhook/cmd"
  certmgrv1 "github.com/jetstack/cert-manager/pkg/apis/meta/v1"
  "github.com/jetstack/cert-manager/pkg/issuer/acme/dns/util"

  "github.com/mhenderson-so/godnsmadeeasy/src/GoDNSMadeEasy"
)

const (
	defaultTTL = 600
)

var GroupName = os.Getenv("GROUP_NAME")

func main() {
	if GroupName == "" {
		panic("GROUP_NAME must be specified")
	}

	// This will register our custom DNS provider with the webhook serving
	// library, making it available as an API under the provided GroupName.
	// You can register multiple DNS provider implementations with a single
	// webhook, where the Name() method will be used to disambiguate between
	// the different implementations.
	webhookcmd.RunWebhookServer(GroupName,
		&DNSMadeEasyProviderSolver{},
	)
}

// customDNSProviderSolver implements the provider-specific logic needed to
// 'present' an ACME challenge TXT record for your own DNS provider.
// To do so, it must implement the `github.com/jetstack/cert-manager/pkg/acme/webhook.Solver`
// interface.
type DNSMadeEasyProviderSolver struct {
	// If a Kubernetes 'clientset' is needed, you must:
	// 1. uncomment the additional `client` field in this structure below
	// 2. uncomment the "k8s.io/client-go/kubernetes" import at the top of the file
	// 3. uncomment the relevant code in the Initialize method below
	// 4. ensure your webhook's service account has the required RBAC role
	//    assigned to it for interacting with the Kubernetes APIs you need.
	client *kubernetes.Clientset
}

// customDNSProviderConfig is a structure that is used to decode into when
// solving a DNS01 challenge.
// This information is provided by cert-manager, and may be a reference to
// additional configuration that's needed to solve the challenge for this
// particular certificate or issuer.
// This typically includes references to Secret resources containing DNS
// provider credentials, in cases where a 'multi-tenant' DNS solver is being
// created.
// If you do *not* require per-issuer or per-certificate configuration to be
// provided to your webhook, you can skip decoding altogether in favour of
// using CLI flags or similar to provide configuration.
// You should not include sensitive information here. If credentials need to
// be used by your provider here, you should reference a Kubernetes Secret
// resource and fetch these credentials using a Kubernetes clientset.
type DNSMadeEasyProviderConfig struct {
	// Change the two fields below according to the format of the configuration
	// to be decoded.
	// These fields will be set by users in the
	// `issuer.spec.acme.dns01.providers.webhook.config` field.

	APIKeyRef    certmgrv1.SecretKeySelector `json:"apiKeyRef"`
	APISecretRef certmgrv1.SecretKeySelector `json:"apiSecretRef"`
  TTL          *int                        `json:"ttl"`
  Sandbox      bool                        `json:"sandbox"`
  //Secrets directly in config - not recomended -> use secrets!
  APIKey       string `json:"apiKey"`
  APISecret    string `json:"apiSecret"`
}

// Name is used as the name for this DNS solver when referencing it on the ACME
// Issuer resource.
// This should be unique **within the group name**, i.e. you can have two
// solvers configured with the same Name() **so long as they do not co-exist
// within a single webhook deployment**.
// For example, `cloudflare` may be used as the name of a solver.
func (c *DNSMadeEasyProviderSolver) Name() string {
	return "dnsmadeeasy"
}

// Present is responsible for actually presenting the DNS record with the
// DNS provider.
// This method should tolerate being called multiple times with the same value.
// cert-manager itself will later perform a self check to ensure that the
// solver has correctly configured the DNS provider.
func (c *DNSMadeEasyProviderSolver) Present(ch *webhookapi.ChallengeRequest) error {

  fmt.Printf("\n>>>Present: fqdn:[%s] zone:[%s]\n", ch.ResolvedFQDN, ch.ResolvedZone)

  cfg, err := loadConfig(ch.Config)
	if err != nil {
    printError(err)
		return err
	}
  //fmt.Printf("Decoded configuration %v\n", cfg)

	client, err := c.getDnsClient(ch, cfg)
  if err != nil {
		printError(err)
    return err
	}

  domainID, err := getDomainID(client, ch.ResolvedZone)
	if err != nil {
		printError(err)
    return err
	}

  exitingRecord := findTxtRecord(client, domainID, ch.ResolvedZone, ch.ResolvedFQDN)

  if (exitingRecord == nil) {
    record := newTxtRecord(ch.ResolvedZone, ch.ResolvedFQDN, ch.Key, *cfg.TTL)
    _, err = client.AddRecord(domainID, record)
  	if err != nil {
  		printError(err)
      return fmt.Errorf("DNSMadeEasy API call failed: %v", err)
  	}
  } else {
    exitingRecord.Value = ch.Key
    exitingRecord.TTL = *cfg.TTL

    err = client.UpdateRecord(domainID, exitingRecord)
  	if err != nil {
      printError(err)
  		return fmt.Errorf("DNSMadeEasy API call failed: %v", err)
  	}
  }

	fmt.Printf("\n<<<Present: fqdn:[%s] zone:[%s]\n", ch.ResolvedFQDN, ch.ResolvedZone)
  return nil
}

// CleanUp should delete the relevant TXT record from the DNS provider console.
// If multiple TXT records exist with the same record name (e.g.
// _acme-challenge.example.com) then **only** the record with the same `key`
// value provided on the ChallengeRequest should be cleaned up.
// This is in order to facilitate multiple DNS validations for the same domain
// concurrently.
func (c *DNSMadeEasyProviderSolver) CleanUp(ch *webhookapi.ChallengeRequest) error {

  fmt.Printf("\n>>>CleanUp: fqdn:[%s] zone:[%s]\n", ch.ResolvedFQDN, ch.ResolvedZone)
  cfg, err := loadConfig(ch.Config)
	if err != nil {
		printError(err)
    return err
	}

  client, err := c.getDnsClient(ch, cfg)
  if err != nil {
		printError(err)
    return err
	}

  fmt.Printf("fqdn:[%s] zone:[%s]\n", ch.ResolvedFQDN, ch.ResolvedZone)
  domainID, err := getDomainID(client, ch.ResolvedZone)
	if err != nil {
		printError(err)
    return err
	}

  exitingRecord := findTxtRecord(client, domainID, ch.ResolvedZone, ch.ResolvedFQDN)

  if (exitingRecord != nil) {
    err = client.DeleteRecord(domainID, exitingRecord.ID)
    if err != nil {
  		printError(err)
      return fmt.Errorf("DNSMadeEasy API call failed: %v", err)
  	}
  }
  fmt.Printf("\n<<<CleanUp: fqdn:[%s] zone:[%s]\n", ch.ResolvedFQDN, ch.ResolvedZone)
  return nil
}

// Initialize will be called when the webhook first starts.
// This method can be used to instantiate the webhook, i.e. initialising
// connections or warming up caches.
// Typically, the kubeClientConfig parameter is used to build a Kubernetes
// client that can be used to fetch resources from the Kubernetes API, e.g.
// Secret resources containing credentials used to authenticate with DNS
// provider accounts.
// The stopCh can be used to handle early termination of the webhook, in cases
// where a SIGTERM or similar signal is sent to the webhook process.
func (c *DNSMadeEasyProviderSolver) Initialize(kubeClientConfig *rest.Config, stopCh <-chan struct{}) error {

	cl, err := kubernetes.NewForConfig(kubeClientConfig)
	if err != nil {
    printError(err)
		return err
	}

	c.client = cl

	return nil
}

// loadConfig is a small helper function that decodes JSON configuration into
// the typed config struct.
func loadConfig(cfgJSON *extAPI.JSON) (DNSMadeEasyProviderConfig, error) {
  ttl := defaultTTL
	cfg := DNSMadeEasyProviderConfig{TTL: &ttl}
	// handle the 'base case' where no configuration has been provided
	if cfgJSON == nil {
		return cfg, nil
	}
	if err := json.Unmarshal(cfgJSON.Raw, &cfg); err != nil {
		return cfg, fmt.Errorf("error decoding solver config: %v", err)
	}

	return cfg, nil
}

func (c *DNSMadeEasyProviderSolver) getDnsClient(ch *webhookapi.ChallengeRequest, cfg DNSMadeEasyProviderConfig) (*GoDNSMadeEasy.GoDMEConfig, error) {

  //API Key
  apiKey := cfg.APIKey
  if apiKey == "" {
    ref := cfg.APIKeyRef
  	if ref.Key == "" || ref.Name == "" {
  		return nil, fmt.Errorf("no apiKeyRef for %q in secret '%s/%s'", ref.Name, ref.Key, ch.ResourceNamespace)
  	}
  	secret, err := c.client.CoreV1().Secrets(ch.ResourceNamespace).Get(ref.Name, metav1.GetOptions{})
  	if err != nil {
  		return nil, err
  	}
    apiKeyRef, ok := secret.Data[ref.Key]
  	if !ok {
  		return nil, fmt.Errorf("no apiKeyRef for %q in secret '%s/%s'", ref.Name, ref.Key, ch.ResourceNamespace)
  	}
  	apiKey = fmt.Sprintf("%s", apiKeyRef)
  }

  //API Secret
  apiSecret := cfg.APISecret
  if apiSecret == "" {
    ref := cfg.APISecretRef
  	if ref.Key == "" || ref.Name == "" {
  		return nil, fmt.Errorf("no apiSecretRef for %q in secret '%s/%s'", ref.Name, ref.Key, ch.ResourceNamespace)
  	}
    secret, err := c.client.CoreV1().Secrets(ch.ResourceNamespace).Get(ref.Name, metav1.GetOptions{})
  	if err != nil {
  		return nil, err
  	}
    apiSecretRef, ok := secret.Data[ref.Key]
  	if !ok {
  		return nil, fmt.Errorf("no accessKeySecret for %q in secret '%s/%s'", ref.Name, ref.Key, ch.ResourceNamespace)
  	}
  	apiSecret = fmt.Sprintf("%s", apiSecretRef)
  }

  APIUrl := GoDNSMadeEasy.LIVEAPI
  if (cfg.Sandbox) {
    APIUrl = GoDNSMadeEasy.SANDBOXAPI
  }

  //Init client
  client, err := GoDNSMadeEasy.NewGoDNSMadeEasy(&GoDNSMadeEasy.GoDMEConfig{
      APIKey:               apiKey,
      SecretKey:            apiSecret,
      APIUrl:               APIUrl,
      DisableSSLValidation: false,
  })
  if err != nil {
      return nil, err
  }

	return client, nil
}

func getDomainID(client *GoDNSMadeEasy.GoDMEConfig, zone string) (int, error) {
	domains, err := client.Domains()
	if err != nil {
		return -1, fmt.Errorf("dnspod API call failed: %v", err)
	}

	authZone, err := util.FindZoneByFqdn(zone, util.RecursiveNameservers)
	if err != nil {
		return -1, err
	}

	var hostedDomain GoDNSMadeEasy.Domain
	for _, domain := range domains {
    if domain.Name == util.UnFqdn(authZone) {
			hostedDomain = domain
			break
		}
	}

	if hostedDomain.ID == 0 {
		return -1, fmt.Errorf("Zone %s not found in DNSMadeEasy for zone %s", authZone, zone)
	}

	return hostedDomain.ID, nil
}

func newTxtRecord(zone, fqdn, value string, ttl int) *GoDNSMadeEasy.Record {
	name := extractRecordName(fqdn, zone)

	return &GoDNSMadeEasy.Record{
		Type:  "TXT",
		Name:  name,
		Value: value,
		GtdLocation: "DEFAULT",
		TTL:   ttl,
	}
}

func findTxtRecord(client *GoDNSMadeEasy.GoDMEConfig, domainID int, zone, fqdn string) *GoDNSMadeEasy.Record {

  name := extractRecordName(fqdn, zone)

  records, err := client.Records(domainID)
  if (err != nil) {
    return nil
  }

  for _, existingRecord := range records {
    if existingRecord.Name == name {
      fmt.Printf("DNS record found: %v\n", existingRecord)
			return &existingRecord
		}
	}

	return nil
}


func extractRecordName(fqdn, zone string) string {
	if idx := strings.Index(fqdn, "."+zone); idx != -1 {
		return fqdn[:idx]
	}

	return util.UnFqdn(fqdn)
}

func printError(err error) {
  fmt.Printf("\n\nERROR\n %v \n\n", err)
}
