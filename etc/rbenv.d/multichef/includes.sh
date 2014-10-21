# Copyright 2014 Roy Liu
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

# Contains functionality common to plugin scripts.

# Gets the multichef configuration directory to use.
function multichef_config_dir {
    local -- config_name
    local -- config_file

    if [[ -n "$RBENV_MULTICHEF_CONFIG" ]]; then
        config_name=$RBENV_MULTICHEF_CONFIG
    elif { config_file=$(multichef_config_file "$1"); }; then
        config_name=$(cat -- "$config_file")
    else
        return -- 1
    fi

    local -- config_dir="${RBENV_MULTICHEF_ROOT}/configs/${config_name}"

    if [[ -d "$config_dir" ]]; then
        echo "$config_dir"
        return -- 0
    else
        echo "rbenv-multichef: the config directory \`${config_dir}\` doesn't exist" >&2
        return -- 1
    fi
}

# Finds the local (or global) multichef configuration file.
function multichef_config_file {
    local -- root=$1
    local -- config_file

    while [[ "$root" != "/" ]]; do
        if [[ -f "${root}/.multichef-config" ]]; then
            config_file="${root}/.multichef-config"
            break
        fi

        root=$(dirname -- "$root")
    done

    if [[ -z "$config_file" ]] && [[ -f "${RBENV_MULTICHEF_ROOT}/config" ]]; then
        config_file="${RBENV_MULTICHEF_ROOT}/config"
    fi

    if [[ -z "$config_file" ]]; then
        return -- 1
    fi

    echo "$config_file"
}

# Computes the absolute path.
function absolute_path {
    local -- head=$1
    local -- tail=$(basename -- "$head")
    local -- real_path
    local -- resolved=""

    while [[ "$head" != "/" ]] && [[ -n "$tail" ]]; do
        real_path=$head

        while [[ -n "$real_path" ]]; do
            if { ! head=$(cd -- "$(dirname -- "$real_path")" && pwd); }; then
                return -- 1
            fi

            tail=$(basename -- "$real_path")
            real_path=$(cd -- "$(dirname -- "$real_path")" && readlink -- "$tail" || true)
        done

        resolved="/${tail}${resolved}"
    done

    echo "$resolved"
}

if [[ -z "$RBENV_MULTICHEF_ROOT" ]]; then
    export -- RBENV_MULTICHEF_ROOT="${HOME}/.chef/multichef"
fi
