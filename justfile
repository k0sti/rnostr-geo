# rnostr-geo development commands

# Default recipe - show available commands
default:
    @just --list

# Build the relay
build:
    cargo build --bin rnostr

# Build the relay in release mode
build-release:
    cargo build --bin rnostr --release

# Clear/reset the relay database
clear-db:
    #!/usr/bin/env bash
    echo "🗑️  Clearing relay database..."
    pkill -f "rnostr relay" || echo "No relay process found"
    sleep 1
    rm -rf data/
    echo "✅ Database cleared"

# Start the relay (without search features for faster build)
start-relay:
    #!/usr/bin/env bash
    echo "🚀 Starting rnostr relay..."
    cargo run --bin rnostr --no-default-features relay

# Start the relay in the background
start-relay-bg:
    #!/usr/bin/env bash
    echo "🚀 Starting rnostr relay in background..."
    cargo run --bin rnostr --no-default-features relay > relay.log 2>&1 &
    echo "Relay started (PID: $!)"
    echo "Check relay.log for output"

# Stop the relay
stop-relay:
    #!/usr/bin/env bash
    echo "🛑 Stopping relay..."
    pkill -f "rnostr relay" && echo "✅ Relay stopped" || echo "No relay process found"

# Restart the relay (clear DB, then start)
restart-relay: clear-db start-relay

# Check relay status
status:
    #!/usr/bin/env bash
    echo "📊 Relay Status:"
    if pgrep -f "rnostr relay" > /dev/null; then
        echo "✅ Relay is running (PID: $(pgrep -f 'rnostr relay'))"
        echo "📁 Database size:"
        du -sh data/ 2>/dev/null || echo "No database found"
    else
        echo "❌ Relay is not running"
    fi

# Show relay logs (last 20 lines)
logs:
    #!/usr/bin/env bash
    if [ -f "relay.log" ]; then
        echo "📋 Last 20 lines of relay.log:"
        tail -20 relay.log
    elif [ -f "test_relay.log" ]; then
        echo "📋 Last 20 lines of test_relay.log:"
        tail -20 test_relay.log
    else
        echo "No relay log files found"
    fi

# Follow relay logs in real-time
logs-follow:
    #!/usr/bin/env bash
    if [ -f "relay.log" ]; then
        tail -f relay.log
    elif [ -f "test_relay.log" ]; then
        tail -f test_relay.log
    else
        echo "No relay log files found. Start relay with 'just start-relay-bg' to generate logs."
    fi

# Clean up log files
clean-logs:
    rm -f relay.log test_relay.log geohash_test/relay.log

# Check database contents (show some sample events)
db-info:
    #!/usr/bin/env bash
    echo "📊 Database Information:"
    if [ -d "data" ]; then
        echo "Database exists at: $(pwd)/data"
        echo "Database size: $(du -sh data/ | cut -f1)"
        echo "Files:"
        ls -la data/
    else
        echo "No database found at $(pwd)/data"
    fi
