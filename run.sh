#!/usr/bin/env bash

# Directory this script lives in
test_root=$(dirname $(realpath $0))

# Create and set up each test project
for project_name in \
  project_base_working \
  project_updated_before_gradle_invocation_working \
  project_updated_after_gradle_invocation_broken \
  project_updated_after_gradle_no_daemon_invocation_working
do
  if [[ -e ${test_root}/${project_name} ]]
  then
    echo "Directory for \"${project_name}\" already exists"
    echo "Please run clean.sh to remove existing project directories and files."
    exit
  fi

  cp -r CLEAN_project ${test_root}/${project_name}
done

# run base project
(
  project_name=project_base_working
  echo "==========================================================="
  echo "-- ${project_name}"
  echo "-----------------------------------------------------------"

  cd ${test_root}/${project_name}

  ./gradlew clean build jmh &> ${test_root}/${project_name}.1.out
  [[ $? == 0 ]] && echo "Success" || echo "Fail (UNEXPECTED)"

  ./gradlew clean build jmh &> ${test_root}/${project_name}.2.out
  [[ $? == 0 ]] && echo "Success" || echo "Fail (UNEXPECTED)"

  echo "==========================================================="
)

# Update project *before* gradle and run
(
  project_name=project_updated_before_gradle_invocation_working

  echo "==========================================================="
  echo "-- ${project_name}"
  echo "-----------------------------------------------------------"

  cd ${test_root}/${project_name}

  cp ${test_root}/MyClassBenchmark.java.update ${test_root}/${project_name}/src/jmh/java/MyClassBenchmark.java

  ./gradlew clean build jmh &> ${test_root}/${project_name}.1.out
  [[ $? == 0 ]] && echo "Success" || echo "Fail (UNEXPECTED)"

  ./gradlew clean build jmh &> ${test_root}/${project_name}.2.out
  [[ $? == 0 ]] && echo "Success" || echo "Fail (UNEXPECTED)"

  echo "==========================================================="
)

# Update project *after* gradle and run
(
  project_name=project_updated_after_gradle_invocation_broken

  echo "==========================================================="
  echo "-- ${project_name}"
  echo "-----------------------------------------------------------"

  cd ${test_root}/${project_name}

  ./gradlew clean build jmh &> ${test_root}/${project_name}.1.out
  [[ $? == 0 ]] && echo "Success" || echo "Fail (UNEXPECTED)"

  cp ${test_root}/MyClassBenchmark.java.update ${test_root}/${project_name}/src/jmh/java/MyClassBenchmark.java

  ./gradlew clean build jmh &> ${test_root}/${project_name}.2.out
  [[ $? == 0 ]] && echo "Success (UNEXPECTED)" || echo "Fail (expected)"

  echo "==========================================================="
)

# Update project *after* gradle and run
(
  project_name=project_updated_after_gradle_no_daemon_invocation_working
  echo "==========================================================="
  echo "-- ${project_name}"
  echo "-----------------------------------------------------------"

  cd ${test_root}/${project_name}

  ./gradlew --no-daemon clean build jmh &> ${test_root}/${project_name}.1.out
  [[ $? == 0 ]] && echo "Success" || echo "Fail (UNEXPECTED)"

  cp ${test_root}/MyClassBenchmark.java.update ${test_root}/${project_name}/src/jmh/java/MyClassBenchmark.java

  ./gradlew --no-daemon clean build jmh &> ${test_root}/${project_name}.2.out
  [[ $? == 0 ]] && echo "Success" || echo "Fail (UNEXPECTED)"

  echo "==========================================================="
)
