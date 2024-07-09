version 1.0

workflow FilterVCF {
  input {
    File vcf_file  # Input VCF file
    File bed_file  # BED file with SNP positions
    String docker_image = "us.gcr.io/broad-dsp-lrma/mosdepth:sz_v3152024"  # Existing Docker image
    Int filter_vcf_cpu = 2  # Number of CPUs for FilterVCFTask
    String filter_vcf_memory = "4 GB"  # Memory for FilterVCFTask
    Int index_vcf_cpu = 1  # Number of CPUs for IndexVCFTask
    String index_vcf_memory = "2 GB"  # Memory for IndexVCFTask
    String filter_vcf_disk = "10 GB"  # Disk space for FilterVCFTask
    String index_vcf_disk = "10 GB"  # Disk space for IndexVCFTask
  }

  call FilterVCFTask {
    input:
      vcf_file = vcf_file,
      bed_file = bed_file,
      docker_image = docker_image,
      cpu = filter_vcf_cpu,
      memory = filter_vcf_memory,
      disk = filter_vcf_disk
  }

  call IndexVCFTask {
    input:
      vcf_file = FilterVCFTask.filtered_vcf,
      docker_image = docker_image,
      cpu = index_vcf_cpu,
      memory = index_vcf_memory,
      disk = index_vcf_disk
  }

  output {
    File filtered_vcf = FilterVCFTask.filtered_vcf
    File filtered_vcf_index = IndexVCFTask.vcf_index
  }
}

task FilterVCFTask {
  input {
    File vcf_file
    File bed_file
    String docker_image
    Int cpu
    String memory
    String disk
  }

  command {
    bcftools view -R ~{bed_file} -Oz -o filtered.vcf.gz ~{vcf_file}
  }

  output {
    File filtered_vcf = "filtered.vcf.gz"
  }

  runtime {
    docker: docker_image
    cpu: cpu
    memory: memory
    disks: "local-disk " + disk
  }
}

task IndexVCFTask {
  input {
    File vcf_file
    String docker_image
    Int cpu
    String memory
    String disk
  }

  command {
    bcftools index ~{vcf_file}
  }

  output {
    File vcf_index = "~{vcf_file}.csi"
  }

  runtime {
    docker: docker_image
    cpu: cpu
    memory: memory
    disks: "local-disk " + disk
  }
}
