resource "juju_model" "sdcore" {
  name = var.model_name
}

resource "juju_application" "pcf" {
  name = "pcf"
  model = var.model_name

  charm {
    name = "sdcore-pcf-k8s"
    channel = var.channel
  }

  units = 1
  trust = true
}

module "mongodb-k8s" {
  source     = "gatici/mongodb-k8s/juju"
  version    = "1.0.2"
  model_name = var.model_name
}

module "self-signed-certificates" {
  source     = "gatici/self-signed-certificates/juju"
  version    = "1.0.3"
  model_name = var.model_name
}

module "sdcore-nrf-k8s" {
  source  = "gatici/sdcore-nrf-k8s/juju"
  version = "1.0.0"
  model_name = var.model_name
  certs_application_name = var.certs_application_name
  db_application_name = var.db_application_name
  channel = var.channel
}

resource "juju_integration" "pcf-db" {
  model = var.model_name

  application {
    name     = juju_application.pcf.name
    endpoint = "database"
  }

  application {
    name     = var.db_application_name
    endpoint = "database"
  }
}

resource "juju_integration" "pcf-certs" {
  model = var.model_name

  application {
    name     = juju_application.pcf.name
    endpoint = "certificates"
  }

  application {
    name     = var.certs_application_name
    endpoint = "certificates"
  }
}

resource "juju_integration" "pcf-nrf" {
  model = var.model_name

  application {
    name     = juju_application.pcf.name
    endpoint = "fiveg-nrf"
  }

  application {
    name     = var.nrf_application_name
    endpoint = "fiveg-nrf"
  }
}

