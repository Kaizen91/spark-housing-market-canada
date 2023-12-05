terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_project_service" "iam_api" {
  project = var.project
  service = "iam.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "dataproc_api" {
  project = var.project
  service = "dataproc.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "compute_api" {
  project = var.project
  service = "compute.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_project_service" "cloudresourcemanager" {
  project = var.project
  service = "cloudresourcemanager.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}

resource "google_storage_bucket" "spark_housing" {
  name          = "spark_housing"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_object" "source_data" {
  name         = "LZ/source_housing_data.csv"
  content_type = "csv"
  source       = "HouseListings-Top45Cities-10292023-kaggle.csv"
  bucket       = google_storage_bucket.spark_housing.id
}

resource "google_storage_bucket_object" "transformation_script" {
  name   = "scripts/transform.py"
  source = "transform.py"
  bucket = google_storage_bucket.spark_housing.id
}

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_dataproc_cluster" "mycluster" {
  name                          = "mycluster"
  region                        = var.region
  graceful_decommission_timeout = "120s"

  cluster_config {
    master_config {
      num_instances = 1
      machine_type  = "e2-standard-2"
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 30
      }
    }

    worker_config {
      num_instances = 2
      machine_type  = "e2-standard-2"
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 30
      }
    }

    # Override or set some custom properties
    software_config {
      image_version = "2.1-debian11"
    }
  }
}

resource "google_bigquery_dataset" "housing_datamart" {
  dataset_id  = "housing_datamart"
  description = "This dataset contains canadian housing data"
}

# Submit an example pyspark job to a dataproc cluster
resource "google_dataproc_job" "pyspark" {
  region       = google_dataproc_cluster.mycluster.region
  force_delete = true
  placement {
    cluster_name = google_dataproc_cluster.mycluster.name
  }

  pyspark_config {
    main_python_file_uri = format("gs://%s/%s", google_storage_bucket.spark_housing.name, google_storage_bucket_object.transformation_script.name)
    properties = {
      "spark.logConf" = "true"
    }
  }
}
