#!/bin/bash

root=`pwd`
version=${1}
imageReg=registry.cn-qingdao.aliyuncs.com/kangta123/hawk

# echo "data image(npm)"
# cd run/init && docker build -t ${imageReg}/hawk_init_npm:${version} -f Dockerfile_NPM .
# docker push ${imageReg}/hawk_init_npm:${version}
# cd ${root}

echo "data image(springboot)"
cd run/init && docker build -t ${imageReg}/hawk_init_springboot:${version} -f Dockerfile_SPRINGBOOT .
docker push ${imageReg}/hawk_init_springboot:${version}
cd ${root}

echo "data image(tomcat)"
cd run/init && docker build -t ${imageReg}/hawk_init_tomcat:${version} -f Dockerfile_TOMCAT .
docker push ${imageReg}/hawk_init_tomcat:${version}
cd ${root}


# base=(hlwojiv/alpine-jdk8 adoptopenjdk/openjdk11:jre-11.0.9.1_1-alpine)
# versions=(8 11)
# for (( i = 0; i < ${#base[@]}; i++ )); do
# 	v=${versions[i]}
# 	image=${base[i]}
#   echo "jdk ${v} image ${image}"
# 	cd run && docker build -t ${imageReg}/hawk_jdk${v}:${version} --build-arg JDK_IMAGE=${image} -f Dockerfile .
# 	docker push ${imageReg}/hawk_jdk${v}:${version}
# 	cd ${root}
# done


# echo "build image(maven)"
# cd build/maven && docker build -t ${imageReg}/hawk_maven_build:${version} -f Dockerfile .
# docker push ${imageReg}/hawk_maven_build:${version}
# cd ${root}



# echo "build image(gradle)"
# cd build/gradle && docker build -t ${imageReg}/hawk_gradle_build:${version} -f Dockerfile .
# docker push ${imageReg}/hawk_gradle_build:${version}
# cd ${root}

# echo "build image(npm)"
# cd build/npm && docker build -t ${imageReg}/hawk_npm_build:${version} -f Dockerfile .
# docker push ${imageReg}/hawk_npm_build:${version}
# cd ${root}


# echo "runtime image(tomcat8)"
# for v in 8 11;
# do
# 	cd run && docker build -t ${imageReg}/hawk_tomcat${v}:${version} --build-arg JDK_IMAGE=${imageReg}/hawk_jdk${v}:${version} -f tomcat/Dockerfile .
# 	docker push ${imageReg}/hawk_tomcat${v}:${version}
# 	cd ${root}
# done


# echo "runtime image(springboot)"
# for v in 8 11;
# do
# 	cd run && docker build -t ${imageReg}/hawk_springboot${v}:${version} --build-arg JDK_IMAGE=${imageReg}/hawk_jdk${v}:${version} -f springboot/Dockerfile .
# 	docker push ${imageReg}/hawk_springboot${v}:${version}
# 	cd ${root}
# done


# echo "runtime image(nginx)"
# cd run && docker build -t ${imageReg}/hawk_nginx:${version} -f nginx/Dockerfile .
# docker push ${imageReg}/hawk_nginx:${version}
# cd ${root}
