#!/bin/bash

# 分卷压缩 + 独立镜像文件下载合并解压脚本
# 使用方式: ./download_all.sh

# 配置参数
BASE_URL="https://github.com/CHonghaohao/hvisor_env_img/releases/download/v2025.02.26sh"

# 分卷文件配置（必须按顺序排列）
ZIP_PARTS=(
  "rootfs1.zip.001"
  "rootfs1.zip.002"
  "rootfs1.zip.003"
)
ZIP_OUTPUT="rootfs1.zip"
UNZIP_DIR="images/aarch64/virtdisk"          # 解压目标目录

# 独立镜像文件配置
TARGET_DIR="images/aarch64/kernel"   # 目标目录路径
IMAGE_FILE="${TARGET_DIR}/Image"     # 镜像文件完整路径
IMAGE_URL="$BASE_URL/Image"

# 下载控制参数
MAX_RETRIES=3                # 单文件重试次数
PARALLEL_DOWNLOADS=1         # 并发下载数（提升大文件下载速度）
TIMEOUT=3600                  # 单文件超时时间（秒）

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# 检查依赖项
check_dependencies() {
  local missing=()
  command -v unzip >/dev/null 2>&1 || missing+=("unzip")
  command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 || missing+=("curl/wget")

  if [ ${#missing[@]} -gt 0 ]; then
    echo -e "${RED}错误：缺少依赖 - ${missing[*]}${NC}"
    exit 1
  fi
}

# 带进度显示的下载函数
download_file() {
  local url="$1"
  local output="$2"
  local retries=0

  while [ $retries -lt $MAX_RETRIES ]; do
    if [ -f "$output" ]; then
      local current_size=$(stat -c%s "$output" 2>/dev/null || echo 0)
      if command -v curl >/dev/null 2>&1; then
        curl -C - -# -L --retry 2 --max-time $TIMEOUT -o "$output" "$url" && return 0
      elif command -v wget >/dev/null 2>&1; then
        wget -c -q --show-progress --tries=2 --timeout=$TIMEOUT -O "$output" "$url" && return 0
      fi
    else
      if command -v curl >/dev/null 2>&1; then
        curl -# -L --retry 2 --max-time $TIMEOUT -o "$output" "$url" && return 0
      elif command -v wget >/dev/null 2>&1; then
        wget -q --show-progress --tries=2 --timeout=$TIMEOUT -O "$output" "$url" && return 0
      fi
    fi

    ((retries++))
    echo -e "${YELLOW}重试 ($retries/$MAX_RETRIES): $output${NC}"
    sleep 2
  done

  echo -e "${RED}下载失败: $url${NC}"
  return 1
}

# 主流程
main() {
  check_dependencies

  # 检查最终文件是否存在
  if [ -d "$UNZIP_DIR" ] && [ -f "$IMAGE_FILE" ]; then
    echo -e "${GREEN}所有文件已存在：\n- 镜像文件: $IMAGE_FILE\n- 解压目录: $UNZIP_DIR${NC}"
    exit 0
  fi

  # 并发下载分卷文件
  echo -e "${YELLOW}开始下载分卷文件 (并发数: $PARALLEL_DOWNLOADS)...${NC}"
  for part in "${ZIP_PARTS[@]}"; do
    local url="$BASE_URL/$part"
    local output="$part"

    if [ -f "$output" ]; then
      echo -e "${GREEN}分卷已存在: $output${NC}"
      continue
    fi

    ((i=i%PARALLEL_DOWNLOADS)); ((i++==0)) && wait
    (
      if download_file "$url" "$output"; then
        echo -e "${GREEN}下载完成: $output${NC}"
      else
        exit 1
      fi
    ) &
  done
  wait

  # 检查分卷完整性
  for part in "${ZIP_PARTS[@]}"; do
    if [ ! -f "$part" ]; then
      echo -e "${RED}分卷缺失: $part${NC}"
      exit 1
    fi
  done

  # 合并分卷
  if [ ! -f "$ZIP_OUTPUT" ]; then
    echo -e "${YELLOW}合并分卷文件 -> $ZIP_OUTPUT ...${NC}"
    cat "${ZIP_PARTS[@]}" > "$ZIP_OUTPUT" || {
      echo -e "${RED}合并失败!${NC}"
      exit 1
    }
  else
    echo -e "${GREEN}使用已存在的合并文件: $ZIP_OUTPUT${NC}"
  fi

  # 解压文件
  if [ ! -d "$UNZIP_DIR" ]; then
    echo -e "${YELLOW}解压到目录: $UNZIP_DIR ...${NC}"
    unzip -q "$ZIP_OUTPUT" -d "$UNZIP_DIR" || {  # 添加 -d 参数指定解压目录
      echo -e "${RED}解压失败! 可能原因:\n1. 密码保护\n2. 文件损坏${NC}"
      exit 1
    }
  fi

  # 下载独立镜像文件
  echo -e "${YELLOW}下载镜像文件: $IMAGE_FILE ...${NC}"
  mkdir -p "$TARGET_DIR" || {  # 自动创建目标目录
    echo -e "${RED}无法创建目录: $TARGET_DIR${NC}"
    exit 1
  }

  if [ -f "$IMAGE_FILE" ]; then
    echo -e "${GREEN}镜像已存在: $IMAGE_FILE${NC}"
  else
    download_file "$IMAGE_URL" "$IMAGE_FILE" || {
        echo -e "${RED}下载失败: $IMAGE_FILE${NC}"
        exit 1
    }
  fi

  # 最终验证
  echo -e "\n${GREEN}所有组件就绪："
  echo -e "  - 镜像文件: $(ls -lh $IMAGE_FILE)"
  echo -e "  - 解压目录: $(du -sh $UNZIP_DIR)${NC}"
}

main
