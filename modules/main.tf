# To fetch information about each worker node
data "ibm_container_vpc_cluster_worker" "worker1" {
  # count = length(local.ids)
  # # name               = "diag-rule"
  # worker_id = local.ids[count.index]
  for_each= local.ids
  worker_id = each.value
  cluster_name_id = "test-cluster1"
  depends_on = [ ibm_container_vpc_cluster.cluster5]
}

#To print the information about the workers
output "ip_address" {
  value=data.ibm_container_vpc_cluster_worker.worker1
  depends_on = [ data.ibm_container_vpc_cluster_worker.worker1 ]
}

#To filter the ip address and store in a list
output "ip" {
  depends_on = [ data.ibm_container_vpc_cluster_worker.worker1 ]
  value = [
    for i in data.ibm_container_vpc_cluster.cluster1.workers:
    lookup(lookup(lookup(data.ibm_container_vpc_cluster_worker.worker1,i),"network_interfaces")[0],"ip_address")
    
  ]
  
}