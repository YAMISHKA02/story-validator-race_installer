#!/bin/bash

# Color variables
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Language variable (default to English)
LANGUAGE="EN"

# Function to print colored output
log_message() {
    case $1 in
        "success") COLOR=$GREEN ;;
        "info") COLOR=$CYAN ;;
        "warning") COLOR=$MAGENTA ;;
        *) COLOR=$NC ;;
    esac

    case $LANGUAGE in
        "RU")
            case $2 in
                "setup_env") MESSAGE="Настройка окружения..." ;;
                "env_done") MESSAGE="Настройка окружения завершена" ;;
                "fetch_core") MESSAGE="Загрузка основных компонентов..." ;;
                "core_done") MESSAGE="Основные компоненты загружены и установлены" ;;
                "fetch_secondary") MESSAGE="Загрузка дополнительных компонентов..." ;;
                "secondary_done") MESSAGE="Дополнительные компоненты загружены и установлены" ;;
                "init_node") MESSAGE="Инициализация ноды..." ;;
                "node_done") MESSAGE="Нода успешно инициализирована" ;;
                "config_services") MESSAGE="Настройка сервисов..." ;;
                "services_done") MESSAGE="Сервисы настроены" ;;
                "start_services") MESSAGE="Запуск сервисов..." ;;
                "services_started") MESSAGE="Сервисы запущены" ;;
                "fetch_snapshots") MESSAGE="Загрузка снапшотов ноды..." ;;
                "snapshots_done") MESSAGE="Снапшоты успешно загружены" ;;
                "backup_done") MESSAGE="Бэкап успешно создан" ;;
                "clear_data") MESSAGE="Удаление старых данных..." ;;
                "data_cleared") MESSAGE="Старые данные удалены" ;;
                "restore_data") MESSAGE="Восстановление данных ноды..." ;;
                "data_restored") MESSAGE="Данные ноды восстановлены" ;;
                "restart_services") MESSAGE="Перезапуск сервисов..." ;;
                "services_restarted") MESSAGE="Сервисы успешно перезапущены" ;;
                "install_complete") MESSAGE="Установка и восстановление завершены!" ;;
            esac
            ;;
        "EN")
            case $2 in
                "setup_env") MESSAGE="Setting up environment..." ;;
                "env_done") MESSAGE="Environment setup completed" ;;
                "fetch_core") MESSAGE="Fetching core components..." ;;
                "core_done") MESSAGE="Core components fetched and installed" ;;
                "fetch_secondary") MESSAGE="Fetching additional components..." ;;
                "secondary_done") MESSAGE="Additional components fetched and installed" ;;
                "init_node") MESSAGE="Initializing node..." ;;
                "node_done") MESSAGE="Node successfully initialized" ;;
                "config_services") MESSAGE="Setting up services..." ;;
                "services_done") MESSAGE="Services configured" ;;
                "start_services") MESSAGE="Starting services..." ;;
                "services_started") MESSAGE="Services started" ;;
                "fetch_snapshots") MESSAGE="Fetching node snapshots..." ;;
                "snapshots_done") MESSAGE="Snapshots successfully downloaded" ;;
                "backup_done") MESSAGE="Backup created successfully" ;;
                "clear_data") MESSAGE="Clearing old data..." ;;
                "data_cleared") MESSAGE="Old data removed" ;;
                "restore_data") MESSAGE="Restoring node data..." ;;
                "data_restored") MESSAGE="Node data restored" ;;
                "restart_services") MESSAGE="Restarting services..." ;;
                "services_restarted") MESSAGE="Services successfully restarted" ;;
                "install_complete") MESSAGE="Installation and backup restoration complete!" ;;
            esac
            ;;
    esac

    echo -e "${COLOR}${MESSAGE}${NC}"
}

# Function to check command execution
validate() {
    if [ $? -eq 0 ]; then
        log_message "success" "$1_done"
    else
        log_message "warning" "$1_failed"
        exit 1
    fi
}

# Function to select language
select_language() {
    echo "Select installation language | Выберите язык установки:"
    echo "1) English"
    echo "2) Русский"
    read -p "Enter choice [1-2]: " lang_choice

    case $lang_choice in
        1)
            LANGUAGE="EN"
            ;;
        2)
            LANGUAGE="RU"
            ;;
        *)
            echo "Invalid choice, defaulting to English | Неверный выбор, используется английский"
            LANGUAGE="EN"
            ;;
    esac
}

