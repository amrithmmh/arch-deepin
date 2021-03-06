#!/bin/bash

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3, or
# (at your option) any later version.

source ./libhelper.sh

mirror="http://packages.deepin.com"
fileurl_prefix="/deepin"

# candidate mirrors
# mirror="http://ftp5.gwdg.de"
# fileurl_prefix="/pub/linux/linuxdeepin/packages"

# "http://ftp5.gwdg.de"
# "http://mirrors.ustc.edu.cn"
# "https://ftp.fau.de"

deepin_repo_sources=(
  "${mirror}${fileurl_prefix}/dists/trusty/main/source/Sources.gz"
  "${mirror}${fileurl_prefix}/dists/trusty/non-free/source/Sources.gz"
  "${mirror}${fileurl_prefix}/dists/trusty/universe/source/Sources.gz"
)
local_sources=(
  "./upstream_repos/main"
  "./upstream_repos/non-free"
  "./upstream_repos/universe"
)

download_repo_sources() {
  rm -f ./upstream_repos/*
  local i=0
  for s in "${deepin_repo_sources[@]}"; do
    local l="${local_sources[${i}]}"
    msg "Download repo source: ${s}"
    curl --retry 3 --retry-delay 3 -o "${l}".gz "${s}"
    gunzip -f "${l}".gz
    ((i+=1))
  done
}

# output $pkg_version, $pkg_fileurl, $pkg_sha256sum, etc.
get_pkginfo() {
  unset pkg_name pkg_info pkg_directory pkg_version pkg_version_fixed pkg_srcdirname
  unset pkg_files pkg_fileurls pkg_sha256sums pkg_file pkg_fileurl pkg_sha256sum
  unset pkg_file_orig pkg_fileurl_orig pkg_sha256sum_orig
  unset pkg_file_debian pkg_fileurl_debian pkg_sha256sum_debian
  unset obs_host obs_protocol obs_path obs_path_orig obs_path_debian
  pkg_name="${1}"
  pkg_info=$(grep_block "Package: ${pkg_name}\n" "${local_sources[@]}")
  if [ -z "${pkg_info}" ]; then
      error "get pkginfo failed: ${pkg_name}"
      return 1
  fi
  pkg_directory=$(echo "${pkg_info}" | grep -m1 "^Directory:" | awk '{print $2}')
  pkg_version=$(echo "${pkg_info}" | grep -m1 "^Version:" | awk '{print $2}')
  pkg_version="${pkg_version#*:}"           # remove prefix version like "1:"

  # get source directory name in source archive
  pkg_srcdirname="${pkg_name}-${pkg_version%-*}"

  # fix package version
  pkg_version_fixed="${pkg_version}"
  # if contains "-*+", replace "-" with "."
  pkg_version_fixed="$(echo ${pkg_version_fixed} | sed 's/-\(.\+\)+/.\1+/')"
  # remove git commit hash
  pkg_version_fixed="$(echo ${pkg_version_fixed} | sed 's/~[0-9a-f]\{10\}//')"
  pkg_version_fixed="${pkg_version_fixed%-*}"      # remove suffix "-*"
  pkg_version_fixed="${pkg_version_fixed/git/}"    # remove "git"
  pkg_version_fixed="${pkg_version_fixed/\~/.}"    # replace "~" with "."
  pkg_version_fixed="${pkg_version_fixed/+/.}"     # replace "+" with "."

  local version_prefix="$(get_package_versionprefix "${pkg_name}")"
  if [ "${version_prefix}" ]; then
    pkg_version_fixed="${version_prefix}.${pkg_version_fixed}"
  fi

  # get all files' information
  pkg_files=($(echo "${pkg_info}" | awk 'BEGIN{output=0} /: /{output=0} /Files: /{output=1} NF==3{if(output){print}}' | awk '{print $3}'))
  pkg_fileurls=()
  for f in "${pkg_files[@]}"; do
    pkg_fileurls+=("${mirror}${fileurl_prefix}/${pkg_directory}/${f}")
  done
  pkg_sha256sums=($(echo "${pkg_info}" | awk 'BEGIN{output=0} /: /{output=0} /Checksums-Sha256: /{output=1} NF==3{if(output){print}}' | awk '{print $1}'))

  # get the default source file's information
  pkg_file="${pkg_name}_${pkg_version}.tar.gz"
  pkg_fileurl="${mirror}${fileurl_prefix}/${pkg_directory}/${pkg_file}"
  pkg_sha256sum=$(echo "${pkg_info}" | awk 'BEGIN{output=0} /: /{output=0} /Checksums-Sha256: /{output=1} NF==3{if(output){print}}' | grep "${pkg_file}" | awk '{print $1}')

  # get special source files' information if exists
  local i=0
  for f in "${pkg_files[@]}"; do
    case "${f}" in
      *orig.tar*)
        pkg_file_orig="${f}"
        pkg_fileurl_orig="${pkg_fileurls[$i]}"
        pkg_sha256sum_orig="${pkg_sha256sums[$i]}"
        ;;
      *debian.tar*)
        pkg_file_debian="${f}"
        pkg_fileurl_debian="${pkg_fileurls[$i]}"
        pkg_sha256sum_debian="${pkg_sha256sums[$i]}"
        ;;
    esac
    ((i++))
  done

  # split host, protocol and path from fileurl, used for _service in OBS
  obs_host="${mirror#*://}"
  obs_protocol="${mirror%://*}"
  obs_path="${fileurl_prefix}/${pkg_directory}/${pkg_file}"
  obs_paths=()
  for f in "${pkg_files[@]}"; do
    obs_paths+=("${fileurl_prefix}/${pkg_directory}/${f}")
  done
  obs_path_orig="${fileurl_prefix}/${pkg_directory}/${pkg_file_orig}"
  obs_path_debian="${fileurl_prefix}/${pkg_directory}/${pkg_file_debian}"
}
