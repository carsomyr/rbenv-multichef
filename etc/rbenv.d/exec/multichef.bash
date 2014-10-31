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

# The plugin delegate for `rbenv exec`.

source -- "$(dirname -- "$(dirname -- "${BASH_SOURCE[0]}")")/multichef/includes.sh"

if { config_dir=$(multichef_config_dir "$(pwd)"); }; then
    if [[ "$RBENV_COMMAND" != "bundle" ]]; then
        cmd="$RBENV_COMMAND"
    else
        cmd="$3"
    fi

    case "$cmd" in
        chef-client)
            config_file="${config_dir}/client.rb"

            if [[ -f "$config_file" ]]; then
                # Run `chef-client` with the configuration file prepended to the command-line arguments.
                if [[ "$RBENV_COMMAND" != "bundle" ]]; then
                    shift -- 1
                    set -- "-" "-c" "$config_file" "$@"
                else
                    shift -- 3
                    set -- "-" "exec" "chef-client" "-c" "$config_file" "$@"
                fi
            else
                echo "rbenv-multichef: running without an implicit \`client.rb\` file, which wasn't found in"\
" \`$(absolute_path "$config_dir")\`" >&2
            fi
            ;;

        knife)
            # Export the `KNIFE_HOME` environment variable for `knife` to pick up later.
            export -- KNIFE_HOME=$config_dir
            ;;
    esac
fi