# Function to install necessary packages
setup_environment() {
    log_message "info" "setup_env"
    sudo apt update && sudo apt-get update
    sudo apt install curl git make jq build-essential gcc unzip wget lz4 aria2 pv -y
    validate "env"
}

# Function to install the core binary
fetch_core() {
    log_message "info" "fetch_core"
    wget https://example.com/geth-core.tar.gz
    tar -xzvf geth-core.tar.gz
    rm geth-core.tar.gz
    mkdir -p $HOME/bin
    echo "export PATH=$PATH:~/bin" >> ~/.bashrc
    cp geth-core/geth $HOME/bin/my-geth
    rm -rf geth-core
    source ~/.bashrc
    my-geth version
    validate "core"
}

# Function to install secondary binary
fetch_secondary() {
    log_message "info" "fetch_secondary"
    wget https://example.com/secondary-binary.tar.gz
    tar -xzvf secondary-binary.tar.gz
    rm secondary-binary.tar.gz
    cp secondary-binary/mybinary $HOME/bin
    rm -rf secondary-binary
    source ~/.bashrc
    mybinary version
    validate "secondary"
}

# Function to initialize the node
initialize_node() {
    local alias=$1
    log_message "info" "init_node"
    mybinary init --network custom --alias "$alias"
    validate "node"
}

# Function to configure services
configure_services() {
    log_message "info" "config_services"
    sudo tee /etc/systemd/system/my-geth.service > /dev/null <<EOF
[Unit]
Description=Custom Geth Service
After=network.target

[Service]
User=root
ExecStart=/root/bin/my-geth --network-mode full
Restart=on-failure
RestartSec=5
LimitNOFILE=5000

[Install]
WantedBy=multi-user.target
EOF

    sudo tee /etc/systemd/system/mybinary.service > /dev/null <<EOF
[Unit]
Description=Custom Consensus Service
After=network.target

[Service]
User=root
ExecStart=/root/bin/mybinary run
Restart=on-failure
RestartSec=5
LimitNOFILE=5000

[Install]
WantedBy=multi-user.target
EOF

    validate "services"
}

# Function to start the services
activate_services() {
    log_message "info" "start_services"
    sudo systemctl daemon-reload
    sudo systemctl start my-geth
    sudo systemctl enable my-geth
    sudo systemctl start mybinary
    sudo systemctl enable mybinary
    validate "services_started"
}

# Function to download and restore backups
restore_backups() {
    # Backup sources
    local snapshot_url="https://example.com/snapshot.tar.lz4"
    local core_data_url="https://example.com/coredata.tar.lz4"

    log_message "info" "stop_services"
    sudo systemctl stop my-geth
    sudo systemctl stop mybinary
    validate "services_stopped"

    log_message "info" "fetch_snapshots"
    cd $HOME
    rm -f snapshot.tar.lz4 coredata.tar.lz4
    wget --show-progress $snapshot_url -O snapshot.tar.lz4
    wget --show-progress $core_data_url -O coredata.tar.lz4
    validate "snapshots"

    log_message "info" "backup"
    cp ~/.customnode/data/priv_validator_state.json ~/.customnode/priv_validator_state_backup.json
    validate "backup_done"

    log_message "info" "clear_data"
    rm -rf ~/.customnode/data
    rm -rf ~/.customgeth/gethdata
    validate "data_cleared"

    log_message "info" "restore_data"
    mkdir -p ~/.customnode/data
    lz4 -d -c snapshot.tar.lz4 | pv | tar xvf - -C ~/.customnode/data
    validate "data_restored"

    mkdir -p ~/.customgeth/gethdata
    lz4 -d -c coredata.tar.lz4 | pv | tar xvf - -C ~/.customgeth/gethdata
    validate "data_restored"

    log_message "info" "restore_state"
    cp ~/.customnode/priv_validator_state_backup.json ~/.customnode/data/priv_validator_state.json
    validate "state_restored"

    log_message "info" "restart_services"
    sudo systemctl start my-geth
    sudo systemctl start mybinary
    validate "services_restarted"
}

# Main function
install_node() {
    select_language
    read -p "$(if [[ $LANGUAGE == "RU" ]]; then echo 'Введите название ноды: '; else echo 'Enter node alias: '; fi)" alias
    setup_environment
    fetch_core
