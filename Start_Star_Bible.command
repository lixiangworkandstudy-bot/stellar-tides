#!/bin/bash
# 获取当前脚本所在目录
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 进入项目目录
cd "$DIR"

echo "✨ 正在启动星尘宇宙引擎 (Starting Stellar Tides Engine)..."
echo "📍 目录: $DIR"

# 检查 node_modules 是否存在，不存在则安装
if [ ! -d "node_modules" ]; then
    echo "📦 首次运行，正在安装依赖 (Installing dependencies)..."
    npm install
fi

# 启动服务器并自动打开浏览器
# 这里的 & 符号和 open 命令配合使用可能比较复杂，我们直接使用 vite 的 --open 参数更稳妥
# 或者简单的逻辑：
# 使用 Vite 的自动打开功能，它会自动处理端口
npm run dev -- --open

# 如果 npm run dev 停止了（用户关闭了终端窗口），脚本也就结束了
