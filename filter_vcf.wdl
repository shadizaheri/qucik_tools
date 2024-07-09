version 1.0

workflow FilterVCF {
  input {
    File vcf_file  # Input VCF file
    File bed_file  # BED file with SNP positions
    String docker_image = "us.gcr.io/broad-dsp-lrma/mosdepth:sz_v3152024"  # Existing Docker image
  }

  call FilterVCFTask {
    input:
      vcf_file = vcf_file,
      bed_file = bed_file,
      docker_image = docker_image
  }

  call IndexVCFTask {
    input:
      vcf_file = FilterVCFTask.filtered_vcf,
      docker_image = docker_image
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
  }

  command {
    bcftools view -R ~{bed_file} -Oz -o filtered.vcf.gz ~{vcf_file}
  }

  output {
    File filtered_vcf = "filtered.vcf.gz"
  }

  runtime {
    docker: docker_image
    memory: "4 GB"
    cpu: "2"
  }
}

task IndexVCFTask {
  input {
    File vcf_file
    String docker_image
  }

  command {
    bcftools index ~{vcf_file}
  }

  output {
    File vcf_index = "~{vcf_file}.csi"
  }

  runtime {
    docker: docker_image
    memory: "2 GB"
    cpu: "1"
  }
}
