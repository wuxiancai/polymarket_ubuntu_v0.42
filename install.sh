#!/bin/bash

# 检查是否为 Ubuntu 系统
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        echo "错误: 此脚本仅支持 Ubuntu 系统"
        exit 1
    fi
fi

echo "开始安装 Polymarket Trader 环境..."

echo "正在安装系统依赖..."
# 安装系统依赖
sudo apt-get update
sudo apt-get install -y \
    python3-venv \
    python3-pip \
    python3-tk \
    python3-dev \
    python3-xlib \
    xclip \
    xsel \
    scrot \
    chromium-browser \
    chromium-chromedriver \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    x11-utils \
    python3-setuptools

echo "创建 Python 虚拟环境..."
# 创建并激活虚拟环境
python3 -m venv venv
source venv/bin/activate

# 升级 pip
pip install --upgrade pip

echo "安装 Python 依赖..."
# 安装 Python 依赖
pip install \
    selenium \
    pyautogui \
    pillow \
    python3-xlib \
    wheel

echo "检查 Chrome 和 ChromeDriver..."
# 检查 Chrome 是否已安装
if ! command -v chromium-browser &> /dev/null; then
    echo "正在安装 Chrome..."
    sudo apt-get install -y chromium-browser
else
    echo "Chrome 已安装，跳过安装"
fi

# 检查 ChromeDriver 是否已安装
if ! command -v chromedriver &> /dev/null; then
    echo "正在安装 ChromeDriver..."
    sudo apt-get install -y chromium-chromedriver
else
    echo "ChromeDriver 已安装，跳过安装"
fi

# 验证版本匹配
echo "验证 Chrome 和 ChromeDriver 版本..."
CHROME_VERSION=$(chromium-browser --version | cut -d ' ' -f 2)
CHROMEDRIVER_VERSION=$(chromedriver --version | cut -d ' ' -f 2)

echo "Chrome 版本: $CHROME_VERSION"
echo "ChromeDriver 版本: $CHROMEDRIVER_VERSION"

if [ "$CHROME_VERSION" != "$CHROMEDRIVER_VERSION" ]; then
    echo "警告: Chrome 版本 ($CHROME_VERSION) 与 ChromeDriver 版本 ($CHROMEDRIVER_VERSION) 不匹配"
    echo "尝试重新安装 ChromeDriver 以匹配 Chrome 版本..."
    sudo apt-get install --reinstall chromium-chromedriver
fi

chmod +x start_chrome.sh

# 创建程序启动脚本
cat > 10.sh << 'EOL'
#!/bin/bash
cd "$(dirname "$0")"
source venv/bin/activate
python3 crypto_trader_10.py
EOL
cat > 12.sh << 'EOL'
#!/bin/bash
cd "$(dirname "$0")"
source venv/bin/activate
python3 crypto_trader_12.py
EOL
cat > 14.sh << 'EOL'
#!/bin/bash
cd "$(dirname "$0")"
source venv/bin/activate
python3 crypto_trader_14.py
EOL
chmod +x 10.sh
chmod +x 12.sh
chmod +x 14.sh

# 创建环境变量配置文件
cat > .env << 'EOL'
DISPLAY=:0
PYTHONPATH=$PYTHONPATH:$HOME/polymarket_trader
EOL

echo "安装完成！"
echo "使用说明："
echo "1. 运行 ./start_chrome.sh 启动浏览器"
echo "2. 在另一个终端中运行 ./start_trader.sh 启动交易程序"
echo "注意：首次运行时需要在浏览器中手动登录 Polymarket"
