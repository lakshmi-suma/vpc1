resource "ibm_is_vpc" "vpc2" {
  name = "vpc2"
  resource_group=var.resource_group

}

resource "ibm_is_subnet" "subnet4" {
  name                     = "subnet4"
  vpc                      = ibm_is_vpc.vpc2.id
  zone                     = "us-south-1"
  total_ipv4_address_count = 256
  resource_group=var.resource_group
  # public_gateway = true
}
resource "ibm_is_public_gateway" "gateway1" {
  name = "gateway1"
  vpc  = ibm_is_vpc.vpc2.id
  zone = "us-south-1"
  resource_group=var.resource_group
  timeouts {
    create = "90m"
  }
}

resource "ibm_is_subnet_public_gateway_attachment" "subatt1" {
  subnet                = ibm_is_subnet.subnet4.id
  public_gateway         = ibm_is_public_gateway.gateway1.id
}

data "ibm_container_vpc_cluster" "cluster" {
  name  = "testcluster1"
  # depends_on = [ ibm_container_vpc_cluster.cluster ]
  
}


data "ibm_container_vpc_cluster_worker" "worker" {
  for_each= toset(data.ibm_container_vpc_cluster.cluster.workers)
  worker_id = each.value
  cluster_name_id = "testcluster1"
  depends_on = [ data.ibm_container_vpc_cluster.cluster ]


}

locals {
  # depends_on = [ data.ibm_container_vpc_cluster_worker.worker ]
  previous = [
    for i in data.ibm_container_vpc_cluster.cluster.workers:
    lookup(lookup(lookup(data.ibm_container_vpc_cluster_worker.worker,i),"network_interfaces")[0],"ip_address")
    
  ]
  
}
# locals {
#   ip1=data.ibm_container_vpc_cluster.cluster.workers
  
# }
output "prev" {
  value=local.previous
  
}
# # Print the id's of the workers
# # locals  {
# #   value1 = data.ibm_container_vpc_cluster.cluster.workers
# #   depends_on = [ data.ibm_container_vpc_cluster.cluster ]
  
# # }
# output "ip1" {
#   value = local.previous
#   depends_on = [ local.previous ]
  
# }


resource "ibm_container_vpc_cluster" "testcluster1" {
  name              = "testcluster1"
  vpc_id            = ibm_is_vpc.vpc2.id
  flavor            = "bx2.4x16"
  worker_count      = 2
  resource_group_id=var.resource_group_id
  kube_version      = "1.25.9"  
  update_all_workers     = true
  wait_for_worker_update = true
  depends_on = [ ibm_is_subnet.subnet4,data.ibm_container_vpc_cluster. cluster]
  #  ,data.ibm_container_vpc_cluster.cluster ,local.previous]
  zones {
    subnet_id = ibm_is_subnet.subnet4.id
    name      = "us-south-1"
    
  }
}
#To fetch information about the vpc cluster
data "ibm_container_vpc_cluster" "cluster1" {
  name  = "testcluster1"
  depends_on = [ ibm_container_vpc_cluster.testcluster1 ]
  
}
# Print the id's of the workers
output "workers" {
  value = data.ibm_container_vpc_cluster.cluster1.workers
  depends_on = [ data.ibm_container_vpc_cluster.cluster1 ]
  
}

#To fetch information about each worker node
data "ibm_container_vpc_cluster_worker" "worker1" {
  for_each= toset(data.ibm_container_vpc_cluster.cluster1.workers)
  worker_id = each.value
  cluster_name_id = "testcluster1"
  depends_on = [ ibm_container_vpc_cluster.testcluster1,data.ibm_container_vpc_cluster.cluster1 ]
}

#To print the information about the workers
# output "ip_address" {
#   value=data.ibm_container_vpc_cluster_worker.worker1
#   depends_on = [ data.ibm_container_vpc_cluster_worker.worker1 ]
# }

#To filter the ip address and store in a list
output "ip" {
  depends_on = [ ibm_container_vpc_cluster.testcluster1,data.ibm_container_vpc_cluster.cluster1,data.ibm_container_vpc_cluster_worker.worker1 ]
  value = [
    for i in data.ibm_container_vpc_cluster.cluster1.workers:
    lookup(lookup(lookup(data.ibm_container_vpc_cluster_worker.worker1,i),"network_interfaces")[0],"ip_address")
    
  ]
  
}

# data "ibm_container_vpc_cluster_worker" "worker2" {
#   worker_id       = "kube-cgnsv2ud0jhkn4p263d0-testcluster-mywp-00000761"
#   cluster_name_id = "test-cluster"
#   depends_on = [ ibm_container_vpc_cluster.cluster ]
# }


# data "ibm_container_vpc_cluster" "cluster1" {
#   name  = "testcluster1"
#   depends_on = [ ibm_container_vpc_cluster.testcluster1 ]
  
# }
# # Print the id's of the workers
# locals {
#   value2 = data.ibm_container_vpc_cluster.cluster1.workers
#   # depends_on = [ data.ibm_container_vpc_cluster.cluster1 ]
  
# }
# data "ibm_container_vpc_cluster_worker" "worker1" {
#   for_each= toset(local.value2)
#   worker_id = each.value
#   cluster_name_id = "testcluster1"
#   depends_on = [ data.ibm_container_vpc_cluster.cluster1 ]


# }

# locals {
#   # depends_on = [ data.ibm_container_vpc_cluster_worker.worker1 ]
#   new = [
#     for i in data.ibm_container_vpc_cluster.cluster1.workers:
#     lookup(lookup(lookup(data.ibm_container_vpc_cluster_worker.worker1,i),"network_interfaces")[0],"ip_address")
    
#   ]
  
# }

# output "ip2" {
#   value = local.new
  
  
  
# }

# locals {
#   # validation{
#   #   condition=local.value1==local.value2
#   #   error_message="Please chane the ip_address in the bluefringe"
#   # }
#   display=local.previous!=local.new?1:0
# }
# output "display" {
#   value = local.display
  
# }