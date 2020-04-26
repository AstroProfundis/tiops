#!/bin/bash

set -eu

version=${version-v4.0.0-rc}
name=test_cmd
topo=./topo/full.yaml

tiup-cluster check $topo -i ~/.ssh/id_rsa --enable-mem --enable-cpu --apply

yes | tiup-cluster check $topo -i ~/.ssh/id_rsa

yes | tiup-cluster deploy $name $version $topo -i ~/.ssh/id_rsa

tiup-cluster list | grep "$name"

tiup-cluster audit | grep "deploy $name $version"

# Get the audit id can check it just runnable
id=`tiup-cluster audit | grep "deploy $name $version" | awk '{print $1}'`
tiup-cluster audit $id


yes | tiup-cluster start $name

tiup-cluster _test $name writable

yes | tiup-cluster stop $name

yes | tiup-cluster restart $name

tiup-cluster _test $name writable

tiup-cluster display $name

totol_sub_one=19

echo "start scale in tidb"
yes | tiup-cluster scale-in $name -N 172.19.0.101:4000
wait_instance_num_reach $name $totol_sub_one
echo "start scale out tidb"
yes | tiup-cluster scale-out $name ./topo/full_scale_in_tidb.yaml

echo "start scale in tikv"
yes | tiup-cluster scale-in $name -N 172.19.0.103:20160
wait_instance_num_reach $name $totol_sub_one
echo "start scale out tikv"
yes | tiup-cluster scale-out $name ./topo/full_scale_in_tikv.yaml

echo "start scale in pd"
yes | tiup-cluster scale-in $name -N 172.19.0.103:2379
wait_instance_num_reach $name $totol_sub_one
echo "start scale out pd"
yes | tiup-cluster scale-out $name ./topo/full_scale_in_pd.yaml

echo "start scale in pump"
yes | tiup-cluster scale-in $name -N 172.19.0.103:8250
wait_instance_num_reach $name $totol_sub_one
echo "start scale out pump"
yes | tiup-cluster scale-out $name ./topo/full_scale_in_pump.yaml

echo "start scale in cdc"
yes | tiup-cluster scale-in $name -N 172.19.0.103:8300
wait_instance_num_reach $name $totol_sub_one
echo "start scale out cdc"
yes | tiup-cluster scale-out $name ./topo/full_scale_in_cdc.yaml

echo "start scale in grafana"
yes | tiup-cluster scale-in $name -N 172.19.0.101:3000
wait_instance_num_reach $name $totol_sub_one
echo "start scale out grafana"
yes | tiup-cluster scale-out $name ./topo/full_scale_in_grafana.yaml

tiup-cluster _test $name writable

yes | tiup-cluster destroy $name

