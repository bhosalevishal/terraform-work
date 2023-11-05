variable location {
  type = string
  description = "Name of the region" 
  default     = "Japan East"
}

variable hub_cluster_rg_name {
   type = string
   description = "Name of the resource group"
}

variable hub_cluster_name {
  type = string
  description = "Name of the hub cluster" 
  default     = "hub-cluster-001"
}

variable hub_cluster_vm_size {
  type = string
  description = "VM Size of the hub cluster" 
  default     = "Standard_D2_v2"
}