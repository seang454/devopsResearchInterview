resource "local_file" "kubespray_inventory" {
  filename = abspath("${path.module}/${var.kubespray_inventory_path}")

  content = templatefile("${path.module}/templates/kubespray_inventory.tftpl", {
    control_plane_nodes          = module.kubespray_cluster.control_plane_nodes
    worker_nodes                 = module.kubespray_cluster.worker_nodes
    ansible_user                 = trimspace(var.ansible_user) != "" ? var.ansible_user : var.ssh_user
    ansible_ssh_private_key_file = pathexpand(var.ansible_ssh_private_key_file)
    ansible_python_interpreter   = var.ansible_python_interpreter
    ansible_ssh_extra_args       = var.ansible_ssh_extra_args
  })
}
