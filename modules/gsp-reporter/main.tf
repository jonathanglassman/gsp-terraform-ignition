module "reporter-system" {
  source = "../flux-release"

  enabled               = 1
  namespace             = "gsp-reporter"
  chart_git             = "https://github.com/alphagov/gsp-canary-chart.git"
  chart_ref             = "master"
  chart_path            = "charts/gsp-reporter"
  cluster_name          = "${var.cluster_name}"
  cluster_domain        = "${var.cluster_name}.${var.dns_zone}"
  addons_dir            = "${var.addons_dir}"
}
