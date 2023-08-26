# 使用ubuntu作为基础镜像
FROM ubuntu:latest



# 复制entrypoint脚本到容器中
COPY *.sh /

# 添加可执行权限
RUN chmod +x /*.sh

# 定义entrypoint
ENTRYPOINT ["/entrypoint.sh"]