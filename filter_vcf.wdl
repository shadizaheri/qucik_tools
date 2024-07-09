version 1.0

workflow FilterVCF {
  input {
    File vcf_file  # Input VCF file (vcf.gz)
    File vcf_index  # Input VCF index file (vcf.gz.tbi)
    File bed_file  # BED file with SNP positions
    String docker_image = "us.gcr.io/broad-dsp-lrma/mosdepth:sz_v3272024"  # Existing Docker image
    Int filter_vcf_cpu = 2  # Number of CPUs for FilterVCFTask
    String filter_vcf_memory = "4 GB"  # Memory for FilterVCFTask
    Int index_vcf_cpu = 1  # Number of CPUs for IndexVCFTask
    String index_vcf_memory = "2 GB"  # Memory for IndexVCFTask
    String filter_vcf_disk = "local-disk 10 HDD"  # Disk space for FilterVCFTask
    String index_vcf_disk = "local-disk 10 HDD"  # Disk space for IndexVCFTask
    String output_vcf_name = "filtered.vcf.gz"  # Output VCF file name
  }

  call FilterVCFTask {
    input:
      vcf_file = vcf_file,
      vcf_index = vcf_index,
      bed_file = bed_file,
      docker_image = docker_image,
      cpu = filter_vcf_cpu,
      memory = filter_vcf_memory,
      disk = filter_vcf_disk,
      output_vcf_name = output_vcf_name
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
    File vcf_index
    File bed_file
    String docker_image
    Int cpu
    String memory
    String disk
    String output_vcf_name
  }

  command {
    # Ensure the VCF file is indexed
    ln -s ~{vcf_index} ~{vcf_file}.tbi
    bcftools view -R ~{bed_file} -Oz -o ~{output_vcf_name} ~{vcf_file}
  }

  output {
    File filtered_vcf = "~{output_vcf_name}"
  }

  runtime {
    docker: docker_image
    cpu: cpu
    memory: memory
    disks: disk
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
    bcftools index -t ~{vcf_file}
  }

  output {
    File vcf_index = "~{vcf_file}.tbi"
  }

  runtime {
    docker: docker_image
    cpu: cpu
    memory: memory
    disks: disk
  }
}
