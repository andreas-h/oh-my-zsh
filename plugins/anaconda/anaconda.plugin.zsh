if [ -n "${ANACONDA_BASE+x}" ]; then
  if [[ ! $DISABLE_VENV_CD -eq 1 ]]; then
    # Automatically activate Git projects's virtual environments based on the
    # directory name of the project. Virtual environment name can be overridden
    # by placing a .venv file in the project root with a virtualenv name in it
    function anaconda_cwd {
        if [ ! $ANACONDA_CWD ]; then
            ANACONDA_CWD=1
            # Check if this is a Git repo
            PROJECT_ROOT=`git rev-parse --show-toplevel 2> /dev/null`
            if (( $? != 0 )); then
                PROJECT_ROOT="."
            fi
            # Check for virtualenv name override
            if [[ -f "$PROJECT_ROOT/.venv" ]]; then
                ENV_NAME=`cat "$PROJECT_ROOT/.venv"`
                ENV_PATH=$ENV_NAME
            elif [[ "$PROJECT_ROOT" != "." && -d "$ANACONDA_BASE/envs/`basename \"$PROJECT_ROOT\"`" ]]; then
                ENV_NAME=`basename "$PROJECT_ROOT"`
		ENV_PATH="$ANACONDA_BASE/envs/`basename \"$PROJECT_ROOT\"`"
            else
                ENV_NAME=""
            fi
            if [[ "$ENV_NAME" != "" ]]; then
                # Activate the environment only if it is not already active
                if [[ "$CONDA_DEFAULT_ENV" != "$ENV_NAME" ]]; then
		    ANACONDA_SAVE_PROMPT=$PROMPT
                    source $ANACONDA_BASE/bin/activate "$ENV_NAME" && export CD_VIRTUAL_ENV="$ENV_PATH"
		    PROMPT=$ANACONDA_SAVE_PROMPT
                fi
            elif [ $CD_VIRTUAL_ENV ]; then
                # We've just left the repo, deactivate the environment
                # Note: this only happens if the virtualenv was activated automatically
                source $ANACONDA_BASE/bin/deactivate && unset CD_VIRTUAL_ENV
		PROMPT=$ANACONDA_SAVE_PROMPT
            fi
            unset PROJECT_ROOT
            unset ANACONDA_CWD
        fi
    }

    # Append anaconda_cwd to the chpwd_functions array, so it will be called on cd
    # http://zsh.sourceforge.net/Doc/Release/Functions.html
    # TODO: replace with 'add-zsh-hook chpwd anaconda_cwd' when oh-my-zsh min version is raised above 4.3.4
    if (( ${+chpwd_functions} )); then
        if (( $chpwd_functions[(I)anaconda_cwd] == 0 )); then
            set -A chpwd_functions $chpwd_functions anaconda_cwd
        fi
    else
        set -A chpwd_functions anaconda_cwd
    fi
  fi
else
  print "zsh anaconda plugin: Cannot find Anaconda installation. Please set the environment variable \`ANACONDA_BASE\`."
fi
