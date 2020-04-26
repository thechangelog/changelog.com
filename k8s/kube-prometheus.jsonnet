local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet') +
  // Uncomment the following imports to enable its patches
  // (import 'kube-prometheus/kube-prometheus-anti-affinity.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-managed-cluster.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-node-ports.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-static-etcd.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-thanos-sidecar.libsonnet') +
  {
    _config+:: {
      namespace: 'monitoring',
      grafana+:: {
        config: {
          // https://grafana.com/docs/grafana/v6.6/installation/configuration/ - currently installed
          sections: {
            auth: {
              oauth_auto_login: true,
              disable_login_form: true,
            },
            'auth.anonymous': { enabled: false },
            'auth.basic': { enabled: true },
            // https://grafana.com/docs/grafana/v6.6/auth/github/
            'auth.github': {
              enabled: true,
              allow_sign_up: true,
              client_id: std.extVar('METRICS_GITHUB_OAUTH_APP_CLIENT_ID'),
              client_secret: std.extVar('METRICS_GITHUB_OAUTH_APP_CLIENT_SECRET'),
              // http://fabian-kostadinov.github.io/2015/01/16/how-to-find-a-github-team-id/
              // https://github.com/settings/tokens
              // curl -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" https://api.github.com/orgs/thechangelog/teams | view -c "set ft=json" -
              team_ids: 3796119,
              allowed_organizations: 'thechangelog',
            },
            security: {
              disable_initial_admin_creation: true,
            },
            server: {
              enable_gzip: true,
            },
            users: {
              auto_assign_org_role: 'Admin',
            },
          },
        },
      },
    },

    prometheus+:: {
      replicas: 1,
    },
  };

{ ['setup/0namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor'), std.objectFields(kp.prometheusOperator))
} +
// serviceMonitor is separated so that it can be created after the CRDs are ready
{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) }
