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
  # resource_group_name=IaC-dev
}

resource "ibm_container_vpc_cluster" "testcluster1" {
  name              = "testcluster1"
  vpc_id            = ibm_is_vpc.vpc2.id
  flavor            = "bx2.4x16"
  worker_count      = 2
  resource_group_id=var.resource_group_id
  kube_version      = "1.24.13"  
  update_all_workers     = true
  wait_for_worker_update = true
  depends_on = [ ibm_is_subnet.subnet4]
#   ,data.ibm_container_vpc_cluster.cluster ,local.value1,output.ip1]
  zones {
    subnet_id = ibm_is_subnet.subnet4.id
    name      = "us-south-1"
    
  }
}