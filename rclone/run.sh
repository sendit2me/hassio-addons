#!/usr/bin/env bashio

RCLONE_CONFIG=$(bashio::config 'configuration_path')
REMOTES=$(bashio::config 'remotes')

for remote in ${REMOTES}; do

    remote_name=$(bashio::jq "${remote}" ".name")

    remote_local_path=$(bashio::jq "${remote}" ".local_path")
    remote_local_retention=$(bashio::jq "${remote}" ".local_retention_days")

    remote_remote_path=$(bashio::jq "${remote}" ".remote_path")
    remote_remote_retention=$(bashio::jq "${remote}" ".remote_retention_days")

    bashio::log.info "Starting Remote copy for ${remote_name} ${remote_local_path} to ${remote_remote_path} ......"

    bashio::log.info "Pruning local files... ${remote_local_path} till ${remote_local_retention} ....."
    find ${remote_local_path} -mtime +${remote_local_retention} -type f -delete
    bashio::log.info "Pruning local files ${remote_local_path} finished"

    rclone --config ${RCLONE_CONFIG} \
        sync -v \
        --max-age "${remote_remote_retention}d" \
        --delete-during \
        --delete-excluded \
        --ignore-errors \
        --ignore-existing "${remote_local_path}" "${remote_name}:${remote_remote_path}"
    
    bashio::log.info "Remote copy for ${remote_name} ${remote_local_path} to ${remote_remote_path} finished"
done
