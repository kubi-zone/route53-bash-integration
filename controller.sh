#!/usr/bin/env bash

set -e
set -o pipefail

for i in "$@"; do
    case $i in
        --namespace=*)
            namespace="-n ${i#*=}"
        ;;
        --zone=*)
            zone="${i#*=}"
        ;;
        --hosted-zone-id=*)
            hosted_zone_id="${i#*=}"
        ;;
        *)
            echo "Unknown option $i";
            exit 1
        ;;
    esac
done

if [ -z "$zone" ]; then
    echo "--zone not set, aborting!"
    echo ""
    echo "--zone must be set to the resource name of the kubi.zone Zone resource"
    echo "which acts as the source of records to be created in Route53."
    echo ""
    echo "If the zone resource is in a separate namespace from this container, the"
    echo "--namespace argument must also be set."
    echo ""
    echo "Note: must use '=' and no spacing between argument and value,"
    echo "e.g.: --zone=example-org"
    exit 1;
fi

if [ -z "$hosted_zone_id" ]; then
    echo "--hosted-zone-id not set, aborting!"
    echo ""
    echo "--hosted-zone-id must be set to the hosted zone ID as configured in Route53."
    echo ""
    echo "Note: must use '=' and no spacing between argument and value,"
    echo "e.g.: --hosted-zone-id=Z01234567890ABCABCABC"
    exit 1;
fi

echo "zone: $zone"
echo "hosted_zone_id: $hosted_zone_id"

while true; do
    # Fetch the .status.entries field from our Zone resource.
    entries=$(bash -c "kubectl get zone ${namespace} '${zone}' -o jsonpath='{.status.entries}'" 2>&1)
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "Failed to get zone entries: ${entries}"
        exit $exit_code;
    fi

    # Transform the entries to a JSON format compatible with the AWS CLI's route53
    # change-resource-record-sets command
    #
    # See: https://awscli.amazonaws.com/v2/documentation/api/latest/reference/route53/change-resource-record-sets.html
    echo "Current entries in ${zone}:"
    echo "$entries" | jq  '.
        | group_by(.class, .type, .fqdn) | map({
            "Name": .[0].fqdn,
            "Type": .[0].type,
            "TTL": .[0].ttl,
            "Class": .[0].class,
            "ResourceRecords": . |  map({"Value": .rdata })
        })
        | .[]
        | select(.Class == "IN") | del(.Class)
        | select(.Type == [
            "A",
            "AAAA",
            "CAA",
            "CNAME",
            "MX",
            "NAPTR",
            "NS",
            "PTR",
            "SPF",
            "SRV",
            "TXT"][])
        | {
            "Action": "UPSERT",
            "ResourceRecordSet": .
        }' | jq -s '{
            "Comment": "UPDATE",
            "Changes": .
        }' | tee change-batch.json

    if [ -f "old-change-batch.json" ]; then
        if diff "old-change-batch.json" "change-batch.json"; then
            echo "No change, skipping update."
            sleep 30
            continue
        fi
    fi

    echo "Applying update using aws cli"
    aws route53 change-resource-record-sets --hosted-zone-id="${hosted_zone_id}" --change-batch "file://change-batch.json"

    # Copy the just-applied change to a backup so we can compare and skip updating
    # if no records have changed.
    mv change-batch.json old-change-batch.json
    sleep 30
done
