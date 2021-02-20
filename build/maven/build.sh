#!/usr/bin/env bash
export MAVEN_OPTS="-Xmx512m"
mode=${MODE:-single}

cp *.jar $JAVA_HOME/jre/lib/ext

check(){
  buildRet=$1
  echo "=@@$2 ${buildRet} $3@@@"
}

init_deps(){
  if [ -z "$(ls -A $1)" ]; then
    echo "Maven repo Empty, Loading dependencies..."
    mvn dependency:resolve -f app/
  fi
}

do_package(){
    mvn install -Dfindbugs.skip -Dcheckstyle.skip -Dpmd.skip=true -Denforcer.skip -Dmaven.javadoc.skip -Dmaven.test.skip.exec -Dlicense.skip=true -Drat.skip=true  -DskipTests -Dsonar.skip=true -Dpmd.skip=true -f $1
}

upload_app(){
    for f in `find . -name "pom.xml"`
    do
        arId=`mvn help:evaluate -Dexpression=project.artifactId -f $f | sed -n '/^\[/!p' | sed -n '/^Download/!p'`
        echo "=@@subProject@$PROJECT_ID@$REMOTE_BRANCH@$arId@${f%pom.xml*}@@@"
        echo ""
    done
}

package(){
    upload_app

    if [ ${mode} == 'single' ]; then
        f=`find . -name pom.xml | awk -F "/" '{print NF,$0}' | sort -n | head -n1 | awk '{print $2}'`
        do_package $f
    else
        for f in `find . -name "pom.xml"`
        do
            do_package $f
        done
    fi
    check $? "Build"
}

package_assign_project(){
   array=(${SUB_PATH//,/ })
   for var in ${array[@]}
   do
     for f in `find $var  -name "pom.xml"`
     do
         do_package $f
     done
   done

  check $? "Mvn"
}

build_docker(){
  JAR_FILE=$1
  pomFile=`dirname ${JAR_FILE}`
  groupId=${GROUP}
  name=`mvn help:evaluate -Dexpression=project.artifactId -f ${pomFile}/../ |grep -v "^\[" | grep -v "^Download" | grep -v "^Progress" `
  name=`echo $name | awk '{print tolower($0)}'`
  IMAGE_NAME="${IMAGE_PREFIX}${groupId}_${name}"

  tmp=$(mktemp dockerfile.XXXXXX)
  echo "FROM ${BASE_IMAGE}" > ${tmp}

  mkdir docker 2>/dev/null
  docker  build \
        --build-arg OUTPUT=${JAR_FILE}  \
        -t ${IMAGE_NAME}:${TAG} . -f - < ${tmp}

  check $? "DockerBuild" ${IMAGE_NAME}

  docker push ${IMAGE_NAME}:${TAG}
  check $? "DockerPush"

}

git_pull(){
  check 0 "Start"
  rm -fr app
  git clone --depth 1 -b ${REMOTE_BRANCH} ${GIT_URL}  app  && cd app
  check $? "GitClone"
}

build_jar(){
    unzip -l ${f} |grep "application.*\.properties\|application.*\.yml\|bootstrap.*\.yml\|bootstrap.*\.properties"   > /dev/null
    if [ $? -eq "0" ]; then
     echo "build file ${f} `pwd`"
      build_docker ${f}
    fi
}

build_war(){

  target=`find . -name "*.war" | head -1`
  echo "target is ${target}"
  targetFolder=`dirname ${target}`
  cd ${targetFolder}

  targetFile=`ls *.war | head -1`

  build_docker "${targetFile%.*}"

}
build(){
  size=`find . -name "pom.xml"|wc -l`
  if [ ${size} -eq '0' ]; then
   echo "Can not found file pom.xml"
    exit
  fi

  test -z $SUB_PATH && package || package_assign_project


  for f in `find . -regex ".*/target/[^/]*\.*[j|w]ar" |grep -v "sources\.jar"`
  do
    echo "build source ${f}"

    echo $f | grep -qE ".war$" && build_war $f
    echo $f | grep -qE ".jar$" && build_jar $f 
  done
}

git_pull

init_deps

build

check 0 "End"
