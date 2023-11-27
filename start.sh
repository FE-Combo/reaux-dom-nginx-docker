# 构建镜像
echo "docker build -t $1:$2 ."
docker buildx build --platform linux/amd64 -t $1:$2 .

# 移除容器
echo " docker rm -f $1:$2 || ture"
docker rm -f $1:$2 || ture

# 启动容器
echo "docker run -d -p 3000:80 --name $1:$2 $1:$2"
docker run -d -p 3000:80 --name $1:$2 $1:$2

# 移除为none的镜像
echo "docker rmi images"
docker rmi -f `docker images | grep \<none\> | awk '{print $3}'`

echo -e "\n\n\n"
