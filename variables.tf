variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
  default     = "playground-s-11-838df330"

}

variable "region" {
  description = "The region in which to provision resources."
  type        = string
  default     = "us-central1"
}


variable "zone" {
  description = "The zone in which to provision resources."
  type        = string
  default     = "us-central1-a"
}

variable "credentials_file" {
  description = "The path to the service account key file in JSON format."
  type        = string
  default     = "keys.json"
}

variable "backend_bucket" {
  description = "The name of the GCS bucket to use for Terraform state."
  type        = string
  default     = "gke-terraform-bucket01"
}

variable "backend_prefix" {
  description = "The prefix to use for the Terraform state file in the GCS bucket."
  type        = string
  default     = "terraform/state"
}

variable "K8s_version" {
  description = "The version of the GKE master to use."
  type        = string
  default     = "1.35.5-gke.1163012"
}


variable "node_count" {
  description = "The number of nodes to create in the node pool."
  type        = number
  default     = 1
}
