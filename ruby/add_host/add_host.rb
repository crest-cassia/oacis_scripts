# edit the parameters

host_params = {
  name: "your_host",
  work_base_dir: "~/oacis_work",
  mounted_work_base_dir: "",
  max_num_jobs: 1,
  polling_interval: 60,
  min_mpi_procs: 1,
  max_mpi_procs: 1,
  min_omp_threads: 1,
  max_omp_threads: 1,
  executable_simulators: Simulator.all,
  executable_analyzers: Analyzer.all
}

Host.create!(host_params)
