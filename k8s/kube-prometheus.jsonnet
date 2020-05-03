local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
local pvc = k.core.v1.persistentVolumeClaim;
local statefulSet = k.apps.v1.statefulSet;
local container = statefulSet.mixin.spec.template.spec.containersType;
local resourceRequirements = container.mixin.resourcesType;
local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet')
  // Uncomment the following imports to enable its patches
  // + (import 'kube-prometheus/kube-prometheus-anti-affinity.libsonnet')
  // + (import 'kube-prometheus/kube-prometheus-managed-cluster.libsonnet')
  // + (import 'kube-prometheus/kube-prometheus-node-ports.libsonnet')
  // + (import 'kube-prometheus/kube-prometheus-static-etcd.libsonnet')
  // + (import 'kube-prometheus/kube-prometheus-thanos-sidecar.libsonnet')
  + {
    _config+:: {
      namespace: std.extVar('NAMESPACE'),
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
              client_id: std.extVar('GITHUB_OAUTH_APP_CLIENT_ID'),
              client_secret: std.extVar('GITHUB_OAUTH_APP_CLIENT_SECRET'),
              team_ids: std.extVar('GITHUB_TEAM_ID'),
              allowed_organizations: std.extVar('GITHUB_ORG'),
            },
            security: {
              disable_initial_admin_creation: true,
            },
            server: {
              enable_gzip: true,
              root_url: std.extVar('ROOT_URL'),
            },
            users: {
              auto_assign_org_role: 'Admin',
            },
          },
        },
      },
      prometheus+:: {
        replicas: 1,
      },
    },

  grafana+:: {
    deployment+: {
      spec+: {
        template+: {
          spec+: {
            volumes:
              std.map(
                function(v)
                  if v.name == 'grafana-storage' then {
                    'name': 'grafana-storage',
                    'persistentVolumeClaim': {
                      'claimName': 'grafana-storage',
                    },
                  }
                  else v,
                super.volumes
              ),
          },
        },
      },
    },
    storage:
      pvc.new()
      + pvc.mixin.metadata.withNamespace($._config.namespace)
      + pvc.mixin.metadata.withName("grafana-storage")
      + pvc.mixin.spec.withAccessModes('ReadWriteOnce')
      + pvc.mixin.spec.resources.withRequests({ storage: '10Gi' })
      + pvc.mixin.spec.withStorageClassName('linode-block-storage-retain'),
    },

    // https://github.com/coreos/kube-prometheus/blob/master/examples/prometheus-pvc.jsonnet
    prometheus+:: {
      prometheus+: {
        // https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#prometheusspec
        spec+: {
           // If a value isn't specified for 'retention', then by default the '--storage.tsdb.retention=24h' arg will be passed to prometheus by prometheus-operator.
          retention: '30d',
          retentionSize: '8GB',
          resources:
            resourceRequirements.new()
            + resourceRequirements.withRequests({ cpu: '500m', memory: '500Mi' })
            + resourceRequirements.withLimits({ cpu: '1', memory: '1000Mi' }),
          storage: {  // https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#storagespec
            volumeClaimTemplate:
              pvc.new()  // http://g.bryan.dev.hepti.center/core/v1/persistentVolumeClaim/#core.v1.persistentVolumeClaim.new
              + pvc.mixin.spec.withAccessModes('ReadWriteOnce')
              + pvc.mixin.spec.resources.withRequests({ storage: '10Gi' })
              // A StorageClass of the following name (which can be seen via `kubectl get storageclass` from a node in the given K8s cluster) must exist prior to kube-prometheus being deployed.
              + pvc.mixin.spec.withStorageClassName('linode-block-storage-retain'),
          },
        },
      },
    },

// https://github.com/coreos/kube-prometheus/blob/master/examples/prometheus-pvc.jsonnet
// https://github.com/coreos/kube-prometheus/issues/98#issuecomment-491782065

  };

{ ['setup/0namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) }
+ {
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor'), std.objectFields(kp.prometheusOperator))
}
// serviceMonitor is separated so that it can be created after the CRDs are ready
+ { 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor }
+ { ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) }
+ { ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) }
+ { ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) }
+ { ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) }
+ { ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) }
+ { ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) }
