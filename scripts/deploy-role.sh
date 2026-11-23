#!/bin/sh
# Creates or updates the role the GitHub Actions deploy assumes (infra/deploy-role.yml) and saves
# what .github/workflows/deploy.yml reads as repo variables. Run once, and again if pdb ever
# replaces the bucket or the distribution.
#
#   AWS_PROFILE            admin profile for the site's account (default: prod-pilot-admin)
#   SITE_BUCKET            skip the lookup of pdb's bucket by its tags
#   SITE_DISTRIBUTION_ID   skip the lookup of pdb's distribution by its tags
set -eu

profile="${AWS_PROFILE:-prod-pilot-admin}"
repository="nickpalenchar/seismic-site"
stack="seismic-site-github-deploy"
region="us-east-2"
cd "$(dirname "$0")/.."

# ARNs of pdb's seismic-site prod resources of one type, found by the tags pdb puts on them.
tagged() {
  aws resourcegroupstaggingapi get-resources --profile "$profile" --region "$1" \
    --resource-type-filters "$2" \
    --tag-filters Key=pdb_service,Values=seismic-site Key=pdb_environment,Values=prod "$3" \
    --query 'ResourceTagMappingList[].ResourceARN' --output text
}

# Exactly one match, or stop: a guess would point the deploy at the wrong resource.
only() {
  count="$(printf '%s\n' "$2" | wc -w | tr -d ' ')"
  if [ "$count" != 1 ]; then
    echo "deploy-role: expected one $1, found $count: $2 (set it by hand, see the header)" >&2
    exit 1
  fi
  # Word-split to drop the separators the lookups leave around the one match.
  set -- $2
  printf '%s' "$1"
}

bucket="${SITE_BUCKET:-}"
if [ -z "$bucket" ]; then
  arn="$(only "site bucket" "$(tagged "$region" s3:bucket Key=pdb_component,Values=site:static)")"
  bucket="${arn##*:}"
fi

distribution="${SITE_DISTRIBUTION_ID:-}"
if [ -z "$distribution" ]; then
  # Through CloudFront's own API, as pdb does: the account's SCP denies the tagging API in
  # us-east-1, where CloudFront's tags are listed. Redirect distributions are pdb_type=redirect.
  matches=""
  for arn in $(aws cloudfront list-distributions --profile "$profile" \
    --query 'DistributionList.Items[].ARN' --output text); do
    tags=",$(aws cloudfront list-tags-for-resource --profile "$profile" --resource "$arn" \
      --query "join(',', Tags.Items[].join('=', [Key, Value]))" --output text),"
    case "$tags" in
      *,pdb_service=seismic-site,*) ;;
      *) continue ;;
    esac
    case "$tags" in
      *,pdb_environment=prod,*) ;;
      *) continue ;;
    esac
    case "$tags" in
      *,pdb_type=site,*) matches="$matches ${arn##*/}" ;;
    esac
  done
  distribution="$(only "site distribution" "$matches")"
fi

# Repos on GitHub's immutable OIDC subjects sign as repo:<owner>@<id>/<repo>@<id>.
subject="$(gh api "repos/$repository/actions/oidc/customization/sub" --jq .sub_claim_prefix)"

create_provider=true
if aws iam list-open-id-connect-providers --profile "$profile" --output text \
  | grep -q "oidc-provider/token.actions.githubusercontent.com"; then
  create_provider=false
fi

echo "deploy-role: bucket=$bucket distribution=$distribution subject=$subject new-oidc-provider=$create_provider"

aws cloudformation deploy --profile "$profile" --region "$region" \
  --stack-name "$stack" --template-file infra/deploy-role.yml --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides "GitHubSubject=$subject" "BucketName=$bucket" \
    "DistributionId=$distribution" "CreateOidcProvider=$create_provider" \
  --no-fail-on-empty-changeset

role="$(aws cloudformation describe-stacks --profile "$profile" --region "$region" --stack-name "$stack" \
  --query "Stacks[0].Outputs[?OutputKey=='RoleArn'].OutputValue" --output text)"

gh variable set AWS_DEPLOY_ROLE_ARN --repo "$repository" --body "$role"
gh variable set SITE_BUCKET --repo "$repository" --body "$bucket"
gh variable set SITE_DISTRIBUTION_ID --repo "$repository" --body "$distribution"
echo "deploy-role: $role, repo variables set on $repository"
