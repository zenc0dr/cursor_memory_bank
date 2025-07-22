#!/bin/bash
set -e

REPO_URL="https://github.com/JackOman69/cursor_riper_memory_bank.git"

# 1. Клонирование
git clone "$REPO_URL" cursor_src

# 2. Копирование
rm -rf mcp/memory_bank_engine
mkdir -p mcp/memory_bank_engine
cp -r cursor_src/memory-bank-mcp/* mcp/memory_bank_engine/

# 3. Удаление исходников
rm -rf cursor_src

# 4. Сборка
cd mcp/memory_bank_engine
npm install
npm run build
cd ../..

# 5. Папка данных
mkdir -p memory-bank-data

# 6. Скрипт запуска
cat > scripts/start-memory-bank.sh <<'EOF'
#!/bin/bash
export MEMORY_BASE_PATH="$(pwd)/memory-bank-data"
mkdir -p "$MEMORY_BASE_PATH"
node ./mcp/memory_bank_engine/dist/memory-bank.js
EOF
chmod +x scripts/start-memory-bank.sh

# 7. Настройка Cursor
mkdir -p .cursor
cat > .cursor/mcp.json <<EOF
{
  "mcpServers": {
    "memory_bank": {
      "command": "node",
      "args": ["./mcp/memory_bank_engine/dist/memory-bank.js"],
      "env": { "MEMORY_BASE_PATH": "./memory-bank-data" }
    }
  }
}
EOF

echo "✅ Готово. Запуск: ./scripts/start-memory-bank.sh"