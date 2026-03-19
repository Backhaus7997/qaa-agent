#!/bin/bash
# QAA - QA Automation Agent Installer
# Installs to ~/.claude/qaa/ (similar to GSD at ~/.claude/get-shit-done/)

set -e

QAA_HOME="$HOME/.claude/qaa"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " QAA ► INSTALLING QA AUTOMATION AGENT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create QAA home
mkdir -p "$QAA_HOME"

# Copy core directories
echo "◆ Copying bin/ (CLI tooling)..."
cp -r "$SCRIPT_DIR/bin" "$QAA_HOME/"

echo "◆ Copying agents/ (7 agent workflows + orchestrator)..."
cp -r "$SCRIPT_DIR/agents" "$QAA_HOME/"

echo "◆ Copying templates/ (10 QA artifact templates)..."
cp -r "$SCRIPT_DIR/templates" "$QAA_HOME/"

echo "◆ Copying .claude/skills/ (6 QA skills)..."
mkdir -p "$QAA_HOME/skills"
cp -r "$SCRIPT_DIR/.claude/skills/"* "$QAA_HOME/skills/"

echo "◆ Copying .claude/commands/ (13 slash commands)..."
mkdir -p "$QAA_HOME/commands"
cp -r "$SCRIPT_DIR/.claude/commands/"* "$QAA_HOME/commands/"

echo "◆ Copying standards (CLAUDE.md)..."
cp "$SCRIPT_DIR/CLAUDE.md" "$QAA_HOME/CLAUDE.md"

echo "◆ Copying .claude/settings.json..."
cp "$SCRIPT_DIR/.claude/settings.json" "$QAA_HOME/settings.json"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " QAA ► INSTALLED ✓"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Installed to: $QAA_HOME"
echo ""
echo "To use in a project:"
echo "  cd /path/to/client/repo"
echo "  qaa init"
echo ""
echo "This copies CLAUDE.md + .claude/ (commands, skills, settings) into the project."
echo "Then open Claude Code and run: /qa-start"
echo ""
