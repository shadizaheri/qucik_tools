version 1.0

workflow FilterVCF {
  input {
    File vcf_file  # Input VCF file
    File bed_file  # BED file with SNP positions
  }

  call FilterVCFTask {
    input:
      vcf_file = vcf_file,
      bed_file = bed_file
  }

  call IndexVCFTask {
    input:
      vcf_file = FilterVCFTask.filtered_vcf
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
  }

  command {
    bcftools view -R ~{bed_file} -Oz -o filtered.vcf.gz ~{vcf_file}
  }

  output {
    File filtered_vcf = "filtered.vcf.gz"
  }

  runtime {
    docker: "biocontainers/bcftools:v1.9-1-deb_cv1"
  }
}

task IndexVCFTask {
  input {
    File vcf_file
  }

  command {
    bcftools index ~{vcf_file}
  }

  output {
    File vcf_index = "~{vcf_file}.csi"
  }

  runtime {
    docker: "biocontainers/bcftools:v1.9-1-deb_cv1"
  }
}

