# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by newuser for 5.8.1
source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# pnpm
export PNPM_HOME="/home/macklinrw/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

# add Pulumi to the PATH
export PATH=$PATH:$HOME/.pulumi/bin

#zig
export PATH="$HOME/zig:$PATH"

# RISCV, assembly
export RISCV=$HOME/Programming/RISCV
export PATH=$PATH:$RISCV/bin

# unreal engine
# export UE4_ROOT=/mnt/ssd2/UnrealEngine_4.26

# jump
eval "$(jump shell)"
export LD_LIBRARY_PATH=/usr/local/cuda-12.3/lib64:$LD_LIBRARY_PATH
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# terminal
export TERM=xterm-ghostty
