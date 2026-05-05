export MAMBA_EXE="${MAMBA_EXE:-$HOME/.local/bin/micromamba}"
export MAMBA_ROOT_PREFIX="${MAMBA_ROOT_PREFIX:-$HOME/micromamba}"

if [[ -x "$MAMBA_EXE" ]]; then
  eval "$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX")"
else 
  echo " micromamba not found at $MAMBA_EXE" >&2
fi
